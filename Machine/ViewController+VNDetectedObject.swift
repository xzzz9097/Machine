//
//  ViewController+VNDetectedObject.swift
//  Machine
//
//  Created by lyrae on 03/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

extension ViewController: VNDetectedObjectDelegate {

    func didReceiveBoundingBoxes(tag: ObservationTag,
                                 _ boxes: [NSRect]) {
        let delta = boxes.count - faceViews.count
        
        if abs(delta) > 0 {
            DispatchQueue.main.async {
                switch boxes.count {
                case 0:
                    self.status.components[.faceDetection] = StatusComponent.faceDetection.defaultValue
                default:
                    self.status.components[.faceDetection] = "\(boxes.count) 😀 detected"
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
