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
                      VisionDetectedObjectHandlerDelegate {
    
    var requestDelegate = VisionRequestCaptureDelegate.default
    
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
        window.titleVisibility = .hidden
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
        
        captureSession.delegate = requestDelegate
        
        cameraView.layer?.addSublayer(captureSession.previewLayer)
        
        captureSession.start()
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
    
}

