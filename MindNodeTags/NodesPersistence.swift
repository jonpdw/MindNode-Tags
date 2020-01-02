//
//  History.swift
//  MindNode Tags
//
//  Created by Jonathan on 13/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa


class BackupNodeList {
    
    var indexOfCurrentBackup = 0
    
    var url: URL {
        let openUrl = getMindNodeOpenFileUrlMaster()!
        return openUrl.deletingLastPathComponent().appendingPathComponent(".\(openUrl.lastPathComponent).backup")
    }
    
    var numberFiles: Int {
        try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).count
    }
    
    
    init() {
        // create folder
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }
    
    func add(content: [nodeStruct], mindmapsForStruct61: Set<mindMapsStruct6>!) {
        
        let urlForNewFile = url.appendingPathComponent("Backup \(String(describing: numberFiles+1) ).plist")
        
        var arrayToWrite: [mindMapsStruct6]?
        if mindmapsForStruct61 == nil {
            arrayToWrite = nil
        } else {
            arrayToWrite = Array(mindmapsForStruct61)
        }
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            let encodedMindNodeStruct = try encoder.encode(nodeStructList(nodeStructVar: content, mindMapsForStruct6: arrayToWrite))
            try encodedMindNodeStruct.write(to: urlForNewFile)
        } catch {
            Swift.print("Write error")
        }
    }
    
    
    
    func get(index: Int) -> ( mindMap6Struct: Set<mindMapsStruct6>?, nodeStruct: [nodeStruct])?  {
        // get url
        let allBackupFileURLS = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        
        let sortedURLs = allBackupFileURLS.sorted {$0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == ComparisonResult.orderedDescending}
        
        guard let chosenUrl = sortedURLs.getElement(at: index) else {
            return nil
        }
        
        // read file
        let dataObject                  = try? Data(contentsOf: chosenUrl)
        let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(nodeStructList.self, from: dataObject!)
        if DecodedStructVersionOfData!.mindMapsForStruct6 == nil {
             return (nil, DecodedStructVersionOfData!.nodeStructVar)
        } else {
            return (Set(DecodedStructVersionOfData!.mindMapsForStruct6!), DecodedStructVersionOfData!.nodeStructVar)
        }
    }
    
}

// Safe way to get item at index and return nil if not there
extension Array {
    func getElement(at index: Int) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}


