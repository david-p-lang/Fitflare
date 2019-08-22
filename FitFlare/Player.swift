//
//  Player.swift
//  FitFlare
//
//  Created by David Lang on 8/21/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import Foundation
import SceneKit

class Player {
    
    var node:SCNNode!
    var torso:SCNNode!
    var rightLeg:SCNNode!
    var leftLeg:SCNNode!
    var head:SCNNode!
    var rightArm:SCNNode!
    var leftArm:SCNNode!
    var material:SCNMaterial!
    var light:SCNLight!
    
    init() {
        
        //declare geometries
        //todo - add dimensions to constants class
        let torsoGeometry = SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.15)
        let legGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.015)
        let armGeometry = SCNBox(width: 0.15, height: 0.15, length: 0.15, chamferRadius: 0.015)
        let headGeometry = SCNBox(width: 0.4, height: 0.4, length: 0.4, chamferRadius: 0.1)
        material = SCNMaterial()
        material.diffuse.contents = UIColor.cyan
        
        //add in material
        torsoGeometry.materials = [material]
        headGeometry.materials = [material]
        legGeometry.materials = [material]
        armGeometry.materials = [material]
        
        //build nodes
        torso = SCNNode(geometry: torsoGeometry)
        head = SCNNode(geometry: headGeometry)
        rightArm = SCNNode(geometry: armGeometry)
        leftArm = SCNNode(geometry: armGeometry)
        rightLeg = SCNNode(geometry: legGeometry)
        leftLeg = SCNNode(geometry: legGeometry)
        node = SCNNode()
        
        //add component nodes to player node
        node.addChildNode(torso)
        node.addChildNode(head)
        node.addChildNode(rightArm)
        node.addChildNode(leftArm)
        node.addChildNode(rightLeg)
        node.addChildNode(leftLeg)
        
        //set initial positions
        //todo add values to constants
        torso.position = SCNVector3(0, 1.3, 0)
        head.position = SCNVector3(0, 2.0, 0)
        rightArm.position = SCNVector3(0.55, 1.0, 0)
        leftArm.position = SCNVector3(-0.55, 1.0, 0)
        rightLeg.position = SCNVector3(0.4, 0.2, 0)
        leftLeg.position = SCNVector3(-0.4, 0.2, 0)
        
        //declare and add light
//        light = SCNLight()
//        light.type = SCNLight.LightType.ambient
//        light.intensity = 10
//        node.light = light
    }
}
