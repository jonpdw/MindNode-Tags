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
    var structOfMindNode6File: MindNode6ContentStruct!
    var loadedVersion: loadedVersionNumber!
    
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
        write5(url: url)
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
        if loadedVersion == nil {fatalError("NSDocument Read: Neither mindNode5 or mindNode6 structs loaded")}
        
    }
    
    func read5(url: URL) {
        if  let dataObject          = try? Data(contentsOf: url),
            let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(MindNodeContentStruct.self, from: dataObject)
        {
            loadedVersion = .five
            structOfMindNodeFile = DecodedStructVersionOfData
            
        } else {
            Swift.print("Read Problem")
        }
    }
    
    func read6(url: URL) {
        if  let dataObject          = try? Data(contentsOf: url),
            let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(MindNode6ContentStruct.self, from: dataObject)
        {
            loadedVersion = .six
            structOfMindNode6File = DecodedStructVersionOfData
            
        } else {
            Swift.print("Read Problem")
        }
    }

    
    
}

