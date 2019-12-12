//
//  StructForMindNode6.swift
//  MindNodeTags
//
//  Created by Jonathan on 9/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

//
//  MindNodeContent.swift
//  MindNode Tag
//
//  Created by Jonathan on 21/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation

import Cocoa

struct NSPrintInfoStruct1: Codable {
    var NSHorizontallyCentered: Bool
    var NSFirstPage: Int
    var NSVerticalPagination: Int
    var NSHorizonalPagination: Int
    var NSLastPage: Int
    var NSOrientation: Int
    var NSVerticallyCentered: Bool
    var NSScalingFactor: Int
    var NSPrintAllPages: Bool
}

struct strokeStyleStruct1: Codable {
    var color: String
    var width: Int
    var dash: Int
}

struct pathStyleStruct1: Codable {
    var strokeStyle: strokeStyleStruct1
}

struct borderstrokeStyleStruct11: Codable {
    var color: String
    var dash: Int
    var width: Int
}

struct shapeStyleStruct1: Codable {
    var borderStrokeStyle: borderstrokeStyleStruct11
}

struct fontStyleStruct1: Codable {
    var italic: Bool
    var fontSize: Int
    var color: String
    var strikethrough: Bool
    var fontName: String
    var alignment: Int
    var underline: Bool
    var bold: Bool
}

struct titleStruct1: Codable {
    var fontStyle: fontStyleStruct1?
    var maxWidth: Int
    var allowToShrinkWidth: Bool
    var text: String
    
}

//struct nodeStruct1: Codable {
//    var shapeStyle: shapeStyleStruct1
//    var nodeID: String
//    var location: String
//    var title: titleStruct1
//    var subnodes: [nodeStruct1]
//    var pathStyle: pathStyleStruct1
//    var hasFoldedSubnodes: Bool
//    var willShowInFilter: Bool?
//
//}

struct arrowStyleStruc1: Codable {
    var endArrow: Int
    var startArrow: Int
}

struct endPointsStruct1: Codable {
    var startNodeID: String
    var endNodeID: String
}

struct wayPointsStruct1: Codable {
    var wayPointOffset: String
}

struct layoutStruct1: Codable {
    var wayPoints: [wayPointsStruct1]
}

struct crossConnectionsStruct1: Codable {
    
    var connectionID: String
    var title: titleStruct1
    var arrowStyle: arrowStyleStruc1
    var endPoints: endPointsStruct1
    var pathStyle: pathStyleStruct1
    var layout: layoutStruct1
}

struct mindMapsStruct: Codable {
    var branchType: Int
    var styleAdjustmentType: Int
    var mainNode: nodeStruct
    var branchWidthType: Int
    var layoutStyle: Int
}

struct canvasStruct: Codable {
    var color: String
    var crossConnections: [crossConnectionsStruct1]?
    var mindMaps: [mindMapsStruct]
}

struct MindNode6ContentStruct:  Codable {
    var NSPrintInfo: NSPrintInfoStruct1
    var canvas: canvasStruct
    var typeOptions: Int
    var version: Int
    var tags: [TagStruct]?
    var history1: [nodeStructList]?
}

