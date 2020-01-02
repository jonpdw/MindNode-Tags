//
//  Document.swift
//  document based appliation
//
//  Created by Jonathan on 22/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    var structOfMindNode2File: MindNode2ContentStruct!
    var structOfMindNode6File: MindNodeContentStruct6!
    var loadedVersion: loadedVersionNumber!
    
    enum loadedVersionNumber {
        case two
        case six
    }
    
    override init() {
        super.init()
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        do {
            var encodedMindNodeStruct: Data!
            if loadedVersion == .six {
                encodedMindNodeStruct = try encoder.encode(structOfMindNode6File)
            }
            if loadedVersion == .two {
                encodedMindNodeStruct = try encoder.encode(structOfMindNode2File)
            }
            
            try encodedMindNodeStruct.write(to: url)
        } catch {
            Swift.print("Write error")
        }
    }
    
    
    override func read(from url: URL, ofType typeName: String) throws {
        let dataObject = try! Data(contentsOf: url)
        
        switch loadedVersion {
        case .two:
            structOfMindNode2File  = try? PropertyListDecoder().decode(MindNode2ContentStruct.self, from: dataObject)
        case .six:
            structOfMindNode6File  = try? PropertyListDecoder().decode(MindNodeContentStruct6.self, from: dataObject)
        case .none:
            structOfMindNode2File  = try? PropertyListDecoder().decode(MindNode2ContentStruct.self, from: dataObject)
            if structOfMindNode2File != nil {
                loadedVersion = .two
                return
            }
            
            structOfMindNode6File  = try? PropertyListDecoder().decode(MindNodeContentStruct6.self, from: dataObject)
            if structOfMindNode6File != nil {
                loadedVersion = .six
                return
            }
            Swift.print("Nothing read. This Shouldn't happen")
        }
    }
    
    override func makeWindowControllers() {
        var storyboard: NSStoryboard
        if loadedVersion == .two {
            storyboard = NSStoryboard(name: NSStoryboard.Name("Main2"), bundle: nil)
        }
        else {
            storyboard = NSStoryboard(name: NSStoryboard.Name("Main6"), bundle: nil)
        }
        
        
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        
        self.addWindowController(windowController)
        
        let window = self.windowForSheet
        window?.standardWindowButton(.documentIconButton)?.image = nil
        window?.standardWindowButton(.closeButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    override func presentedItemDidChange() {
        // this stops my app from asking if we want to revert to changes
        
        guard let currentDocumentURL = self.fileURL else {
            Swift.print("currentDocumentURL guard problem")
            return }
        do {
            try revert(toContentsOf: currentDocumentURL, ofType: "xml")}
        catch { Swift.print("Auto Revert Error")}
        
    }



    override class var autosavesInPlace: Bool {
        return false
    }


    override func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        Swift.print("restoreWindow called")
        NSApplication.shared.terminate(self)
//        Swift.print("test")

    }


    

    


        
    
}

