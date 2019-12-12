//
//  outlineView.swift
//  MindNode Tags
//
//  Created by Jonathan on 13/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

class NSOutlineView1 : NSOutlineView {
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if (event.keyCode == 51){
            return true
        } else {
            return false
        }
    }
    
}
