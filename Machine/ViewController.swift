//
//  ViewController.swift
//  Machine
//
//  Created by lyrae on 26/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa
import AVFoundation
import Vision

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let session = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureQueue = DispatchQueue(label: "captureQueue")
    
    var gradientLayer = CAGradientLayer()
    
    var faceRect = NSView(frame: NSRect())
    
    @IBOutlet weak var cameraView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        
        loadCaptureSession()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        previewLayer.frame  = self.cameraView.bounds;
        gradientLayer.frame = self.cameraView.bounds;
    }
    
    func prepareViews() {
        cameraView.wantsLayer = true
        faceRect.wantsLayer   = true
        
        faceRect.layer?.borderColor = NSColor.yellow.cgColor
        faceRect.layer?.borderWidth = 1
        
        cameraView.addSubview(faceRect)
    }
    
    func loadCaptureSession() {
        // Load the camera
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video capture device available")
        }
        
        do {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraView.layer?.addSublayer(previewLayer)
            
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            videoOutput.videoSettings =
                [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            session.sessionPreset = .high
            
            // Load the session
            session.addInput(cameraInput)
            session.addOutput(videoOutput)
            
            let connection = videoOutput.connection(with: .video)
            
            // Reduce frame rate
            if (connection?.isVideoMinFrameDurationSupported)! {
                // Polls requests every 1/2 second
                connection?.videoMinFrameDuration = CMTimeMake(1, 2)
            }
            
            // Start the session
            session.startRunning()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: 1,
                                                        options: [:])
        
        do {
            try imageRequestHandler.perform(
                [VNDetectFaceRectanglesRequest(completionHandler: handleRequestOutput)]
            )
        } catch {
            print(error)
        }
    }
    
    func handleRequestOutput(request: VNRequest, error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        let results = observations
            .flatMap({$0 as? VNFaceObservation})
            .map({$0.boundingBox})
        
        for result in results {
            DispatchQueue.main.async {
                self.faceRect.frame = result.scaled(
                    width: self.cameraView.bounds.width,
                    height: self.cameraView.bounds.height
                )
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension CGRect {
    func scaled(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: self.minX * width,
                      y: self.minY * height,
                      width: self.width * width,
                      height: self.height * height)
    }
}

