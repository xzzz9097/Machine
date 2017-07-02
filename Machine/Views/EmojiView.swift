//
//  EmojiView.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Cocoa

class EmojiView: NSTextField {

    override init(frame: NSRect) {
        super.init(frame: frame)
        
        configureEmojiView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureEmojiView()
    }
    
    func configureEmojiView() {
        self.stringValue     = "😀"
        self.isEditable      = false
        self.drawsBackground = false
        self.isBezeled       = false
        self.alignment       = .center
    }
    
}
