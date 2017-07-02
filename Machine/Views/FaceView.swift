//
//  FaceView.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa

class FaceView: NSView {
    
    var hiddenFace = false {
        didSet {
            self.layer?.borderWidth = hiddenFace ? 0 : 1
        }
    }
    
    var emojiView: EmojiView!
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.wantsLayer         = true
        self.layer?.borderColor = NSColor.random.cgColor
        self.layer?.borderWidth = 1
    }
    
    convenience init(frame: NSRect, hiddenFace: Bool = false) {
        self.init(frame: frame)
        
        if hiddenFace {
            emojiView = EmojiView(frame: NSRect())
            
            self.addSubview(emojiView)
        }
        
        defer {
            self.hiddenFace = hiddenFace
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateFrame(to frame: NSRect) {
        self.animator().frame = frame
        
        if hiddenFace {
            emojiView.update(for: frame, textScale: 0.8)
        }
    }
    
}
