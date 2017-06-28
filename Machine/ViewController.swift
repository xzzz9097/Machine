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
    
    var captureSession = CaptureSession()
    
    var hideFace = false
        
    var faceViews: [FaceView] = [ ] {
        didSet {
            cameraView.subviews = [ ]
            
            for view in faceViews {
                cameraView.addSubview(view)
            }
        }
    }
    
    var shouldTrack = true
    
    @IBOutlet weak var cameraView: NSView!
    
    @IBAction func trackingMenuItemClicked(_ sender: Any) {
        shouldTrack = !shouldTrack
        
        if let sender = sender as? NSMenuItem {
            sender.state = shouldTrack ? .on : .off
        }
    }
    
    @IBAction func lowPowerMenuItemClicked(_ sender: Any) {
        captureSession.lowPower = !captureSession.lowPower
        
        captureSession.resetFrameDuration()
        
        if let sender = sender as? NSMenuItem {
            sender.state = captureSession.lowPower ? .on : .off
        }
    }
    
    @IBAction func hideFacesMenuItemClicked(_ sender: Any) {
        hideFace = !hideFace
        
        faceViews = [ ]
        
        if let sender = sender as? NSMenuItem {
            sender.state = hideFace ? .on : .off
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        
        loadCaptureSession()
    }
    
    func loadCaptureSession() {
        captureSession.delegate = self
        
        cameraView.layer?.addSublayer(captureSession.previewLayer)
        
        captureSession.start()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        captureSession.previewLayer.frame = self.cameraView.bounds
    }
    
    func prepareViews() {
        cameraView.wantsLayer = true
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard   shouldTrack,
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            resetFaceViews()
                    
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
        
        let delta = results.count - faceViews.count
        
        if delta > 0 {
            for _ in 0..<delta {
                DispatchQueue.main.async {
                    self.faceViews.append(FaceView(frame: NSRect(),
                                                   hiddenFace: self.hideFace))
                }
            }
        } else if delta < 0 {
            for _ in 0..<abs(delta) {
                DispatchQueue.main.async {
                    if !self.faceViews.isEmpty { self.faceViews.removeLast() }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.faceViews = self.faceViews.sorted { $0.frame.minX < $1.frame.minX }
        }
        
        guard !results.isEmpty else {
            resetFaceViews()
            
            return
        }
        
        for (result, view) in zip(results, faceViews) {
            DispatchQueue.main.async {
                view.updateFrame(to: result.scaled(
                        width: self.cameraView.bounds.width,
                        height: self.cameraView.bounds.height
                    )
                )
            }
        }
    }
    
    func resetFaceViews() {
        for view in faceViews {
            DispatchQueue.main.async {
                view.updateFrame(to: NSRect())
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
