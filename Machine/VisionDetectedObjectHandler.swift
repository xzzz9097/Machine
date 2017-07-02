//
//  VisionDetectedObjectHandler.swift
//  Machine
//
//  Created by lyrae on 30/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension VisionRequestResultHandlerProtocol
    where Request: VNDetectRectanglesRequest {
    
    func didReceiveResults(_ results: [Any]) {
        if let delegate = delegate as? VisionDetectedObjectHandlerDelegate {
            let boxes = results
                .flatMap { $0 as? VNDetectedObjectObservation }
                .map { $0.boundingBox }
                .sorted { $0.minX < $1.minX }
            
            delegate.didReceiveBoundingBoxes(boxes)
        }
    }
    
}

protocol VisionDetectedObjectHandlerDelegate {
    
    func didReceiveBoundingBoxes(_ boxes: [NSRect])
    
}

class VisionDetectedObjectHandler: VisionRequestResultHandlerProtocol {
    
    typealias Request = VNDetectRectanglesRequest
    
    var delegate: Any?
        
    init(delegate: VisionDetectedObjectHandlerDelegate) {
        self.delegate = delegate
    }
    
}
