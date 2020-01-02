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

struct MindNodeContentStruct6:  Codable {
    var NSPrintInfo: NSPrintInfoStruct
    var canvas: canvasStruct6
    var typeOptions: Int
    var version: Int
    var tags: [TagStruct]?
}

struct canvasStruct6: Codable {
    var color: String
    var crossConnections: [crossConnectionsStruct6]?
    var mindMaps: [mindMapsStruct6]
}

struct mindMapsStruct6: Codable {
    var branchType: Int
    var styleAdjustmentType: Int
    var mainNode: nodeStruct
    var branchWidthType: Int
    var layoutStyle: Int
}

struct crossConnectionsStruct6: Codable {
    var title: titleStruct
    var arrowStyle: arrowStyleStruc
    var pathStyle: pathStyleStruct
    
    var connectionID: String
    
    var endPoints: endPointsStruct6
    var layout: layoutStruct6
}

struct endPointsStruct6: Codable {
    var startNodeID: String
    var endNodeID: String
}

struct wayPointsStruct6: Codable {
    var wayPointOffset: String
}

struct layoutStruct6: Codable {
    var wayPoints: [wayPointsStruct6]
}

extension mindMapsStruct6: Hashable {
    static func == (lhs: mindMapsStruct6, rhs: mindMapsStruct6) -> Bool {
        return lhs.mainNode.nodeID == rhs.mainNode.nodeID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(mainNode.nodeID)
    }
}
