//
//  Constants.swift
//  FitFlare
//
//  Created by David Lang on 8/21/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

struct Constants {
    struct colors {
        static let blueSky = UIColor(displayP3Red: 0.0, green: 0.4, blue: 0.7, alpha: 0.3)
    }
    
    struct times {
        static let workoutTime = 35
    }
    
    struct Positions {
        static let initialCamera = SCNVector3(0, 5, 12)
        static let origin = SCNVector3(0,0,0)
        static let headOut = SCNVector3(0, 2.0, 0)
        static let torsoOut = SCNVector3(0, 1.3, 0)
        static let rightHandOut = SCNVector3(0.55, 1.0, 0)
        static let leftHandOut = SCNVector3(-0.55, 1.0, 0)
        static let rightFootOut = SCNVector3(0.4, 0.2, 0)
        static let leftFootOut = SCNVector3(-0.4, 0.2, 0)
    }
    
    struct Table {
        static let reuseId = "Cell"
    }
}

struct CollisionCategory {
    static let player: Int = 1
    static let block: Int = 2
    static let wall: Int = 1
    
}

//enum CollisionTypes: Int {
//    case player = 1
//    case wall = 2
//    case star = 4
//    case vortex = 8
//    case finish = 16
//}

enum GameMode {
  case workout
  case gameOn
  case paused
}

