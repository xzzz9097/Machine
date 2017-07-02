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
    
    func didReceiveResults(_ results: [Any]) {
        if let delegate = delegate as? VNClassificationObservationDelegate {
            let classifications = results
                .flatMap { $0 as? VNClassificationObservation }
            
            delegate.didReceiveClassificationObservations(classifications)
        }
    }
    
}

protocol VNClassificationObservationDelegate {
    
    func didReceiveClassificationObservations(_ observations: [VNClassificationObservation])
    
}

class VNClassificationObservationHandler: VNRequestResultHandler {
    
    typealias Request = VNCoreMLRequest
    
    var delegate: Any?    
    
    init(delegate: VNDetectedObjectDelegate) {
        self.delegate = delegate
    }
    
}
