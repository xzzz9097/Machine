//
//  CaptureSession.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa
import AVFoundation

class CaptureSession {
    
    private var captureQueue = DispatchQueue(label: "captureQueue")
    
    private let session = AVCaptureSession()
    
    private var connection: AVCaptureConnection!
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? {
        didSet {
            videoOutput.setSampleBufferDelegate(delegate,
                                                queue: captureQueue)
        }
    }
    
    var lowPower = true
    
    init() {
        loadCaptureSession()
    }
    
    func loadCaptureSession() {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video capture device available")
        }
        
        do {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            session.addInput(cameraInput)
            session.addOutput(videoOutput)
            
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as
                                         String: kCVPixelFormatType_32BGRA]
            session.sessionPreset     = .high
            
            connection = videoOutput.connection(with: .video)
            
            resetFrameDuration()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func setFrameDuration(_ times: CMTime) {
        setFrameDuration(connection: connection, times)
    }
    
    func resetFrameDuration() {
        setFrameDuration(lowPower ? lowPowerFrameDuration : minFrameDuration)
    }
    
}
