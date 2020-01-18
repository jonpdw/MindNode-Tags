//
//  TagsAddRemoveFunctions.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

class Tag: NSObject {
    
    var tagName = ""
    var checkedState = NSControl.StateValue.off
    var children: [Tag] = []
    var uuid: String = UUID().uuidString
    
}

class tagsClass{
    var list = [Tag]()
    
    var numberOfCheckedTagsBeforeClick = 0
    
    func flatList() -> [Tag] {
        return flattenTagList(list)
    }
    
    func totalTags() -> Int {
        return flatList().count
    }
    
    func filterCheckedOnFlat() -> [Tag] {
        
        flatList().filter {$0.checkedState == .on}
    }
    
    func removeItem(removeIndex: Int, parentOfItemToRemove: Tag?) {
        list = removeItemList(removeIndex: removeIndex, parentOfItemToRemove: parentOfItemToRemove, inputItems: list)
    }
    
    func insertItem(insertIndex: Int, parentOfItemToInsert: Tag?, insertItem: Tag) {
        list = insertItemList(insertIndex: insertIndex, parentOfItemToInsert: parentOfItemToInsert, inputItems: list, insertItem: insertItem)
        
    }
    
    func findTagAlongWithParentAndIndex(itemsUUIDToFind: String, currentItem: Tag?) -> (Item: Tag, Parent: Tag?, Index: Int)? {
        return MindNode_Tags.findTagAlongWithParentAndIndex(itemsUUIDToFind: itemsUUIDToFind, tagList: list, currentItem: currentItem)
    }
    
    func replaceTagInTagList(replaceUUID: String, newCheckboxState: NSControl.StateValue) {
        list = MindNode_Tags.replaceTagInTagList(tagList: list, replaceUUID: replaceUUID, newCheckboxState: newCheckboxState)
    }
    

}

func removeItemSingle(removeIndex: Int, parentOfItemToRemove: Tag, inputItem: Tag) -> Tag {
    
    if inputItem.uuid == parentOfItemToRemove.uuid {
        inputItem.children.remove(at: removeIndex)
        return inputItem
    }
    
    if inputItem.children.count == 0 {
        return inputItem
    }
    
    var returnItems: [Tag] = []
    for child in inputItem.children {
        returnItems += [removeItemSingle(removeIndex: removeIndex, parentOfItemToRemove: parentOfItemToRemove, inputItem: child)]
    }
    
    inputItem.children = returnItems
    return inputItem
}

func removeItemList(removeIndex: Int, parentOfItemToRemove: Tag?, inputItems: [Tag]) -> [Tag] {
    if parentOfItemToRemove == nil {
        var outputItem = inputItems
        outputItem.remove(at: removeIndex)
        return outputItem
    } else {
        var returnItems: [Tag] = []
        for item in inputItems {
            returnItems += [removeItemSingle(removeIndex: removeIndex, parentOfItemToRemove: parentOfItemToRemove!, inputItem: item)]
        }
        return returnItems
    }
    
}

func insertItemSingle(insertIndex: Int, parentOfItemToInsert: Tag, inputItem: Tag, insertItem: Tag) -> Tag {
    
    if inputItem.uuid == parentOfItemToInsert.uuid {
        inputItem.children.insert(insertItem, at: insertIndex)
        return inputItem
    }
    
    if inputItem.children.count == 0 {
        return inputItem
    }
    
    var returnItems: [Tag] = []
    for child in inputItem.children {
        returnItems += [insertItemSingle(insertIndex: insertIndex, parentOfItemToInsert: parentOfItemToInsert, inputItem: child, insertItem: insertItem)]
    }
    
    inputItem.children = returnItems
    return inputItem
}

func insertItemList(insertIndex: Int, parentOfItemToInsert: Tag?, inputItems: [Tag], insertItem: Tag) -> [Tag] {
    if parentOfItemToInsert == nil {
        var outputItem = inputItems
        outputItem.insert(insertItem, at: insertIndex)
        return outputItem
    } else {
        var returnItems: [Tag] = []
        for item in inputItems {
            returnItems += [insertItemSingle(insertIndex: insertIndex, parentOfItemToInsert: parentOfItemToInsert!, inputItem: item, insertItem: insertItem)]
        }
        return returnItems
    }
    
}


func findTagAlongWithParentAndIndex(itemsUUIDToFind: String ,tagList children: [Tag], currentItem: Tag?) -> (Item: Tag, Parent: Tag?, Index: Int)? {
    for (index, child) in children.enumerated() {
        if (child.uuid == itemsUUIDToFind) {
            return (child, currentItem, index)
        }
        if let result = findTagAlongWithParentAndIndex(itemsUUIDToFind: itemsUUIDToFind, tagList: child.children, currentItem: child) {
            return result
        }
    }
    return nil
}


func flattenTagList(_ tagList: [Tag]) -> [Tag] {
    func flattenSingleTag(currentTag: Tag) -> [Tag] {
        if currentTag.children.count == 0 {
            return [currentTag]
        }
        
        var returnTags: [Tag] = []
        for tag in currentTag.children {
            returnTags += flattenSingleTag(currentTag: tag)
        }
        
        return ([currentTag] + returnTags )
    }
    
    return tagList.flatMap({flattenSingleTag(currentTag: $0)})
}

func occurancesOfTag(tagInQuestion: Tag, tagList: [Tag]) -> Int {
    return (flattenTagList(tagList).filter {$0.tagName == tagInQuestion.tagName}).count
}

func replaceTagInTagList(tagList: [Tag], replaceUUID: String, newCheckboxState: NSControl.StateValue) -> [Tag] {
    
    func replaceTagInTag(currentTag: Tag, replaceUUID: String, newCheckboxState: NSControl.StateValue) -> Tag {
        if currentTag.uuid == replaceUUID {
            currentTag.checkedState = newCheckboxState
        }
        
        if currentTag.children.count == 0 {
            return currentTag
        }
        
        var returnTags: [Tag] = []
        for tag in currentTag.children {
            returnTags += [replaceTagInTag(currentTag: tag, replaceUUID: replaceUUID, newCheckboxState: newCheckboxState)]
        }
        currentTag.children = returnTags
        return currentTag
    }
    
    return tagList.map({replaceTagInTag(currentTag: $0, replaceUUID: replaceUUID, newCheckboxState: newCheckboxState)})
}


