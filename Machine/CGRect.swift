//
//  CGRect.swift
//  Machine
//
//  Created by lyrae on 28/06/2017.
//  Copyright © 2017 lyrae. All rights reserved.
//

import Foundation

extension CGRect {
    
    func scaled(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: self.minX * width,
                      y: self.minY * height,
                      width: self.width * width,
                      height: self.height * height)
    }
    
}

