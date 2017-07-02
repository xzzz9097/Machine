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
    
    func didReceiveResults(tag: ObservationTag.RawValue, _ results: [Any]) {
        if let delegate = delegate as? VNDetectedObjectDelegate {
            let boxes = results
                .flatMap { $0 as? VNDetectedObjectObservation }
                .map { $0.boundingBox }
                .sorted { $0.minX < $1.minX }
            
            delegate.didReceiveBoundingBoxes(tag: tag,
                                             boxes)
        }
    }
    
}

protocol VNDetectedObjectDelegate {
    
    func didReceiveBoundingBoxes(tag: ObservationTag.RawValue,
                                 _ boxes: [NSRect])
    
}

class VNDetectedObjectHandler: VNRequestResultHandler {
    
    typealias Request = VNDetectRectanglesRequest
    
    var delegate: Any?
    
    var tag: ObservationTag.RawValue
        
    init(tag: ObservationTag.RawValue,
         delegate: VNDetectedObjectDelegate) {
        self.tag      = tag
        self.delegate = delegate
    }
    
}
