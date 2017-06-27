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
    
    var connection: AVCaptureConnection!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureQueue = DispatchQueue(label: "captureQueue")
        
    var faceRects: [FaceRect] = [ ] {
        didSet {
            cameraView.subviews = [ ]
            
            for rect in faceRects {
                cameraView.addSubview(rect)
            }
        }
    }
    
    var lowPower = true
    
    var shouldTrack = true
    
    var lowPowerFrameDuration = CMTimeMake(1, 2) // Every 1/2 second
    var minFrameDuration      = CMTimeMake(0, 0)
    
    @IBOutlet weak var cameraView: NSView!
    
    @IBAction func trackingMenuItemClicked(_ sender: Any) {
        shouldTrack = !shouldTrack
        
        if let sender = sender as? NSMenuItem {
            sender.state = shouldTrack ? .on : .off
        }
    }
    
    @IBAction func lowPowerMenuItemClicked(_ sender: Any) {
        lowPower = !lowPower
        
        resetFrameDuration()
        
        if let sender = sender as? NSMenuItem {
            sender.state = lowPower ? .on : .off
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        
        loadCaptureSession()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        previewLayer.frame  = self.cameraView.bounds
    }
    
    func prepareViews() {
        cameraView.wantsLayer = true
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
            
            connection = videoOutput.connection(with: .video)
            
            resetFrameDuration()
            
            // Start the session
            session.startRunning()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func setFrameDuration(_ times: CMTime) {
        if (connection?.isVideoMinFrameDurationSupported)! {
            connection?.videoMinFrameDuration = times
        }
    }
    
    func resetFrameDuration() {
        connection.videoMinFrameDuration =  lowPower ?
                                            lowPowerFrameDuration :
                                            minFrameDuration
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard   shouldTrack,
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            resetFaceRectagle()
                    
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
            .flatMap { $0 as? VNFaceObservation }
            .map { $0.boundingBox }
            .sorted { $0.minX < $1.minX }
        
        let delta = results.count - faceRects.count
        
        if delta > 0 {
            for _ in 0..<delta {
                DispatchQueue.main.async {
                    self.faceRects.append(FaceRect(frame: NSRect()))
                }
            }
        } else if delta < 0 {
            for _ in 0..<abs(delta) {
                DispatchQueue.main.async {
                    if !self.faceRects.isEmpty { self.faceRects.removeLast() }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.faceRects = self.faceRects.sorted { $0.frame.minX < $1.frame.minX }
        }
        
        guard !results.isEmpty else {
            resetFaceRectagle()
            
            return
        }
        
        for (result, faceRect) in zip(results, faceRects) {
            DispatchQueue.main.async {
                faceRect.animator().frame = result.scaled(
                    width: self.cameraView.bounds.width,
                    height: self.cameraView.bounds.height
                )
            }
        }
    }
    
    func resetFaceRectagle() {
        for faceRect in faceRects {
            DispatchQueue.main.async {
                faceRect.frame = NSRect()
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

class FaceRect: NSView {
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.wantsLayer         = true
        self.layer?.borderColor = NSColor.random.cgColor
        self.layer?.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension NSColor {
    
    static var random: NSColor {
        return NSColor(red: CGFloat(drand48()),
                       green: CGFloat(drand48()),
                       blue: CGFloat(drand48()),
                       alpha: 1)
    }
    
}

