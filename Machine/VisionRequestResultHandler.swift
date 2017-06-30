//
//  VisionRequestResultHandler.swift
//  Machine
//
//  Created by lyrae on 30/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

protocol VisionRequestResultHandlerProtocol {
    
    var delegate: VisionRequestResultHandlerDelegate? { get set }
    
}

protocol VisionRequestResultHandlerDelegate: class {
    
    func didReceiveResults(_ results: [Any])
    
}

extension VisionRequestResultHandlerProtocol {
    
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
            
            self.delegate?.didReceiveResults(observations)
        }
    }
    
}

class VisionRequestResultHandler:
      VisionRequestResultHandlerProtocol  {
    
    var delegate: VisionRequestResultHandlerDelegate?
    
    init(delegate: VisionRequestResultHandlerDelegate?) {
        self.delegate = delegate
    }
    
}
