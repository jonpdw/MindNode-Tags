//
//  SaveImages.swift
//  MindNode Tags
//
//  Created by Jonathan on 20/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation

class SaveImages {
    
    var backupUrl: URL {
        let openUrl = getMindNodeOpenFileUrlMaster()!
        var temp =  openUrl.deletingLastPathComponent()
        temp.appendPathComponent(".\(openUrl.lastPathComponent).backup/.resources/")
        return temp
    }
    
    var url: URL {getMindNodeOpenFileUrlMaster()!.appendingPathComponent("resources/")}
    
    var images: [(data: Data, name: String)] = []
    
    func addNewImages() {
        let files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)
        let filesTuple = files.map {try! (data: Data(contentsOf: $0),name: try! $0.resourceValues(forKeys: [.nameKey]).name!)}
        #warning("replace this with a set or unique array or something.")
        for file in filesTuple {
            let isFileInImages = (images.filter {$0.name == file.name}.count) > 0
            if isFileInImages == false {
                images.append(file)
            }
        }
    }
    
    func saveImagesToBackup() {
        
        for image in images {
            let tempUrl = backupUrl.appendingPathComponent(image.name)
            let fileExists = (try? tempUrl.checkResourceIsReachable()) ?? false
            if fileExists == false {
                try! image.data.write(to: tempUrl)
            }
        }
    }
    
    func getImagesFromBackup() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: backupUrl, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles) else {
            // if try fails it is becuase the resources folder doesn't exist yet. Lets create it
            try! FileManager.default.createDirectory(at: backupUrl, withIntermediateDirectories: true)
            return
        }
        
        let filesTuple = files.map {try! (data: Data(contentsOf: $0),name: try! $0.resourceValues(forKeys: [.nameKey]).name!)}
        #warning("replace this with a set or unique array or something.")
        for file in filesTuple {
            let isFileInImages = (images.filter {$0.name == file.name}.count) > 0
            if isFileInImages == false {
                images.append(file)
            }
        }
    }
    
    func saveImages() {
        for image in images {
            let tempUrl = url.appendingPathComponent(image.name)
            let fileExists = (try? tempUrl.checkResourceIsReachable()) ?? false
            if fileExists == false {
                try! image.data.write(to: tempUrl)
            }
        }
    }
}
