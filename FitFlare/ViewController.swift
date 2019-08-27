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
    
    let cube = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.15)

    let cubeNode = SCNNode()
    
    var player: AVAudioPlayer?
    let name = "Ice_Cream"
    
    
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
        
 
        
        setupCubeNode()
        cube.materials.first?.diffuse.contents = UIColor.cyan
        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ground)
        scene.rootNode.addChildNode(cameraNode)

        
        cameraNode.runAction(cameraPanning(node: cameraNode))
        addHoverSpin(node: cubeNode)
        
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
    
    fileprivate func setupCubeNode() {
        cubeNode.geometry = cube
        cubeNode.position = SCNVector3(0,2.5,0)
    }
    
    @objc func pushPlay() {
        let playVC = PlayViewController(nibName: nil, bundle: nil)
        player?.stop()
        self.navigationController?.pushViewController(playVC, animated: true)
    }
    
    func createButtons() {
        let playButton = UIButton(type: .system)
        playButton.setTitle(NSLocalizedString("Play", comment: ""), for: .normal)
        playButton.addTarget(self, action: #selector(self.pushPlay), for: .primaryActionTriggered)
        configureButtons(playButton)
        
        let connectButton = UIButton(type: .system)
        connectButton.setTitle(NSLocalizedString("Connect", comment: ""), for: .normal)
        configureButtons(connectButton)
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
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.prepareToPlay()
            player?.play()
            player?.numberOfLoops = 3
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
}

extension UIViewController {
    
    func lowerCamera(node: SCNNode) -> SCNAction {
        node.position = SCNVector3(0, 30, 12)
        let lookDown = SCNAction.rotateBy(x: -1, y: 0, z: 0, duration: 2)
        let wait = SCNAction.wait(duration: 1)
        let lookUp = lookDown.reversed()
        let cameraSearch = SCNAction.sequence([lookDown, wait, lookUp])
        node.runAction(cameraSearch)
        let moveDown = SCNAction.move(to: Constants.Positions.initialCamera, duration: 5)
        //let panning = cameraPanning()
        //let sequence = SCNAction.sequence([moveDown, wait, panning])
        return moveDown
    }
    
    func cameraPanning(node: SCNNode) -> SCNAction {
        
        node.position = SCNVector3(0, 25, 18)
        let searchDown = SCNAction.rotateBy(x: -0.2, y: 0, z: 0, duration: 2)
        let searchWait = SCNAction.wait(duration: 1)
        let searchUp = searchDown.reversed()
        let cameraSearch = SCNAction.sequence([searchDown, searchWait, searchUp])
        node.runAction(cameraSearch)
        let moveDown = SCNAction.move(to: Constants.Positions.initialCamera, duration: 4.5)
        let searchSequence = SCNAction.group([cameraSearch, moveDown])
        
        let lookDown = SCNAction.rotateBy(x: -0.10, y: 0.01, z: -0.01, duration: 0.5)
        let lookDownWait = SCNAction.wait(duration: 1.4)
        let lookDownScan = SCNAction.rotateBy(x: 0, y: -0.01, z: -0.01, duration: 0.8)
        let lookDownScanBack = SCNAction.rotateBy(x: 0, y: 0.01, z: 0.01, duration: 1.9)
        let lookUp = SCNAction.rotateBy(x: 0.10, y: -0.01, z: 0.01, duration: 2.0)
        
        let cameraRight = SCNAction.rotateBy(x: 0.09, y:  0.7, z: 0, duration: 2.8)
        let cameraWait = SCNAction.wait(duration: 0.7)
        let cameraLeft = SCNAction.rotateBy(x: -0.09, y: -0.7, z: 0, duration: 3.5)
        let cameraRight2 = SCNAction.rotateBy(x: -0.06, y:  -0.6, z: 0, duration: 2.8)
        let cameraLeft2 = SCNAction.rotateBy(x: 0.06, y: 0.6, z: 0, duration: 3.1)
        let hoverSequence2 = SCNAction.sequence([lookDownWait, lookDown, lookDownWait, lookDownScan, lookDownScanBack, lookUp])
        let hoverSequence3 = SCNAction.sequence([cameraWait, cameraWait, cameraWait, cameraWait, cameraRight,cameraWait, cameraWait, cameraLeft, cameraRight2, cameraWait, cameraWait, cameraLeft2])
        let lookGroup = SCNAction.group([hoverSequence2, hoverSequence3])
        let overallSequence = SCNAction.sequence([searchSequence, lookGroup])
        hoverSequence2.timingMode = .easeInEaseOut
        hoverSequence3.timingMode = .easeInEaseOut
        _ = SCNAction.repeatForever(hoverSequence3)
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



