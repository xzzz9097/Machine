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
    
    func didReceiveResults(tag: ObservationTag, _ results: [Any]) {
        if let delegate = delegate as? VNClassificationObservationDelegate {
            let classifications = results
                .flatMap { $0 as? VNClassificationObservation }
            
            delegate.didReceiveClassificationObservations(tag: tag,
                                                          classifications)
        }
    }
    
}

protocol VNClassificationObservationDelegate: class {
    
    func didReceiveClassificationObservations(tag: ObservationTag,
                                              _ observations: [VNClassificationObservation])
    
}

class VNClassificationObservationHandler: VNRequestResultHandler {
    
    typealias Request = VNCoreMLRequest
    
    weak var delegate: AnyObject?
    
    var tag: ObservationTag
    
    init(tag: ObservationTag,
         delegate: VNClassificationObservationDelegate) {
        self.tag      = tag
        self.delegate = delegate
    }
    
}
