//
//  DebugTool.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

func getNodeText(fullTitle: String) -> String {
    let firstIndex = fullTitle.firstIndex(of: ">")!
    let firstIndexPlusOne = fullTitle.index(after:firstIndex)
    let lastIndex = fullTitle.lastIndex(of: "<")!
    let justTitleBit = fullTitle[firstIndexPlusOne..<lastIndex]
    return String(justTitleBit)
}

struct simpleNodeStruct {
    
    var title: String
    var nodeID: String
    var children: [simpleNodeStruct]?
    var childrenTitles: String
    
    init(title: String, nodeID: String,children: [simpleNodeStruct]?) {
        self.title = title
        self.nodeID = nodeID
        self.children = children
        self.childrenTitles = (children?.map {$0.title})?.joined(separator:" ") ?? "None"
    }
    
    func getChildren() -> String {
        guard children != nil else {return ""}
        var returnString = ""
        for child in children! {
            returnString += " \(child.title) "
        }
        return returnString
    }
}

func simple(_ subnode: nodeStruct) -> simpleNodeStruct {
    if subnode.subnodes.count == 0 {
        return simpleNodeStruct(title: getNodeText(fullTitle: subnode.title.text),nodeID: subnode.nodeID, children: nil)
    }
    
    var returnNodes: [simpleNodeStruct] = []
    for node in subnode.subnodes {
        returnNodes += [simple(node)]
    }
    
    return simpleNodeStruct(title: getNodeText(fullTitle: subnode.title.text),nodeID: subnode.nodeID, children: returnNodes)
}

func simple(_ nodeList: [nodeStruct]) -> [simpleNodeStruct] {
    return nodeList.map {simple($0)}
}
