//
//  Document.swift
//  document based appliation
//
//  Created by Jonathan on 22/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa


class NSWindowController1: NSWindowController {
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return ""
    }
}

class Document: NSDocument {
    
    var structOfMindNodeFile: MindNodeContentStruct!
    var structOfMindNode6File: MindNode6ContentStruct!
    var loadedVersion: loadedVersionNumber!
    var historyBeforeWrite: Int = -1
    
    enum loadedVersionNumber {
        case five
        case six
    }

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return false
    }


    
    override func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        Swift.print("restoreWindow called")
        NSApplication.shared.terminate(self)
//        Swift.print("test")

    }

    
    override func makeWindowControllers() {
        var storyboard: NSStoryboard
        if loadedVersion == .five {
             storyboard = NSStoryboard(name: NSStoryboard.Name("Main2"), bundle: nil)
        }
        else {
             storyboard = NSStoryboard(name: NSStoryboard.Name("Main6"), bundle: nil)
        }
        
        
//        self.addWindowController(NSWindowController1())
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
    

    override func write(to url: URL, ofType typeName: String) throws {
        switch loadedVersion {
        case .five:
            write5(url: url)
        case .six:
            write6(url: url)
        case .none:
            fatalError("NSDocument: Write: Switch Case ")
        }
    }
    
    func write5(url: URL) {
        historyBeforeWrite = structOfMindNodeFile.history1?.count ?? -1
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        do {
            let encodedMindNodeStruct = try encoder.encode(structOfMindNodeFile)
            try encodedMindNodeStruct.write(to: url)
        } catch {
            Swift.print("Write error")
        }
        
    }
    
    func write6(url: URL) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        do {
            let encodedMindNodeStruct = try encoder.encode(structOfMindNode6File)
            try encodedMindNodeStruct.write(to: url)
        } catch {
            Swift.print("Write error")
        }
    }
    
    
    override func read(from url: URL, ofType typeName: String) throws {
        read5(url: url)
        read6(url: url)
        #warning("Its probably inifficient to read both once I have done it once")
        
        if loadedVersion == nil {fatalError("NSDocument Read: Neither mindNode5 or mindNode6 structs loaded")}
        
    }
    
    func read5(url: URL) {
        if  let dataObject          = try? Data(contentsOf: url),
            let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(MindNodeContentStruct.self, from: dataObject)
        {
//            Swift.print("read5 worked")
            loadedVersion = .five
            structOfMindNodeFile = DecodedStructVersionOfData
            
        } else {
//            Swift.print("Read5 Problem")
        }
    }
    
    func read6(url: URL) {
        if  let dataObject          = try? Data(contentsOf: url),
            let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(MindNode6ContentStruct.self, from: dataObject)
        {
            loadedVersion = .six
            structOfMindNode6File = DecodedStructVersionOfData
            
        } else {
//            Swift.print("Read Problem")
        }
    }

    
    
}

