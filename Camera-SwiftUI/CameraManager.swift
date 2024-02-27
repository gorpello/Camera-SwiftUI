//
//  CameraManager.swift
//  Camera-SwiftUI
//
//  Created by Gianluca Orpello on 27/02/24.
//

import Foundation
import AVFoundation

protocol CameraManagerDelegate {
    /**
     This method delivers the pixel buffer of the current frame seen by the device's camera.
     */
    func didOutput(sampleBuffer: CMSampleBuffer)
}


class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: CameraFeedManagerDelegate
    var delegate: CameraManagerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let defaultVideoDevice = AVCaptureDevice.default(for: .video)
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    //    private let sessionQueue = DispatchQueue(label: "session.queue")
    private let videoOutputQueue = DispatchQueue(label: "video.output.queue")
    
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
        
    }
    
    private func configureSession() async {
        guard await isAuthorized else { return }
        
        captureSession.beginConfiguration()
        
        if captureSession.canSetSessionPreset(.iFrame1280x720) {
            captureSession.sessionPreset = .iFrame1280x720
        }
        
        if let defaultVideoDevice,
           let videoDeviceInput = try? AVCaptureDeviceInput(device: defaultVideoDevice),
           captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: .main)
     
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        captureSession.commitConfiguration()
    }
    
    private func startSession() async {
        guard await isAuthorized else { return }
        captureSession.startRunning()
    }
    
    /**
     AVCaptureVideoDataOutputSampleBufferDelegate
     */
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Delegates the pixel buffer to the ViewController.
        delegate?.didOutput(sampleBuffer: sampleBuffer)
    }
    
}
