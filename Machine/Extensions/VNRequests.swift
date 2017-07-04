//
//  VNRequests.swift
//  Machine
//
//  Created by lyrae on 04/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

extension VNDetectFaceRectanglesRequest {
    
    convenience init(tag: ObservationTag,
                     delegate: VNDetectedObjectDelegate) {
        self.init(
            completionHandler: VNDetectedObjectHandler(
                tag: tag,
                delegate: delegate).requestResultHandler
        )
    }
    
}

extension VNCoreMLRequest {
    
    convenience init(model: VNCoreMLModel,
                     tag: ObservationTag,
                     delegate: VNClassificationObservationDelegate) {
        self.init(
            model: model,
            completionHandler: VNClassificationObservationHandler(
                tag: tag,
                delegate: delegate).requestResultHandler
        )
    }
    
}
