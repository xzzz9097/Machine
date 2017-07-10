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
typealias VNRequests             = [ObservationTag: VNRequest]

class VNRequestCaptureDelegate: NSObject,
                                AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var requests: VNRequests = [ : ]
    
    var shouldTrack = true
    
    private var failHandler: VNRequestFailHandler?
    
    static let `default` = VNRequestCaptureDelegate()
    
    private override init() { }
    
    init(requests: VNRequests,
         failHandler: @escaping VNRequestFailHandler) {
        super.init()
        configure(for: requests, failHandler: failHandler)
    }
    
    init(failHandler: @escaping VNRequestFailHandler) {
        super.init()
        configure(failHandler: failHandler)
    }
    
    func configure(for requests: VNRequests? = nil,
                   failHandler: @escaping VNRequestFailHandler) {
        if let requests = requests {
            self.requests = requests
        }
        
        self.failHandler = failHandler
    }
    
    func configure(for requests: VNRequests) {
        self.requests = requests
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard   let failHandler = failHandler else {
                return
        }
        
        guard   shouldTrack,
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                failHandler()
                return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .up,
                                                        options: [:])
        
        do {
            try imageRequestHandler.perform(
                requests.map { $0.value }
            )
        } catch {
            print(error)
        }
    }
    
    func has(_ tag: ObservationTag) -> Bool {
        return requests[tag] != nil
    }
    
    func add(_ request: VNRequest,
             tag: ObservationTag) {
        requests[tag] = request
    }
    
    func remove(_ request: ObservationTag) {
        requests.removeValue(forKey: request)
    }
    
}
