//
//  DataSource (Drag Drop).swift
//  MindNode Tags
//
//  Created by Jonathan on 20/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController: NSOutlineViewDataSource {
    
    // -- Create Outline Methods
    
    // number of children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // nil means the root node
        if item == nil {
            return tags.list.count
        }
        let item = item as! Tag
        return item.children.count
    }
    
    // child of item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return tags.list[index]
        }
        let item = item as! Tag
        return item.children[index]
    }
    
    // is item expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // this means that I can can make a previously childless node into a child node
        return true
    }
    
    // should show triangle thing
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        let item = item as! Tag
        if item.children.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    //
    // -- Drag and Drop
    //
    
    // returns the bit that is stored in the pasteboard. We store a unique string made but UUID
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pasteBoardItem = NSPasteboardItem()
        let item = item as! Tag
        pasteBoardItem.setString(item.uuid, forType: itemPasteboardTypeForMyTagCells)
        return pasteBoardItem
    }
    
    // if a proposed drop location should be accepted
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        // make input variables more descriptive
        let proposedParentForDrag = item
        let proposedChildIndex = index
        
        // get stuff from pasteboard
        let pasteboardItem = info.draggingPasteboard.pasteboardItems?.first
        let UUIDfromPasteboard = pasteboardItem!.string(forType: itemPasteboardTypeForMyTagCells)!
        
        // find the actual tag that the pasteboard references
        let draggedItem = tags.findTagAlongWithParentAndIndex(itemsUUIDToFind: UUIDfromPasteboard, currentItem: nil)
        
        // we try make a think a parent of itself don't allow it
        if draggedItem?.Item.uuid == (proposedParentForDrag as? Tag)?.uuid {return []}
        
        let canDrag = proposedChildIndex >= 0
        switch canDrag {
        case true:
            return .move
        case false:
            return []
        }
    }
    
    // Handle user dropping item
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard
            let pasteboardItem = info.draggingPasteboard.pasteboardItems?.first,
            let UUIDfromPasteBoard = pasteboardItem.string(forType: itemPasteboardTypeForMyTagCells),
//            let draggedItem = findTagAlongWithParentAndIndex(itemsUUIDToFind: theString, tagList: tags.list, currentItem: nil)
            let draggedItemTuple = tags.findTagAlongWithParentAndIndex(itemsUUIDToFind: UUIDfromPasteBoard, currentItem: nil)
            else {return false}
        var proposedIndexInsideParent = index
        let proposedParent = (item as? Tag ?? nil)
        
        // if we are reordering a tag inside the same parent. And the new index is higher (i.e its lower in the list) then subtract 1 from new index because we are effectivly deleting a row as well.
        if (draggedItemTuple.Parent == proposedParent) && draggedItemTuple.Index < proposedIndexInsideParent {
            proposedIndexInsideParent = proposedIndexInsideParent - 1
        }
        
        outlineView.beginUpdates()
        
        // move the visuals
        outlineView.moveItem(at: draggedItemTuple.Index, inParent: draggedItemTuple.Parent, to: proposedIndexInsideParent, inParent: proposedParent)
        
        // keep my representation up to date
        tags.removeItem(removeIndex: draggedItemTuple.Index, parentOfItemToRemove: draggedItemTuple.Parent)
        tags.insertItem(insertIndex: proposedIndexInsideParent, parentOfItemToInsert: proposedParent, insertItem: draggedItemTuple.Item)
        
        outlineView.reloadItem(nil, reloadChildren: true)
        outlineView.expandItem(proposedParent)
        
        outlineView.endUpdates()
        
        tagsInStruct = convertTagsToSavableForm(tagList: self.tags.list)
        sendActionSaveNSDocument()
        
        return true
    }
    
}
