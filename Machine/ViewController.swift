//
//  ViewController.swift
//  Machine
//
//  Created by lyrae on 26/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureQueue = DispatchQueue(label: "captureQueue")
    
    var gradientLayer = CAGradientLayer()

    @IBOutlet weak var cameraView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCaptureSession()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        previewLayer.frame = self.cameraView.bounds;
        gradientLayer.frame = self.cameraView.bounds;
    }
    
    func loadCaptureSession() {
        // Load the camera
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video capture device available")
        }
        
        do {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraView.wantsLayer = true
            cameraView.layer?.addSublayer(previewLayer)
            
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            session.sessionPreset = .high
            
            // wire up the session
            session.addInput(cameraInput)
            session.addOutput(videoOutput)
            
            // make sure we are in portrait mode
            let conn = videoOutput.connection(with: .video)
            conn?.videoOrientation = .portrait
            
            // Start the session
            session.startRunning()
        } catch {
            
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

