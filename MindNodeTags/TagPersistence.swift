//
//  Tag.swift
//  document based appliation
//
//  Created by Jonathan on 24/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

class TagStruct: Codable {
    var tagName: String = ""
    var children: [TagStruct] = []
}

func writeTags(to urlToWrite: URL, tagList: [Tag]) {
    let tagList_StructForm = convertTagsToSavableForm(tagList: tagList)
    let parentTagForStorage = TagStruct()
    parentTagForStorage.children = tagList_StructForm
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml

    do {
        let encodedItem = try encoder.encode(parentTagForStorage)
        try encodedItem.write(to: urlToWrite)
    } catch {
        Swift.print("Write Tags error")
    }
}

func readTags(from urlToRead: URL) -> [Tag]? {
    if  let dataObject          = try? Data(contentsOf: urlToRead),
        let DecodedStructVersionOfData  = try? PropertyListDecoder().decode(TagStruct.self, from: dataObject)
    {
        return convertTagStructListToTagList(tagStructList: DecodedStructVersionOfData.children)
        
    } else {
        Swift.print("Read Tags Problem")
        return nil
    }
}


func convertTagStructToTag(tagStructItem: TagStruct) -> Tag {
    let returnTag = Tag()
    returnTag.tagName = tagStructItem.tagName
    returnTag.children = tagStructItem.children.map {convertTagStructToTag(tagStructItem: $0)}
    return returnTag
}

func convertTagStructListToTagList(tagStructList: [TagStruct]) -> [Tag] {
    return tagStructList.map {convertTagStructToTag(tagStructItem: $0)}
}

func convertTagToTagStruct(tagItem: Tag) -> TagStruct {
    let returnTagStruct = TagStruct()
    returnTagStruct.tagName = tagItem.tagName
    returnTagStruct.children = tagItem.children.map {convertTagToTagStruct(tagItem: $0)}
    return returnTagStruct
}

func convertTagsToSavableForm(tagList: [Tag]) -> [TagStruct] {
    return tagList.map {convertTagToTagStruct(tagItem: $0)}
}
