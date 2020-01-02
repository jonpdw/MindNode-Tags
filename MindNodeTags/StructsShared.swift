//
//  StructsShared.swift
//  MindNode Tags
//
//  Created by Jonathan on 22/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation


struct nodeStruct: Codable {
    var decreasingStrokeWidth: Bool?
    var layoutStyle: Int?
    
    var hasFoldedSubnodes: Bool
    var isLeftAligned: Bool?
    var location: String
    var nodeID: String
    var pathStyle: pathStyleStruct
    var shapeStyle: shapeStyleStruct?
    var subnodes: [nodeStruct]
    var title: titleStruct
    var willShowInFilter: Bool?
    var attachment: attachmentStruct?
    var note: noteStruct?
    var noteIndicatorColor: String?
    var fileLink: fileLinkStruct?
    var task: taskStruct?
}

struct nodeStructList: Codable {
    var nodeStructVar: [nodeStruct]
    var mindMapsForStruct6: [mindMapsStruct6]?
}

struct taskStruct: Codable {
    var state: Int
}

struct fileLinkStruct: Codable {
    var absoluteFilePath: String
    var bookmarkData: Data
    var relativeFilePath: String
}

struct noteStruct: Codable {
    var text: String
    var visibleOnCanvas: Bool
}

struct attachmentStruct: Codable {
    var clipArtName: String?
    var fileName: String
    var size: String
    var tinted: Bool?
    var type: Int
}

struct titleStruct: Codable {
    var fontStyle: fontStyleStruct?
    var maxWidth: Int
    var allowToShrinkWidth: Bool?
    var text: String
    
}

struct fontStyleStruct: Codable {
    var italic: Bool
    var fontSize: Int
    var color: String
    var strikethrough: Bool
    var fontName: String
    var alignment: Int
    var underline: Bool
    var bold: Bool
}

struct shapeStyleStruct: Codable {
    var borderStrokeStyle: strokeStyleStruct
    var fillColor: String?
    var shapeType: Int?
}


struct pathStyleStruct: Codable {
    var pathType: Int?
    var strokeStyle: strokeStyleStruct
}

struct strokeStyleStruct: Codable {
    var color: String
    var dash: Int
    var width: Int
}


struct crossConnectionsStruct: Codable {
    var title: titleStruct
    var arrowStyle: arrowStyleStruc
    var pathStyle: pathStyleStruct
    
    var startNodeID: String
    var endNodeID: String
    
    var wayPointOffset: String
}

struct arrowStyleStruc: Codable {
    var endArrow: Int
    var startArrow: Int
}

struct NSPrintInfoStruct: Codable {
    var NSHorizontallyCentered: Bool
    var NSVerticallyCentered: Bool
    
    var NSHorizonalPagination: Int
    var NSVerticalPagination: Int
    
    var NSFirstPage: Int
    var NSLastPage: Int
    
    var NSOrientation: Int
    var NSScalingFactor: Int
    var NSPrintAllPages: Bool
}
