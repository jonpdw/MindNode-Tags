//
//  DocumentController.swift
//  MindNode Tags
//
//  Created by Jonathan on 20/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

class CustomNSDocumentController: NSDocumentController {
    
    // Stop restoring the old windows after a crash. I got this from stack exchange
    override class func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        let preventDocumentRestoration = true
        if preventDocumentRestoration {
            // you need to decide when this var is true
            print("inside myNSDocumentController")
            completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil))
        } else {
            super.restoreWindow(withIdentifier: identifier, state: state, completionHandler: completionHandler)
        }
    }
}
