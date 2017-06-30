//
//  VisionDetectedObjectHandler.swift
//  Machine
//
//  Created by lyrae on 30/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

protocol VisionDetectedObjectHandlerDelegate:
    VisionRequestResultHandlerDelegate {
    
    func didReceiveBoundingBoxes(_ boxes: [NSRect])
    
}

extension VisionDetectedObjectHandlerDelegate {
    
    func didReceiveResults(_ results: [Any]) {
        let boxes = results
            .flatMap { $0 as? VNFaceObservation }
            .map { $0.boundingBox }
            .sorted { $0.minX < $1.minX }
        
        didReceiveBoundingBoxes(boxes)
    }
    
}
