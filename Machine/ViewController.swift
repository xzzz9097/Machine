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

class ViewController: NSViewController,
                      VisionDetectedObjectHandlerDelegate,
                      NSWindowDelegate {
    
    var requestDelegate = VisionRequestCaptureDelegate.default
    
    var resnetDelegate  = VisionRequestCaptureDelegate.default
    
    var captureSession = CaptureSession()
    
    var hideFace = false
    
    var faceViews: [FaceView] = [ ] {
        didSet {
            cameraView.subviews = cameraView.subviews.filter {
                !($0 is FaceView)
            }
            
            for view in faceViews {
                cameraView.addSubview(
                    view,
                    positioned: .below,
                    relativeTo: cameraView.subviews.filter{ $0 is FaceView }.first
                )
            }
        }
    }
    
    @IBOutlet weak var cameraView: NSView!
    
    @IBOutlet weak var statusView: NSTextField!
    
    @IBOutlet weak var eyeView: NSImageView!
    
    @IBAction func trackingMenuItemClicked(_ sender: Any) {
        requestDelegate.shouldTrack = !requestDelegate.shouldTrack
        
        if let sender = sender as? NSMenuItem {
            sender.state = requestDelegate.shouldTrack ? .on : .off
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
    
    func prepareWindow() {
        guard let window = self.view.window else { return }
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility            = .hidden
        window.delegate                   = self
        window.appearance                 = NSAppearance(named: .vibrantDark)
        window.styleMask.insert(.fullSizeContentView)
    }
    
    func loadCaptureSession() {
        let detectedObjectHandler = VisionRequestResultHandler(delegate: self)
        
        requestDelegate.configure(
            for: VNDetectFaceRectanglesRequest(
                completionHandler: detectedObjectHandler.requestResultHandler
            ),
            failHandler: { self.resetFaceViews() }
        )
        
        prepareResnetModel()
        
        captureSession.delegate = requestDelegate
        
        cameraView.layer?.addSublayer(captureSession.previewLayer)
    }
    
    func prepareResnetModel() {
        
        guard let resnet = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Failed to load ResNet model")
        }
        
        resnetDelegate.configure(
            for: VNCoreMLRequest(model: resnet,
                                 completionHandler: didReceiveResnetResults),
            failHandler: { print("Error") }
        )
        
        captureSession.delegate = resnetDelegate
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        captureSession.previewLayer.frame = self.cameraView.bounds
        
        prepareWindow()
    }
    
    func prepareViews() {
        cameraView.wantsLayer = true
        
        statusView.alignment = .center
        
        if let osdView = statusView.superview {
            osdView.wantsLayer = true
            osdView.layer?.cornerRadius = 5
        }
    }
    
    func resetFaceViews() {
        for view in faceViews {
            DispatchQueue.main.async {
                view.updateFrame(to: NSRect())
            }
        }
    }
    
    var isCaptureSessionRunning: Bool = false {
        didSet {
            if isCaptureSessionRunning {
                captureSession.start()
                eyeView.isHidden = true
            } else {
                captureSession.stop()
                eyeView.isHidden       = false
                statusView.stringValue = "You're (not) being watched"
                faceViews              = [ ]
            }
        }
    }
    
    func didReceiveResnetResults(request: VNRequest, error: Error?) {
        guard let results = request.results else {
            return
        }
        
        let classifications = results[0...4] // top 4 results
            .flatMap { $0 as? VNClassificationObservation }
            .filter { $0.confidence > 0.3 }
            .map { "\($0.identifier) \(($0.confidence * 100.0).rounded())" }
        
        guard let first = classifications.first else {
            DispatchQueue.main.async {
                self.statusView.stringValue = "Nothing 🤔 detected..."
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.statusView.stringValue = String(describing: first)
        }
    }
    
    // MARK: VisionDetectedObjectHandlerDelegate
    
    func didReceiveBoundingBoxes(_ boxes: [NSRect]) {
        let delta = boxes.count - faceViews.count
        
        if abs(delta) > 0 {
            DispatchQueue.main.async {
                switch boxes.count {
                case 0:
                    self.statusView.stringValue = "No 🤔 detected..."
                default:
                    self.statusView.stringValue = "\(boxes.count) 😀 detected!"
                }
            }
        }
        
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
        
        if boxes.isEmpty {
            resetFaceViews()
            return
        }
        
        DispatchQueue.main.async {
            self.faceViews = self.faceViews.sorted { $0.frame.minX < $1.frame.minX }
        }
        
        for (box, view) in zip(boxes, faceViews) {
            DispatchQueue.main.async {
                view.updateFrame(to: box.scaled(
                        width: self.cameraView.bounds.width,
                        height: self.cameraView.bounds.height
                    )
                )
            }
        }
    }
    
    // MARK: NSWindowDelegate
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        if window.occlusionState.contains(.visible) {
            isCaptureSessionRunning = true
        } else {
            isCaptureSessionRunning = false
        }
    }
    
}
