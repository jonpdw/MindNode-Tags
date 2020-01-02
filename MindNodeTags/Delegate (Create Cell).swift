//
//  Delegate (Create Cell).swift
//  MindNode Tags
//
//  Created by Jonathan on 20/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController: NSOutlineViewDelegate {
    
    // Make the view that is used in the outline
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let TagToCreateViewFrom = item as! Tag
        let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self)
            as! TagCellView
        
        newView.textField?.stringValue = "\(TagToCreateViewFrom.tagName)   (\(occurancesOfTag(tagInQuestion: TagToCreateViewFrom, tagList: getListOfTagsFromListOfNodes(nodeList: unfilteredDocumentListToFindTagsIn))))"
        
        //        cell.textField?.font = NSFont(name: "American Typewriter", size: CGFloat(Float(18)))
        newView.checkbox?.state = TagToCreateViewFrom.checkedState
        newView.uuid = TagToCreateViewFrom.uuid
        newView.highlightBox.isHidden = true
        return newView
    }
}
