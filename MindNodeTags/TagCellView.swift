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
    var uuid: String!
    @IBOutlet weak var box: NSBox!
    
    @IBAction func checkboxClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkBoxClicked"), object: nil)
        
    }
    
}
