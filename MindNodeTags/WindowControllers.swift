//
//  WindowController.swift
//  MindNodeTags
//
//  Created by Jonathan on 6/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//


import Cocoa

class Main2WindowController: NSWindowController {
    // Main2 uses a skinny toolbar that already hides the file name
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.toolbar!.showsBaselineSeparator = false
    }
    
}

class Main6WindowController: NSWindowController {
    // Main6 has a fat toolbar but I want to hide the file name
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return ""
    }
}
