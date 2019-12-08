//
//  Document.swift
//  document based appliation
//
//  Created by Jonathan on 22/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    var structOfMindNodeFile: MindNodeContentStruct!

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }
    
    override func presentedItemDidChange() {
        // this stops my app from asking if we want to revert to changes
        guard let currentDocumentURL = self.fileURL else { return }
        do {
            try revert(toContentsOf: currentDocumentURL, ofType: "xml")}
        catch { Swift.print("Auto Revert Error")}

    }
    

    override func write(to url: URL, ofType typeName: String) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        do {
            let encodedMindNodeStruct = try encoder.encode(structOfMindNodeFile)
            try encodedMindNodeStruct.write(to: url)
        } catch {
            Swift.print("Write error")
        }
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        if  let dataObject          = try? Data(contentsOf: url),
            let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(MindNodeContentStruct.self, from: dataObject)
        {
            structOfMindNodeFile = DecodedStructVersionOfData
            
        } else {
            Swift.print("Read Problem")
        }
    }
    
    
}

