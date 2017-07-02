//
//  NSTextField.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa

extension NSTextField {
    
    func updateTextSize(for frame: NSRect, textScale: CGFloat) {
        self.font = NSFont.systemFont(ofSize: min(frame.width,
                                                  frame.height) * textScale)
    }
    
    func update(for frame: NSRect, textScale: CGFloat) {
        self.updateFrameSize(for: frame)
        self.updateTextSize(for: frame, textScale: textScale)
    }
    
}
