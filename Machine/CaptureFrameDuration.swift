//
//  CaptureFrameDuration.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import AVFoundation

extension CaptureSession {
    
    var lowPowerFrameDuration: CMTime {
        return CMTimeMake(1, 2) // Every 1/2 second
    }
    
    var minFrameDuration: CMTime {
        return CMTimeMake(0, 0) // Maximum refresh rate
    }
    
    func setFrameDuration(connection: AVCaptureConnection!,
                          _ times: CMTime) {
        if (connection?.isVideoMinFrameDurationSupported)! {
            connection?.videoMinFrameDuration = times
        }
    }
    
}
