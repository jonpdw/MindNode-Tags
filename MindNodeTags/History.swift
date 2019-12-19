//
//  History.swift
//  MindNode Tags
//
//  Created by Jonathan on 13/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa


class History {
    
      var url: URL {
        let openUrl = getMindNodeOpenFileUrlMaster()!
        var temp =  openUrl.deletingLastPathComponent()
        temp.appendPathComponent(".\(openUrl.lastPathComponent).backup")
        return temp
    }
    
    var numberFiles: Int {try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).count}
    
    init() {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }
    
    func add(content: [nodeStruct]) {
        
        let tmpURl = url.appendingPathComponent("Backup \(String(describing: numberFiles+1) ).plist")
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        do {
            let encodedMindNodeStruct = try encoder.encode(nodeStructList(nodeStructVar: content))
            try encodedMindNodeStruct.write(to: tmpURl)
        } catch {
            Swift.print("Write error")
        }
        
    }
    
    
    
    func get(index: Int) -> [nodeStruct]  {
        // get url
        let files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        
        let sortedURLs = files.sorted {$0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == ComparisonResult.orderedDescending}
        
        let chosenUrl = sortedURLs[index]
        
        // read file
        let dataObject                  = try? Data(contentsOf: chosenUrl)
        let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(nodeStructList.self, from: dataObject!)
        return DecodedStructVersionOfData!.nodeStructVar
    }
    
}



