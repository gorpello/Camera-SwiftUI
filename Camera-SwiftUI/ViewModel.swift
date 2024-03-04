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
class ViewModel {
    
    var currentFrame: CGImage?
    
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}

extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        guard let imagePixelBuffer = pixelBuffer else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return cgImage
    }
}


