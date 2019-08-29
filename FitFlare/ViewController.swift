//
//  ViewController.swift
//  FitFlare
//
//  Created by David Lang on 8/17/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation

class ViewController: UIViewController {    
    let screenStack = UIStackView()
    let buttonStack = UIStackView()

    let sceneView = SCNView()
    var cameraNode = SCNNode()
    let scene = SCNScene()
    
    let lightNode = SCNNode()
    let spotLight = SCNLight()
    
    var audioPlayer: AVAudioPlayer?
    let name = "Ice_Cream"
    
    var playerNode:Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        setupScreenStack()
        setupButtonStack()
        setupScene()
        setupCamera(cameraNode: cameraNode)
        createButtons()

        playSound(name: name)
        
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.1
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.darkGray
        groundGeometry.materials = [groundMaterial]
    
        let ground = SCNNode(geometry: groundGeometry)
        ground.position = SCNVector3(0, 0, -20)

        setupLight(light: spotLight, node: lightNode, ground)
        
        playerNode = Player()
        playerNode.physicsBody = nil
        playerNode.position = SCNVector3(1,2.5, 0)
        playerNode.light = nil
    
        playerNode.retract()
        let emergeWait = SCNAction.wait(duration: 26)
        playerNode.head.runAction(SCNAction.sequence([emergeWait, playerNode.headEmergeAction]))
        emergeWait.duration = 27.2
        playerNode.rightFoot.runAction(SCNAction.sequence([emergeWait, playerNode.rightFootEmergeAction]))
        emergeWait.duration = 27.5
        playerNode.rightHand.runAction(SCNAction.sequence([emergeWait, playerNode.rightHandEmergeAction]))
        playerNode.leftFoot.runAction(SCNAction.sequence([emergeWait, playerNode.leftFootEmergeAction]))
        playerNode.leftHand.runAction(SCNAction.sequence([emergeWait, playerNode.leftHandEmergeAction]))

        scene.rootNode.addChildNode(playerNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ground)
        scene.rootNode.addChildNode(cameraNode)
        
        cameraNode.runAction(cameraPanning(node: cameraNode))
        addHoverSpin(node: playerNode)
        
        //sprite kit display
        
        let skScene = SKScene(size: CGSize(width: 1000, height: 500))
        skScene.backgroundColor = UIColor.clear
        skScene.scaleMode = .aspectFill
        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 1000, height: 500), cornerRadius: 20)
        rectangle.fillColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        rectangle.strokeColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        rectangle.lineWidth = 4
        rectangle.alpha = 0.1
        let labelNode = SKLabelNode(text: "Shapeshifter")
        labelNode.fontSize = 150
        labelNode.position = CGPoint(x:400,y:350)
        skScene.addChild(rectangle)
        skScene.addChild(labelNode)
        
        let plane = SCNPlane(width: 15, height: 7.5)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(-15, 5, -18)
        node.eulerAngles = SCNVector3(CGFloat.pi, 0, 0)
        cameraNode.addChildNode(node)    
    }
    
    @objc func pushPlay() {
        let playVC = PlayViewController(nibName: nil, bundle: nil)
        audioPlayer?.stop()
        self.navigationController?.pushViewController(playVC, animated: true)
    }
    
    @objc func goToPlayStats() {
        let statsVC = StatsViewController(nibName: nil, bundle: nil)
        audioPlayer?.stop()
        self.navigationController?.pushViewController(statsVC, animated: true)
    }
    
    func createButtons() {
        let playButton = UIButton(type: .system)
        playButton.setTitle(NSLocalizedString("Play", comment: ""), for: .normal)
        playButton.addTarget(self, action: #selector(self.pushPlay), for: .primaryActionTriggered)
        configureButtons(playButton)
        
        let statsButton = UIButton(type: .system)
        statsButton.setTitle(NSLocalizedString("Stats", comment: ""), for: .normal)
        statsButton.addTarget(self, action: #selector(self.goToPlayStats), for: .primaryActionTriggered)
        configureButtons(statsButton)
    }
    
    fileprivate func setupScene() {
        screenStack.addArrangedSubview(sceneView)
        screenStack.addArrangedSubview(buttonStack)
        sceneView.heightAnchor.constraint(equalToConstant: 800).isActive = true
        sceneView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.4, blue: 0.7, alpha: 0.3)
        sceneView.scene = scene
        sceneView.scene?.fogStartDistance = 2
        sceneView.scene?.fogDensityExponent = 2
        sceneView.scene?.fogEndDistance = 100
        sceneView.scene?.fogColor = UIColor.init(white: 1.0, alpha: 0.9)
        sceneView.allowsCameraControl = true
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

    func configureButtons(_ button: UIButton) {
        buttonStack.addArrangedSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    fileprivate func setupButtonStack() {
        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalCentering
        buttonStack.alignment = .center
        buttonStack.spacing = 30
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func lowerCamera(node: SCNNode) -> SCNAction {
        node.position = SCNVector3(0, 30, 12)
        let lookDown = SCNAction.rotateBy(x: -1, y: 0, z: 0, duration: 2)
        let wait = SCNAction.wait(duration: 1)
        let lookUp = lookDown.reversed()
        let cameraSearch = SCNAction.sequence([lookDown, wait, lookUp])
        node.runAction(cameraSearch)
        let moveDown = SCNAction.move(to: Constants.Positions.initialCamera, duration: 5)
        return moveDown
    }
    
    func cameraPanning(node: SCNNode) -> SCNAction {
        
        node.position = SCNVector3(0, 25, 18)
        let searchDown = SCNAction.rotateBy(x: -0.2, y: 0, z: 0, duration: 2)
        let searchWait = SCNAction.wait(duration: 1)
        let searchUp = searchDown.reversed()
        let cameraSearch = SCNAction.sequence([searchDown, searchWait, searchUp])
        node.runAction(cameraSearch)
        let moveDown = SCNAction.move(to: Constants.Positions.initialCamera, duration: 3.5)
        let searchSequence = SCNAction.group([cameraSearch, moveDown])
        
        let lookGroup = SCNAction.group([LevelUtil.cameraLookAround, LevelUtil.cameraScanning])
        let overallSequence = SCNAction.sequence([searchSequence, lookGroup])
        _ = SCNAction.repeatForever(LevelUtil.cameraScanning)
        return overallSequence
    }
}

extension UIViewController {
 
    func addHoverSpin(node: SCNNode) {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 4.0)
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 2.5)
        let hoverDown = SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 2.5)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let rotateAndHover = SCNAction.group([rotateOne, hoverSequence])
        let repeatForever = SCNAction.repeatForever(rotateAndHover)
        node.runAction(repeatForever)
    }
    
    func setupLight(light: SCNLight, node: SCNNode, _ ground: SCNNode) {
        light.type = SCNLight.LightType.spot
        light.castsShadow = false
        light.spotInnerAngle = 50.0
        light.spotOuterAngle = 100.0
        light.zFar = 70
        node.light = light
        node.position = SCNVector3(x: 0, y: 3, z: 10)
        node.constraints = [SCNLookAtConstraint(target: ground)]
    }
    
    func setupCamera(cameraNode: SCNNode) {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.bloomIntensity = 0.9
        cameraNode.camera?.vignettingIntensity = 0.9
        cameraNode.camera?.vignettingPower = 0.2
        cameraNode.position = SCNVector3(0, 5, 12)
    }
}



