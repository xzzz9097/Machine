//
//  ViewController+VNClassificationObservation.swift
//  Machine
//
//  Created by lyrae on 03/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension ViewController: VNClassificationObservationDelegate {
    
    func didReceiveClassificationObservations(tag: ObservationTag,
                                              _ observations: [VNClassificationObservation]) {
        let classifications = observations[0...4] // top 4 results
            .filter { $0.confidence > 0.3 }
            .map { "\($0.identifier) \(($0.confidence * 100.0).rounded())" }
        
        guard let first = classifications.first else {
            DispatchQueue.main.async {
                self.status.components[.classificationObservation] = StatusComponent.classificationObservation.defaultValue
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.status.components[.classificationObservation] = String(describing: first)
        }
    }
    
}
