//
//  VisionClassificationObservationHandlerDelegate.swift
//  Machine
//
//  Created by lyrae on 02/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension VNRequestResultHandler
    where Request: VNCoreMLRequest {
    
    func didReceiveResults(tag: ObservationTag.RawValue, _ results: [Any]) {
        if let delegate = delegate as? VNClassificationObservationDelegate {
            let classifications = results
                .flatMap { $0 as? VNClassificationObservation }
            
            delegate.didReceiveClassificationObservations(tag: tag,
                                                          classifications)
        }
    }
    
}

protocol VNClassificationObservationDelegate {
    
    func didReceiveClassificationObservations(tag: ObservationTag.RawValue,
                                              _ observations: [VNClassificationObservation])
    
}

class VNClassificationObservationHandler: VNRequestResultHandler {
    
    typealias Request = VNCoreMLRequest
    
    var delegate: Any?
    
    var tag: ObservationTag.RawValue
    
    init(tag: ObservationTag.RawValue,
         delegate: VNDetectedObjectDelegate) {
        self.tag      = tag
        self.delegate = delegate
    }
    
}
