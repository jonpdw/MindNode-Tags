//
//  MindNodeContent.swift
//  MindNode Tag
//
//  Created by Jonathan on 21/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation

import Cocoa

struct NSPrintInfoStruct: Codable {
    var NSFirstPage: Int
    var NSHorizonalPagination: Int
    var NSHorizontallyCentered: Bool
    var NSLastPage: Int
    var NSOrientation: Int
    var NSPrintAllPages: Bool
    var NSScalingFactor: Int
    var NSVerticalPagination: Int
    var NSVerticallyCentered: Bool
}

struct strokeStyleStruct: Codable {
    var color: String
    var dash: Int
    var width: Int
}

struct pathStyleStruct: Codable {
    var pathType: Int
    var strokeStyle: strokeStyleStruct
}

struct borderStrokeStyleStruct: Codable {
    var color: String
    var dash: Int
    var width: Int
}

struct shapeStyleStruct: Codable {
    var borderStrokeStyle: borderStrokeStyleStruct
}

struct fontStyleStruct: Codable {
    var alignment: Int
    var bold: Bool
    var color: String
    var fontName: String
    var fontSize: Int
    var italic: Bool
    var strikethrough: Bool
    var underline: Bool
}

struct titleStruct: Codable {
    var allowToShrinkWidth: Bool
    var fontStyle: fontStyleStruct?
    var maxWidth: Int
    var text: String
    
}

struct nodeStruct: Codable {
    var decreasingStrokeWidth: Bool?
    var layoutStyle: Int?
    
    var hasFoldedSubnodes: Bool
    var isLeftAligned: Bool?
    var location: String
    var nodeID: String
    var pathStyle: pathStyleStruct
    var shapeStyle: shapeStyleStruct
    var subnodes: [nodeStruct]
    var title: titleStruct
    
    var willShowInFilter: Bool?
}


struct arrowStyleStruc: Codable {
    var endArrow: Int
    var startArrow: Int
}

struct crossConnectionsStruct: Codable {
    var arrowStyle: arrowStyleStruc
    var endNodeID: String
    var pathStyle: pathStyleStruct
    var startNodeID: String
    var title: titleStruct
    var wayPointOffset: String
}

struct mindMapStruct: Codable {
    var color: String
    var crossConnections: [crossConnectionsStruct]?
    var mainNodes: [nodeStruct]
}

struct MindNodeContentStruct:  Codable {
    var NSPrintInfo: NSPrintInfoStruct
    var mindMap: mindMapStruct
    var typeOptions: Int
    var version: Int
    var tags: [TagStruct]?
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

let mborderStrokeStyleStruct = borderStrokeStyleStruct(color: "blank", dash: 0, width: 0)
let mshapeStyleStruct = shapeStyleStruct(borderStrokeStyle: mborderStrokeStyleStruct)
let mstrokeStyleStruct = strokeStyleStruct(color: "blank", dash: 0, width: 0)
let mpathStyleStruct = pathStyleStruct(pathType: 0, strokeStyle: mstrokeStyleStruct)
let mtitleStruct = titleStruct(allowToShrinkWidth: false, fontStyle: nil, maxWidth: 0, text: "<p style=\'color: rgba(65, 82, 41, 1.000000); font: 18px \"Helvetica Neue\"; text-align: center; -cocoa-font-postscriptname: \"HelveticaNeue-Medium\"; \'>Blank</p>")

let blankNodeStruct = nodeStruct(decreasingStrokeWidth: nil, layoutStyle: nil, hasFoldedSubnodes: false, isLeftAligned: nil, location: "nil", nodeID: "blank_row_id", pathStyle: mpathStyleStruct, shapeStyle: mshapeStyleStruct, subnodes: [], title: mtitleStruct, willShowInFilter: true)
