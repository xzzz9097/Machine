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

extension ObservationTag {
    static let faceRequest: NSString =
        "faceRequest"
    static let resnetClassificationRequest: NSString =
        "resnetClassificationRequest"
}

class ViewController: NSViewController,
                      NSWindowDelegate,
                      CaptureSessionDelegate {
    
    var requestDelegate = VNRequestCaptureDelegate.default
        
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
    
    var status = Status() {
        didSet {
            statusView.stringValue = status.stringValue
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
    
    @IBAction func toggleResnetMenuItemClicked(_ sender: Any) {
        let hasResnetRequest =
            requestDelegate.has(.resnetClassificationRequest)
        
        if hasResnetRequest {
            requestDelegate.remove(.resnetClassificationRequest)
        } else {
            addResnetRequest()
        }
        
        if let sender = sender as? NSMenuItem {
            sender.state = !hasResnetRequest ? .on : .off
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
        addFaceRequest()
        
        requestDelegate.configure(failHandler: { self.resetFaceViews() })
        
        captureSession.captureDelegate = requestDelegate
        captureSession.sessionDelegate = self
        
        cameraView.layer?.addSublayer(captureSession.previewLayer)
    }
    
    func addFaceRequest() {
        requestDelegate.add(VNDetectFaceRectanglesRequest(tag: .faceRequest,
                                                          delegate: self),
                            tag: .faceRequest)
    }
    
    func addResnetRequest() {
        guard let resnet = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Failed to load ResNet model")
        }
        
        requestDelegate.add(VNCoreMLRequest(model: resnet,
                                            tag: .resnetClassificationRequest,
                                            delegate: self),
                            tag: .resnetClassificationRequest)
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
    
    // MARK: CaptureSessionDelegate
    
    func didChangeSessionRunningState(_ running: Bool) {
        eyeView.isHidden = running
        
        if !running {
            statusView.stringValue = "You're (not) being watched"
            faceViews              = [ ]
        }
    }
    
    // MARK: NSWindowDelegate
    
    func windowDidChangeOcclusionState(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        if window.occlusionState.contains(.visible) {
            captureSession.isRunning = true
        } else {
            captureSession.isRunning = false
        }
    }
    
}
