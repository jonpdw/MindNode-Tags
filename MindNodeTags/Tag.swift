//
//  Tag.swift
//  document based appliation
//
//  Created by Jonathan on 24/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

class Tag: NSObject {
    
    var tagName = ""
    var checkedState = NSControl.StateValue.off
    var children: [Tag] = []
    var uuid: String = UUID().uuidString
    
//    init(tagName: String) {
//        self.tagName = tagName
//    }

}

class TagStruct: Codable {
    var tagName: String = ""
    var children: [TagStruct] = []
    
}

func writeTags(to url: URL, tagList: [Tag]) {
    let tagStructList = convertTagListToTagStructList(tagList: tagList)
    let tempRoot = TagStruct()
    tempRoot.children = tagStructList
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml

    do {
        let encodedItem = try encoder.encode(tempRoot)
        try encodedItem.write(to: url)
    } catch {
        Swift.print("Write error")
    }
}

func readTags(from url: URL) -> [Tag]? {
    if  let dataObject          = try? Data(contentsOf: url),
        let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(TagStruct.self, from: dataObject)
    {
        return convertTagStructListToTagList(tagStructList: DecodedStructVersionOfData.children)
        
    } else {
        Swift.print("Read Problem")
        return nil
    }
}


func convertTagStructToTag(tagStructItem: TagStruct) -> Tag {
    
    if tagStructItem.children.count == 0 {
        let returnTag = Tag()
        returnTag.tagName = tagStructItem.tagName
        return returnTag
    }
    
    var returnChildren = [Tag]()
    for child in tagStructItem.children {
        returnChildren += [convertTagStructToTag(tagStructItem: child)]
    }
    
    let returnTag = Tag()
    returnTag.tagName = tagStructItem.tagName
    returnTag.children = returnChildren
    return returnTag
}

func convertTagStructListToTagList(tagStructList: [TagStruct]) -> [Tag] {
    return tagStructList.map {convertTagStructToTag(tagStructItem: $0)}
}

func convertTagToTagStruct(tagItem: Tag) -> TagStruct {
    
    if tagItem.children.count == 0 {
        let returnTagStruct = TagStruct()
        returnTagStruct.tagName = tagItem.tagName
        return returnTagStruct
    }
    
    var returnChildren = [TagStruct]()
    for child in tagItem.children {
        returnChildren += [convertTagToTagStruct(tagItem: child)]
    }
    let returnTagStruct = TagStruct()
    returnTagStruct.tagName = tagItem.tagName
    returnTagStruct.children = returnChildren
    return returnTagStruct
}

func convertTagListToTagStructList(tagList: [Tag]) -> [TagStruct] {
    return tagList.map {convertTagToTagStruct(tagItem: $0)}
}
