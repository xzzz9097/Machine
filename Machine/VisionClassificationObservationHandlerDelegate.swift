//
//  VisionClassificationObservationHandlerDelegate.swift
//  Machine
//
//  Created by lyrae on 02/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension VisionRequestResultHandlerProtocol
    where Request: VNCoreMLRequest {
    
    func didReceiveResults(_ results: [Any]) {
        if let delegate = delegate as? VisionClassificationObservationHandlerDelegate {
            let classifications = results
                .flatMap { $0 as? VNClassificationObservation }
            
            delegate.didReceiveClassificationObservations(classifications)
        }
    }
    
}

protocol VisionClassificationObservationHandlerDelegate {
    
    func didReceiveClassificationObservations(_ observations: [VNClassificationObservation])
    
}

class VisionClassificationObservationHandler: VisionRequestResultHandlerProtocol {
    
    typealias Request = VNCoreMLRequest
    
    var delegate: Any?    
    
    init(delegate: VisionDetectedObjectHandlerDelegate) {
        self.delegate = delegate
    }
}
