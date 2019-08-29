//
//  Level.swift
//  FitFlare
//
//  Created by David Lang on 8/24/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import SceneKit

struct LevelUtil {
    
    static var cameraSearchSequence:SCNAction = {
        let searchDown = SCNAction.rotateBy(x: -0.2, y: 0, z: 0, duration: 2)
        let searchWait = SCNAction.wait(duration: 1)
        let searchUp = searchDown.reversed()
        let cameraSearch = SCNAction.sequence([searchDown, searchWait, searchUp])
        let moveDown = SCNAction.move(to: Constants.Positions.initialCamera, duration: 3.5)
        let action = SCNAction.group([cameraSearch, moveDown])
        return action
    }()
    
    static var cameraLookAround:SCNAction = {
        let lookDown = SCNAction.rotateBy(x: -0.10, y: 0.01, z: -0.01, duration: 0.5)
        let lookDownWait = SCNAction.wait(duration: 1.4)
        let lookDownScan = SCNAction.rotateBy(x: 0, y: -0.01, z: -0.01, duration: 0.8)
        let lookDownScanBack = SCNAction.rotateBy(x: 0, y: 0.01, z: 0.01, duration: 1.9)
        let lookUp = SCNAction.rotateBy(x: 0.10, y: -0.01, z: 0.01, duration: 2.0)
        var action = SCNAction.sequence([lookDownWait, lookDown, lookDownWait, lookDownScan, lookDownScanBack, lookUp])
        action.timingMode = SCNActionTimingMode.easeInEaseOut
        return action
    }()
    
    static var cameraScanning:SCNAction = {
        let cameraRight = SCNAction.rotateBy(x: 0.09, y:  0.7, z: 0, duration: 2.8)
        let cameraWait = SCNAction.wait(duration: 0.7)
        let cameraLeft = SCNAction.rotateBy(x: -0.09, y: -0.7, z: 0, duration: 3.5)
        let cameraRight2 = SCNAction.rotateBy(x: -0.06, y:  -0.6, z: 0, duration: 2.8)
        let cameraLeft2 = SCNAction.rotateBy(x: 0.06, y: 0.6, z: 0, duration: 3.1)
        let cameraScanning = SCNAction.sequence([cameraWait, cameraWait, cameraWait, cameraWait, cameraRight,cameraWait, cameraWait, cameraLeft, cameraRight2, cameraWait, cameraWait, cameraLeft2])
        cameraScanning.timingMode = .easeInEaseOut
        return cameraScanning
    }()
    
}
