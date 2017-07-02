//
//  VisionRequestResultHandler.swift
//  Machine
//
//  Created by lyrae on 30/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

protocol VNRequestResultHandler {
    
    associatedtype Request
    
    var delegate: Any? { get set }
    
    func didReceiveResults(_ results: [Any])
    
}

extension VNRequestResultHandler {
    
    var requestResultHandler: VNRequestCompletionHandler {
        return {
            request, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            guard let observations = request.results else {
                print("No results")
                return
            }
            
            self.didReceiveResults(observations)
        }
    }
    
}
