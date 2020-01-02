//
//  MindNodeContent.swift
//  MindNode Tag
//
//  Created by Jonathan on 21/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

struct MindNode2ContentStruct:  Codable {
    var NSPrintInfo: NSPrintInfoStruct
    var mindMap: mindMapStruct
    var typeOptions: Int
    var version: Int
    var tags: [TagStruct]?
}

struct mindMapStruct: Codable {
    var color: String
    var crossConnections: [crossConnectionsStruct]?
    var mainNodes: [nodeStruct]
}


func TwoThingsEqual(thing1: nodeStruct, thing2: nodeStruct) -> Bool {
    
    if thing1.title.text != thing2.title.text {
        return false
    }
    if thing1.subnodes.count != thing2.subnodes.count {
        return false
    }
    if thing1.willShowInFilter != thing2.willShowInFilter {
        return false
    }
    if thing1.subnodes.count == 0 {
        return true
    }
    for subnodeIndex in 0..<thing1.subnodes.count {
        if TwoThingsEqual(thing1: thing1.subnodes[subnodeIndex], thing2: thing2.subnodes[subnodeIndex]) == false {
            return false
        }
    }
    return true
    
}

extension nodeStruct: Equatable {

    static func == (lhs: nodeStruct, rhs: nodeStruct) -> Bool {
        return TwoThingsEqual(thing1: lhs, thing2: rhs)
    }
    
}

let mborderStrokeStyleStruct = strokeStyleStruct(color: "blank", dash: 0, width: 0)
let mshapeStyleStruct = shapeStyleStruct(borderStrokeStyle: mborderStrokeStyleStruct, fillColor: "", shapeType: 0)
let mstrokeStyleStruct = strokeStyleStruct(color: "blank", dash: 0, width: 0)
let mpathStyleStruct = pathStyleStruct(pathType: 0, strokeStyle: mstrokeStyleStruct)
let mtitleStruct = titleStruct(fontStyle: nil, maxWidth: 0, allowToShrinkWidth: true, text: "<p style=\'color: rgba(65, 82, 41, 1.000000); font: 18px \"Helvetica Neue\"; text-align: center; -cocoa-font-postscriptname: \"HelveticaNeue-Medium\"; \'>Blank</p>")
let mattachmentStruct = attachmentStruct(clipArtName: nil, fileName: "", size: "", tinted: nil, type: 0)

let blankNodeStruct = nodeStruct(decreasingStrokeWidth: nil, layoutStyle: nil, hasFoldedSubnodes: false, isLeftAligned: nil, location: "nil", nodeID: "blank_row_id", pathStyle: mpathStyleStruct, shapeStyle: mshapeStyleStruct, subnodes: [], title: mtitleStruct, willShowInFilter: true, attachment: mattachmentStruct)
