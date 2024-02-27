//
//  ViewModel.swift
//  Camera-SwiftUI
//
//  Created by Gianluca Orpello on 27/02/24.
//

import Foundation
import AVFoundation
import CoreImage

@Observable
class ViewModel: CameraManagerDelegate {
    
    var currentFrame: CGImage?
    
    private let cameraManager = CameraManager()
    
    init() {
        cameraManager.delegate = self
    }
    
    func didOutput(sampleBuffer: CMSampleBuffer) {
        
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let imagePixelBuffer = pixelBuffer else { return }
        
        self.currentFrame = CIImage(cvPixelBuffer: imagePixelBuffer).image
    }
}

extension CIImage {
    var image: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return cgImage
    }
}
