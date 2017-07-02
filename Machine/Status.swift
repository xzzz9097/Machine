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
    case none
    
    var defaultValue: String {
        switch self {
        case .faceDetection:
            return "No faces detected"
        case .classificationObservation:
            return "no objects detected"
        case .none:
            return "Nothing detected 🤔"
        }
    }
}

typealias StatusComponents = [StatusComponent: String]

struct Status {
    
    var components: StatusComponents = [ : ]
    
    var stringValue: String {
        let string = components
            .filter { $0.value != $0.key.defaultValue }
            .filter { $0.key != .none }
            .values
            .joined(separator: ", ")
        
        guard !string.isEmpty else {
            return StatusComponent.none.defaultValue
        }
        
        return string
    }
    
}
