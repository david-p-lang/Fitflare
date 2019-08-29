//
//  PlayViewController.swift
//  FitFlare
//
//  Created by David Lang on 8/20/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation

class PlayViewController: UIViewController {
    
    let screenStack = UIStackView()
    
    let sceneView = SCNView()
    var cameraNode = SCNNode()
    let scene = SCNScene()
    
    let lightNode = SCNNode()
    let spotLight = SCNLight()
    
    var audioPlayer: AVAudioPlayer?
    let songName = "Darkdub"
    
    var floorGeometry:SCNFloor!
    var floorNode:SCNNode!
    
    var hudLabelNode:SKLabelNode!
    var hudNode:SCNNode!
    
    var alertLabelNode:SKLabelNode!
    var alertNode:SCNNode!
    
    let rect = CGRect(x: 0, y: 0, width: 1000, height: 500)
    
    var timer:Timer!
    var timerCount = Constants.times.workoutTime
    
    weak var contactDelegate: SCNPhysicsContactDelegate!
    var playerNode:Player!
    
    var blockSpawnTime:TimeInterval = 0
    
    var blocks:Set<BlockSetNode> = Set<BlockSetNode>()
    

    fileprivate func setupFloorGeometry() {
        floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0.02
        floorGeometry.length = 1000
        floorGeometry.width = 100
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreenStack()
        setupScene()
        sceneView.delegate = self
        sceneView.scene?.physicsWorld.contactDelegate = self

        setupCamera(cameraNode: cameraNode)

        playerNode = Player()
        playerNode.walkInPlace()
        sceneView.pause(self)
        
        playSound(name: songName)
        
        setupFloorGeometry()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.darkGray
        floorNode = SCNNode(geometry: floorGeometry)
        
        floorNode.position = SCNVector3(0, 0, 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody?.allowsResting = true
        floorNode.physicsBody?.damping = 0.1
        floorNode.physicsBody?.friction = 0.1
        floorNode.physicsBody?.categoryBitMask = CollisionCategory.wall
        //floorNode.physicsBody?.contactTestBitMask = CollisionCategory.player
        floorNode.physicsBody?.collisionBitMask = CollisionCategory.player

        
        
        setupLight(light: spotLight, node: lightNode, floorNode)
        scene.rootNode.addChildNode(playerNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(floorNode)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.showsStatistics = true
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.workoutTime), userInfo: nil, repeats: true)
        
        let hudPosition = SCNVector3( -16, 7, -25)
        let alertPosition = SCNVector3( 38, 7, -25)
        
        addHud(hudPosition)
        
        addAlert(alertPosition)
        
        let hudToRight = SCNAction.move(to: SCNVector3(25, 5, -18), duration: 0)
        let hudScrollLeft = SCNAction.move(by: SCNVector3(-34, 0, 0), duration: 1.5)
        let hudWait = SCNAction.wait(duration: 6)
        let call = SCNAction.run { (node) in
            self.timer.fire()
        }
        let hudScrollRight = hudScrollLeft.reversed()
        let hudSequence = SCNAction.sequence([hudScrollLeft, hudWait, hudScrollRight])
        hudSequence.timingMode = .easeInEaseOut
        alertNode.runAction(hudSequence)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .upArrow:
                //print("Up Arrow ", playerNode.presentation.position)
                if playerNode.presentation.position.y < 20 {
                    playerNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
                    playerNode.physicsBody?.applyForce(SCNVector3(0, 200, 0), asImpulse: true)
                }
            case .downArrow:
                print("Down arrow")
                playerNode.physicsBody?.applyForce(SCNVector3(0, 50, 0), asImpulse: true)
            case .leftArrow:
                print("Left arrow")
            case .rightArrow:
                print("Right arrow")
            case .select:
                print("Select")
            case .menu:
                print("Menu")
            default: break
            }
        }
    }

    
    @objc func workoutTime() {
        timerCount -= 1
        switch timerCount {
        case 35, 34, 33:
            hudLabelNode.text = "Walk"
            alertLabelNode.text = "Ready"
        case 32:
            alertLabelNode.text = "Set"
        case 31:
            alertLabelNode.text = "Go"
        default:
            hudLabelNode.text = "Walk \(timerCount)"
 
            if timerCount == 29 {
                timerCount = 35
                timer.invalidate()
                sceneView.play(self)
                print("start playing", sceneView.isPlaying)
                
                let cameraDistanceConstraint = SCNDistanceConstraint(target: playerNode)
                cameraDistanceConstraint.maximumDistance = 20
                cameraDistanceConstraint.minimumDistance = 10
                let replicatorConstraint = SCNReplicatorConstraint(target: playerNode)
                //replicatorConstraint.orientationOffset = SCNQuaternion(0.1, 0.9, 0.1, 0)
                replicatorConstraint.positionOffset = SCNVector3(6, 3, 8)
                let cameraLookPlayerConstraint = SCNLookAtConstraint(target: playerNode)
//                let avoiderConstraint = SCNAvoidOccluderConstraint(target: playerNode)
//                avoiderConstraint.occluderCategoryBitMask = CollisionCategory.block
                let forwardConstraint = SCNTransformConstraint.orientationConstraint(inWorldSpace: true) { (node, quaternion) -> SCNQuaternion in
                    var constrainedQuaternion = quaternion
                    //print("-", constrainedQuaternion)
                    constrainedQuaternion.x = 0.035
                    constrainedQuaternion.z = -0.015
                    constrainedQuaternion.y = 0.25
                    return constrainedQuaternion
                }
                cameraNode.constraints = [replicatorConstraint, SCNLookAtConstraint(target: playerNode), forwardConstraint]
                hudNode.removeFromParentNode()
                //floorNode.geometry?.materials[0].diffuse.contents = UIColor.clear
                
                playerNode.childNodes.forEach { (node) in
                    node.removeAllAnimations()
                    node.removeAllActions()
                }
                playerNode.removeAllAnimations()
                guard let particleSystem = SCNParticleSystem(named: "reactor.scnp", inDirectory: nil) else { return }
                playerNode.torso.addParticleSystem(particleSystem)
            }
        }
    }
    
    fileprivate func addHud(_ hudPosition: SCNVector3) {
        
        let hudComponents = buildHud(position: hudPosition)
        hudNode = hudComponents.0
        hudLabelNode = hudComponents.1
        cameraNode.addChildNode(hudNode)
    }
    
    fileprivate func addAlert(_ alertPosition: SCNVector3) {
        let alertComponents = buildHud(position: alertPosition)
        alertNode = alertComponents.0
        alertLabelNode = alertComponents.1
        cameraNode.addChildNode(alertNode)
    }
    
    //https://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
    //answered Aug 24 '15 at 14:47 - Edward
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor * 0.9
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    func buildHud(position: SCNVector3) -> (SCNNode, SKLabelNode) {
        let skHudScene = SKScene(size: CGSize(width: 1000, height: 500))
        skHudScene.backgroundColor = UIColor.clear
        skHudScene.scaleMode = .aspectFill
        
        let rrectangle = SKShapeNode(rect: rect, cornerRadius: 20)
        rrectangle.fillColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        rrectangle.strokeColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        rrectangle.lineWidth = 5
        rrectangle.alpha = 0.1
        
        //todo error with size to fit algo above (small divisor)
        let labelNode = SKLabelNode(text: "------||-----")
        adjustLabelFontSizeToFitRect(labelNode: labelNode, rect: rect)
        //labelNode.position = CGPoint(x: 180, y: 250)
        skHudScene.addChild(labelNode)
        skHudScene.addChild(rrectangle)
        
        let plane = SCNPlane(width: 15, height: 7.5)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skHudScene
        plane.materials = [material]
        let node = SCNNode(geometry: plane)
        node.position = position
        
        //flip the node to face the camera
        node.eulerAngles = SCNVector3(CGFloat.pi, 0, 0)
        return (node, labelNode)
    }

    fileprivate func setupScene() {
        screenStack.addArrangedSubview(sceneView)
        sceneView.heightAnchor.constraint(equalToConstant: 800).isActive = true

        //sceneView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        sceneView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = Constants.colors.blueSky
        sceneView.scene = scene
        sceneView.scene?.fogStartDistance = 2
        sceneView.scene?.fogDensityExponent = 2
        sceneView.scene?.fogEndDistance = 100
        sceneView.scene?.fogColor = UIColor.init(white: 1.0, alpha: 0.9)
        //sceneView.allowsCameraControl = true
    }
    
    fileprivate func setupScreenStack() {
        screenStack.axis = .vertical
        screenStack.distribution = .equalCentering
        screenStack.alignment = .center
        screenStack.spacing = 30
        view.addSubview(screenStack)
        screenStack.translatesAutoresizingMaskIntoConstraints = false
        screenStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        screenStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            audioPlayer?.numberOfLoops = 3
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func spawnBlocks() {
        let blockSetNode = BlockSetNode()
        blockSetNode.position.z = -20
        scene.rootNode.addChildNode(blockSetNode)
        blocks.insert(blockSetNode)
        //print("blocks count", blocks.count)
    }
}

extension PlayViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        blocks.forEach { (blockSetNode) in
            if blockSetNode.position.z > 10 {
                blockSetNode.removeFromParentNode()
            }
        }
        switch sceneView.isPlaying {
        case true:

            if time > blockSpawnTime {
                spawnBlocks()
                
                
                blockSpawnTime = time + TimeInterval(Float.random(in: 1.7...3.9))
                
            }
            
            blocks.forEach { (blockSetNode) in
                blockSetNode.position.z += 0.06
            }
        default:
            break
        }


    }
}

extension PlayViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("a", contact.nodeA)
//        print("b", contact.nodeB)
        if contact.nodeB.name == "top" || contact.nodeB.name == "bottom" {
            contact.nodeB.removeFromParentNode()
        }
    }
    
}

