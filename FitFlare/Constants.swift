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
    }
}

struct CollisionCategory {
    static let player: Int = 1
    static let block: Int = 2
    static let wall: Int = 1
    
}

enum CollisionTypes: Int {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}
