//
//  NSView.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa

extension NSView {
    
    func updateFrameSize(for frame: NSRect) {
        self.setFrameSize(NSMakeSize(frame.width,
                                     frame.height))
    }
    
}
