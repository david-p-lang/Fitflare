//
//  Player.swift
//  FitFlare
//
//  Created by David Lang on 8/21/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import Foundation
import SceneKit

class Player: SCNNode {
    
    var torso:SCNNode!
    var rightFoot:SCNNode!
    var leftFoot:SCNNode!
    var head:SCNNode!
    var rightHand:SCNNode!
    var leftHand:SCNNode!
    var material:SCNMaterial!
    var lightNode:SCNNode!
    
    let flyingOrientationConstraint:SCNTransformConstraint = {
        let constraint = SCNTransformConstraint.orientationConstraint(inWorldSpace: true) { (node, quaternion) -> SCNQuaternion in
            var constrainedQuaternion = quaternion
            constrainedQuaternion.x = -0.1
            constrainedQuaternion.y = 0
            constrainedQuaternion.z = 0
            return constrainedQuaternion
        }
        return constraint
    }()
    
    let xzConstraint:SCNTransformConstraint = {
        let constraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node, vector3) -> SCNVector3 in
            var constrainedVector = vector3
            constrainedVector.x = 0
            constrainedVector.z = 0
            return constrainedVector
        }
        return constraint
        
    }()
    
    let workoutConstraint:SCNTransformConstraint = {
        let constraint = SCNTransformConstraint.orientationConstraint(inWorldSpace: true) { (node, quaternion) -> SCNQuaternion in
            var constrainedQuaternion = quaternion
            constrainedQuaternion.x = 0
            constrainedQuaternion.z = 0
            constrainedQuaternion.y = 0
            return constrainedQuaternion
        }
        return constraint
    }()
    
    override init() {
        super.init()

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
        rightHand = SCNNode(geometry: armGeometry)
        leftHand = SCNNode(geometry: armGeometry)
        rightFoot = SCNNode(geometry: legGeometry)
        leftFoot = SCNNode(geometry: legGeometry)
        
        let playerLight = SCNLight()
        playerLight.intensity = 500
        playerLight.type = SCNLight.LightType.omni
        lightNode = SCNNode()
        lightNode.light = playerLight
    
        //add component nodes to player node
        self.addChildNode(torso)
        self.addChildNode(head)
        self.addChildNode(rightHand)
        self.addChildNode(leftHand)
        self.addChildNode(rightFoot)
        self.addChildNode(leftFoot)
        self.addChildNode(lightNode)
        
        //set initial positions
        //todo add values to constants struct
        torso.position = SCNVector3(0, 1.3, 0)
        head.position = SCNVector3(0, 2.0, 0)
        rightHand.position = SCNVector3(0.55, 1.0, 0)
        leftHand.position = SCNVector3(-0.55, 1.0, 0)
        rightFoot.position = SCNVector3(0.4, 0.2, 0)
        leftFoot.position = SCNVector3(-0.4, 0.2, 0)
        self.name = "player"
        
        
        
        //add physicsbody
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 50
        physicsBody.allowsResting = true
        physicsBody.isAffectedByGravity = true
        physicsBody.categoryBitMask = CollisionCategory.player
        physicsBody.contactTestBitMask =
            CollisionCategory.block
        physicsBody.collisionBitMask = CollisionCategory.wall | CollisionCategory.block
        self.physicsBody = physicsBody
        
        self.constraints = [xzConstraint, workoutConstraint]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func walkInPlace() {
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 1.5)
        let hoverDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 1.5)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let rotateAndHover = SCNAction.group([ hoverSequence])
        let repeatForever = SCNAction.repeatForever(rotateAndHover)
        //self.runAction(repeatForever)
        
        //foot movement
        let footUp = SCNAction.move(by: SCNVector3(0, 0.5, 0), duration: 0.2)
        let footDown = footUp.reversed()
        let footPause = SCNAction.wait(duration: 0.4)
        let rightFootMovement = SCNAction.sequence([footUp, footDown, footPause])
        rightFootMovement.timingMode = .linear
        let rightWalk = SCNAction.repeatForever(rightFootMovement)
        let leftFootMovement = SCNAction.sequence([footPause, footUp, footDown])
        leftFootMovement.timingMode = .linear
        let leftWalk = SCNAction.repeatForever(leftFootMovement)
        rightFoot.runAction(rightWalk)
        leftFoot.runAction(leftWalk)
        
        //hand movement
        let handUp = SCNAction.move(by: SCNVector3(0, 0.4, -0.2), duration: 0.2)
        let handDown = handUp.reversed()
        let handPause = SCNAction.wait(duration: 0.4)
        let rightHandMovement = SCNAction.sequence([handPause, handUp, handDown])
        rightHandMovement.timingMode = .linear
        let rightHandWalk = SCNAction.repeatForever(rightHandMovement)
        let leftHandMovement = SCNAction.sequence([handUp, handDown, handPause])
        leftHandMovement.timingMode = .linear
        let leftHandWalk = SCNAction.repeatForever(leftHandMovement)
        rightHand.runAction(rightHandWalk)
        leftHand.runAction(leftHandWalk)
        
    }
    
    
}
