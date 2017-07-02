//
//  Status.swift
//  Machine
//
//  Created by lyrae on 02/07/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Vision

enum StatusComponent {
    case faceDetection
    case classificationObservation
}

typealias StatusComponents = [StatusComponent: String]

struct Status {
    
    var components: StatusComponents = [ : ]
    
    var stringValue: String {
        return components.values.joined(separator: ",")
    }
    
}
