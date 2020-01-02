//
//  SaveImages.swift
//  MindNode Tags
//
//  Created by Jonathan on 20/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation

class SaveImages {
    
    var backupURL: URL {
        let openUrl = getMindNodeOpenFileUrlMaster()!
        return openUrl.deletingLastPathComponent().appendingPathComponent(".\(openUrl.lastPathComponent).backup/.resources/")

    }
    
    
    
    var actualResourceFolderURL: URL {getMindNodeOpenFileUrlMaster()!.appendingPathComponent("resources/")}
    
    var images: [(data: Data, name: String)] = []
    
    init() {
        try? FileManager.default.createDirectory(at: backupURL, withIntermediateDirectories: true)
    }
    
    func addNewImagesMemoryStorage() {
        let currentFileURLsInResourceFolder = try! FileManager.default.contentsOfDirectory(at: actualResourceFolderURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)
        let currentFilesTupleWithName = currentFileURLsInResourceFolder.map {try! (data: Data(contentsOf: $0),name: try! $0.resourceValues(forKeys: [.nameKey]).name!)}
        for file in currentFilesTupleWithName {
            let isFileInImages = images.contains {$0.name == file.name}
            if isFileInImages == false {
                images.append(file)
            }
        }
    }
    
    func saveImagesToBackupFolder() {
        for image in images {
            let URLforNewFile = backupURL.appendingPathComponent(image.name)
            let fileExists = (try? URLforNewFile.checkResourceIsReachable()) ?? false
            if fileExists == false {
                try! image.data.write(to: URLforNewFile)
            }
        }
    }
    
    func getImagesFromBackup() {
        let fileURLsInBackup = try! FileManager.default.contentsOfDirectory(at: backupURL, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)
        
        let filesTuple = fileURLsInBackup.map {try! (data: Data(contentsOf: $0),name: try! $0.resourceValues(forKeys: [.nameKey]).name!)}
        for file in filesTuple {
            let isFileInImages = images.contains {$0.name == file.name}
            if isFileInImages == false {
                images.append(file)
            }
        }
    }
    
    func saveImagesToResourceFolder() {
        for image in images {
            let tempUrl = actualResourceFolderURL.appendingPathComponent(image.name)
            let fileExists = (try? tempUrl.checkResourceIsReachable()) ?? false
            if fileExists == false {
                try! image.data.write(to: tempUrl)
            }
        }
    }
    
    func loadAndSaveEverything() {
        // get new images
        self.addNewImagesMemoryStorage()
        // save all images to backup
        self.saveImagesToBackupFolder()
        // add images that might have been deleted back to memory
        self.saveImagesToResourceFolder()
    }
}
