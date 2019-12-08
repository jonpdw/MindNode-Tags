//
//  TagsAddRemoveFunctions.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

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

func insertItemSingle(insertIndex: Int, parentOfItemToRemove: Tag, inputItem: Tag, insertItem: Tag) -> Tag {
    
    if inputItem.uuid == parentOfItemToRemove.uuid {
        inputItem.children.insert(insertItem, at: insertIndex)
        return inputItem
    }
    
    if inputItem.children.count == 0 {
        return inputItem
    }
    
    var returnItems: [Tag] = []
    for child in inputItem.children {
        returnItems += [insertItemSingle(insertIndex: insertIndex, parentOfItemToRemove: parentOfItemToRemove, inputItem: child, insertItem: insertItem)]
    }
    
    inputItem.children = returnItems
    return inputItem
}

func insertItemList(insertIndex: Int, parentOfItemToRemove: Tag?, inputItems: [Tag], insertItem: Tag) -> [Tag] {
    if parentOfItemToRemove == nil {
        var outputItem = inputItems
        outputItem.insert(insertItem, at: insertIndex)
        return outputItem
    } else {
        var returnItems: [Tag] = []
        for item in inputItems {
            returnItems += [insertItemSingle(insertIndex: insertIndex, parentOfItemToRemove: parentOfItemToRemove!, inputItem: item, insertItem: insertItem)]
        }
        return returnItems
    }
    
}


func getIndexParentChild(itemToFind: String ,children: [Tag], currentItem: Tag?) -> (Parent: Tag?, Index: Int, Item: Tag)? {
    for (index, child) in children.enumerated() {
        if (child.uuid == itemToFind) {
            return (currentItem, index, child)
        }
        if let result = getIndexParentChild(itemToFind: itemToFind, children: child.children, currentItem: child) {
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

func replaceTagInTagList(tagList: [Tag], replaceUUID: String, replaceCheckbox: NSControl.StateValue) -> [Tag] {
    
    func replaceTagInTag(currentTag: Tag, replaceUUID: String, replaceCheckbox: NSControl.StateValue) -> Tag {
        if currentTag.uuid == replaceUUID {
            currentTag.checkedState = replaceCheckbox
        }
        
        if currentTag.children.count == 0 {
            return currentTag
        }
        
        var returnTags: [Tag] = []
        for tag in currentTag.children {
            returnTags += [replaceTagInTag(currentTag: tag, replaceUUID: replaceUUID, replaceCheckbox: replaceCheckbox)]
        }
        currentTag.children = returnTags
        return currentTag
    }
    
    return tagList.map({replaceTagInTag(currentTag: $0, replaceUUID: replaceUUID, replaceCheckbox: replaceCheckbox)})
}


