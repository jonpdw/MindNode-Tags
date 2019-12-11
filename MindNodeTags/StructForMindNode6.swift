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
}

//func TwoThingsEqual6(thing1: nodeStruct, thing2: nodeStruct) -> Bool {
//
//    if thing1.title.text != thing2.title.text {
//        return false
//    }
//    if thing1.subnodes.count != thing2.subnodes.count {
//        return false
//    }
//    if thing1.willShowInFilter != thing2.willShowInFilter {
//        return false
//    }
//    if thing1.subnodes.count == 0 {
//        return true
//    }
//    for subnodeIndex in 0..<thing1.subnodes.count {
//        if TwoThingsEqual6(thing1: thing1.subnodes[subnodeIndex], thing2: thing2.subnodes[subnodeIndex]) == false {
//            return false
//        }
//    }
//    return true
//
//}
//
//extension nodeStruct1: Equatable {
//
//    static func == (lhs: nodeStruct, rhs: nodeStruct) -> Bool {
//        return TwoThingsEqual6(thing1: lhs, thing2: rhs)
//    }
//
//}


//let mstrokeStyleStruct1 = strokeStyleStruct1(color: "blank", width: 0, dash: 0)
//let mpathStyleStruct1 = pathStyleStruct1(strokeStyle: mstrokeStyleStruct1)
//let mtitleStruct1 = titleStruct1(fontStyle: nil, maxWidth: 0, allowToShrinkWidth: false, text: "blank")
//let mborderstrokeStyleStruct11 = borderstrokeStyleStruct11(color: "", dash: 0, width: 0)
//let mshapeStyleStruct1 = shapeStyleStruct1(borderStrokeStyle: mborderstrokeStyleStruct11)
////let mnodeStruct1 = nodeStruct1(shapeStyle: mshapeStyleStruct1, nodeID: "", location: "", title: mtitleStruct1, subnodes: [], pathStyle: mpathStyleStruct1, hasFoldedSubnodes: false, willShowInFilter: true)
//let mmindMapsStruct = mindMapsStruct(branchType: 0, styleAdjustmentType: 0, mainNode: blankNodeStruct, branchWidthType: 0, layoutStyle: 0)
//let mcanvasStruct = canvasStruct(color: "", crossConnections: nil, mindMaps: [mmindMapsStruct])
//let mNSPrintInfoStruct1 = NSPrintInfoStruct1(NSHorizontallyCentered: false, NSFirstPage: 0, NSVerticalPagination: 0, NSHorizonalPagination: 0, NSLastPage: 0, NSOrientation: 0, NSVerticallyCentered: false, NSScalingFactor: 0, NSPrintAllPages: false)
//
//let mMindNode6ContentStruct = MindNode6ContentStruct(NSPrintInfo: mNSPrintInfoStruct1, canvas: mcanvasStruct, typeOptions: 0, version: 6, tags: nil)
