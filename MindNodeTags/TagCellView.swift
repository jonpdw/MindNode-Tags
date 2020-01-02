//
//  TagCellView.swift
//  MindNodeTags3
//
//  Created by Jonathan on 25/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

class TagCellView: NSTableCellView {
    
    @IBOutlet weak var tagName: NSTextField!
    @IBOutlet weak var checkbox: NSButton!
    @IBOutlet weak var highlightBox: NSBox!
    var uuid: String!
    
    @IBAction func checkboxClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkBoxClicked"), object: nil)
        
    }
    
//    override func performKeyEquivalent(with event: NSEvent) -> Bool {
//        // Which key events will my program handle i.e don't do whatever default action it might be bound to.
//        switch event.keyCode {
//        case 51: // Backsapce
//            return true
//        case 49: // Space
//            return true
//        default:
//            return false
//        }
//    }
    
//    override func keyUp(with event: NSEvent) {
//        print("keyup")
//            let userInfo = ["event": event]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "keyEvent"), object: nil, userInfo:  userInfo)
//        
//    }
}
