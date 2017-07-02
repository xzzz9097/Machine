//
//  VisionDetectedObjectHandler.swift
//  Machine
//
//  Created by lyrae on 30/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension VNRequestResultHandler
    where Request: VNDetectRectanglesRequest {
    
    func didReceiveResults(_ results: [Any]) {
        if let delegate = delegate as? VNDetectedObjectDelegate {
            let boxes = results
                .flatMap { $0 as? VNDetectedObjectObservation }
                .map { $0.boundingBox }
                .sorted { $0.minX < $1.minX }
            
            delegate.didReceiveBoundingBoxes(boxes)
        }
    }
    
}

protocol VNDetectedObjectDelegate {
    
    func didReceiveBoundingBoxes(_ boxes: [NSRect])
    
}

class VNDetectedObjectHandler: VNRequestResultHandler {
    
    typealias Request = VNDetectRectanglesRequest
    
    var delegate: Any?
        
    init(delegate: VNDetectedObjectDelegate) {
        self.delegate = delegate
    }
    
}
