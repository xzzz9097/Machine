//
//  ImageRequestCaptureDelegate.swift
//  Machine
//
//  Created by lyrae on 29/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Foundation
import AVFoundation
import Vision

typealias VNRequestFailHandler   = () -> ()
typealias VNRequestSuccesHandler = (VNRequest, Error?) -> ()

class VisionRequestCaptureDelegate: NSObject,
                                    AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var request: VNRequest?
    
    var shouldTrack = true
    
    private var failHandler: VNRequestFailHandler?
    
    private var completionHandler: VNRequestSuccesHandler? {
        return request?.completionHandler
    }
    
    static let `default` = VisionRequestCaptureDelegate()
    
    private override init() { }
    
    init(request: VNRequest,
         failHandler: @escaping VNRequestFailHandler) {
        super.init()
        configure(for: request, failHandler: failHandler)
    }
    
    func configure(for request: VNRequest,
                   failHandler: @escaping VNRequestFailHandler) {
        self.request        = request
        self.failHandler    = failHandler
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard   let request = request,
                let failHandler = failHandler else {
                return
        }
        
        guard   shouldTrack,
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                failHandler()
                return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: 1,
                                                        options: [:])
        
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
}
