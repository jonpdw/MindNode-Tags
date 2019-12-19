//
//  MindMapClasses.swift
//  MindNodeTags
//
//  Created by Jonathan on 29/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import SwiftSoup

func mergeUnfilteredWithFilteredWithoutReset(unfiltered: nodeStruct, filtered: nodeStruct, parentID: String?) -> [nodeStruct] {
    var unfiltered = unfiltered

    // any childless node in 'unfiltered' can be replaced with its equivilent from 'filtered'. I could have added some children to the filtered version
    if (unfiltered.willShowInFilter == true) && (unfiltered.subnodes.count == 0) {
        let (filteredEquivOfUnfilteredNode, parent) = findNodeByID(nodeIDToFind: unfiltered.nodeID, subnode: filtered)
        // if parents don't match then the node has been dragged to a new spot. Treat it like it has been deleted
        let doParentsMatch: Bool
        if parent == nil || parentID == nil {
            #warning("I am not sure if I have the logic quite right here. What should happen if the parent or parentID are nill. Is giving a false really the right thing to do")
            doParentsMatch = false
            
        } else {
            doParentsMatch = (parent!.nodeID == parentID!)
        }
        if (filteredEquivOfUnfilteredNode == nil) || (doParentsMatch == false) {
            // the node has been deleted
            return []
        } else {
            return [filteredEquivOfUnfilteredNode!]
        }
    }
    var merged: [nodeStruct] = []
    for unfilteredNode in unfiltered.subnodes {
        
        // if not tagged then just plop strait here (it couldn't have been changed)
        if unfilteredNode.willShowInFilter == nil {
            merged += [unfilteredNode]
        }
        else {
            
            
            merged += mergeUnfilteredWithFilteredWithoutReset(unfiltered: unfilteredNode, filtered: filtered, parentID: unfiltered.nodeID)
        }
    }
    // add newly added branches
    if (unfiltered.willShowInFilter == true) {
        let (filteredNodes, _) = findNodeByID(nodeIDToFind: unfiltered.nodeID, subnode: filtered)
        if filteredNodes == nil {
            return []
        }
        let filteredNodesSubnodes = filteredNodes!.subnodes
        // returning nil is for the situation that unfiltered contains a references to node that has now been deleted and is now looking for it in filtered (which contains the up to date version with the node delted) in this case that node will not contain any new branches and thus we can just ignore it
        for node in filteredNodesSubnodes {
            if !merged.contains(where: {$0.nodeID == node.nodeID}) {
                merged += [node]
            }
        }
    }
    
    unfiltered.subnodes = merged
    return [unfiltered]
    
}







func mergeUnfilteredWithFiltered(unfiltered: [nodeStruct], filtered: [nodeStruct]) -> [nodeStruct] {
    var mUnfiltered = blankNodeStruct
    mUnfiltered.subnodes = unfiltered

    var mFiltered = blankNodeStruct
    mFiltered.subnodes = filtered
    
    let output = mergeUnfilteredWithFilteredWithoutReset(unfiltered: mUnfiltered, filtered: mFiltered, parentID: nil)[0].subnodes
    return output.map({resetWillShowInFilterToNil($0)})
}

func markWillShowInFilter(node: nodeStruct, taglist: [String], markAllChildren: Bool) -> [nodeStruct] {
    var node = node
    var markAllChildren = markAllChildren
    
    // case 1: its a root node
    if node.subnodes.count == 0 {
        if doesNodeContainTagsFromTagList(node: node, taglist: taglist) || markAllChildren {
            node.willShowInFilter = true
        }
        return [node]
    }
    // case 2: its a parent node
    var returnBit: [nodeStruct] = []
    for subnode in node.subnodes {
        if doesNodeContainTagsFromTagList(node: node, taglist: taglist) {markAllChildren = true}
        returnBit += markWillShowInFilter(node: subnode, taglist: taglist, markAllChildren: markAllChildren)
    }
    
    let childrenThatWillShowInFilter = returnBit.filter {$0.willShowInFilter == true}
    if (childrenThatWillShowInFilter.count > 0) || markAllChildren {
        node.willShowInFilter = true
    }
    node.subnodes = returnBit
    return [node]
}
func markWillShowInFilterList(nodeList: [nodeStruct], taglist: [String], markAllChildren: Bool) -> [nodeStruct] {
    return nodeList.map {markWillShowInFilter(node: $0, taglist: taglist, markAllChildren: markAllChildren)[0]}
}


func resetWillShowInFilterToNil(_ subnode: nodeStruct) -> nodeStruct {
    var subnode = subnode
    subnode.willShowInFilter = nil
    if subnode.subnodes.count == 0 {
        return subnode
    }
    var returnNodes: [nodeStruct] = []
    for node in subnode.subnodes {
        returnNodes += [resetWillShowInFilterToNil(node)]
    }
    
    subnode.subnodes = returnNodes
    return subnode
    
}

func findNodeByID(nodeIDToFind: String, subnode: nodeStruct) -> (node: nodeStruct?, parent: nodeStruct?) {
    if subnode.nodeID == nodeIDToFind { return (subnode, nil)}
    for node in subnode.subnodes {
        if node.nodeID == nodeIDToFind { return (node, subnode) }
        let found = findNodeByID(nodeIDToFind: nodeIDToFind, subnode: node)
        if found.node != nil {
            return found
        }
    }
    return (nil,nil)
}

func getListOfTagsFromNode(subnode: nodeStruct) -> [Tag] {
    var listOfTags: [Tag] = []
    if subnode.subnodes.count == 0 {
        return getTagsFromMindNodeTextString(fullTitle: subnode.title.text) ?? []
    }
    
    for node in subnode.subnodes {
        listOfTags += getListOfTagsFromNode(subnode: node)
    }
    listOfTags += getTagsFromMindNodeTextString(fullTitle: subnode.title.text) ?? []
    
    return listOfTags
}

func getListOfTagsFromListOfNodes(nodeList: [nodeStruct]) -> [Tag] {
    return nodeList.flatMap {getListOfTagsFromNode(subnode: $0)}
}

func doesNodeContainTagsFromTagList(node: nodeStruct ,taglist: [String]) -> Bool {
    let nodeString = node.title.text
    let currentNodeTags = getTagsFromMindNodeTextString(fullTitle: nodeString)!
    let currentTagString = currentNodeTags.map {$0.tagName}
    let intersection = Set(currentTagString).intersection(Set(taglist))
    if (intersection.count > 0) {
        return true
    } else {
        return false
    }
}

func filterNodeByTag(subnode: nodeStruct, tagsToFilterBy: [String]) -> [nodeStruct] {
    var subnode = subnode
    
    if (subnode.subnodes.count == 0)  {
        
        let containsTag = doesNodeContainTagsFromTagList(node: subnode, taglist: tagsToFilterBy)
        
        if containsTag {
            return [subnode]
        } else {
            return [nodeStruct]()
        }
    }
    
    var listOfReturningSubNodes: [nodeStruct] = []
    
    for node in subnode.subnodes {
        if doesNodeContainTagsFromTagList(node: node, taglist: tagsToFilterBy) {
            listOfReturningSubNodes += [node]
        } else {
            listOfReturningSubNodes += filterNodeByTag(subnode: node, tagsToFilterBy: tagsToFilterBy)
        }
    }
    
    if (listOfReturningSubNodes.count == 0) && (!doesNodeContainTagsFromTagList(node: subnode, taglist: tagsToFilterBy)) {
        return [nodeStruct]()
    } else {
        subnode.subnodes = listOfReturningSubNodes
        return [subnode]
    }
    
}

func filterNodeListByTag(subnodeList: [nodeStruct], tagsToFilterBy: [String]) -> [nodeStruct] {
    return subnodeList.flatMap {filterNodeByTag(subnode: $0, tagsToFilterBy: tagsToFilterBy)}
}

func getTagsFromMindNodeTextString(fullTitle: String) -> [Tag]? {
    if fullTitle == "" {
        let ts: [Tag] = []
        return ts
    } else {
        #warning("this is probably quite an inefficient function to call many times. Go back to a more efficient one")
        let doc: SwiftSoup.Document = try! SwiftSoup.parse(fullTitle)
        let justTitleBit = try! doc.body()!.text();
        let splitStr = justTitleBit.split(separator: " ")
        //    NSLog(String(splitStr[3]))
        var tags: [String] = []
        for i in splitStr {
            if String(i.prefix(1)) == "#" {
                tags.append(String(i))
            }
        }
        return tags.map {let t1 = Tag(); t1.tagName =  $0; return t1}
    }
    
}
