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
    
    var requests: [VNRequest]?
    
    var shouldTrack = true
    
    private var failHandler: VNRequestFailHandler?
    
    static let `default` = VisionRequestCaptureDelegate()
    
    private override init() { }
    
    init(requests: [VNRequest],
         failHandler: @escaping VNRequestFailHandler) {
        super.init()
        configure(for: requests, failHandler: failHandler)
    }
    
    func configure(for requests: [VNRequest],
                   failHandler: @escaping VNRequestFailHandler) {
        self.requests       = requests
        self.failHandler    = failHandler
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard   let requests = requests,
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
            try imageRequestHandler.perform(requests)
        } catch {
            print(error)
        }
    }
    
}
