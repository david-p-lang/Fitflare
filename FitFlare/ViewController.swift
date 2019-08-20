//
//  ViewController.swift
//  FitFlare
//
//  Created by David Lang on 8/17/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class ViewController: UIViewController {

    let hrMonitor = HeartRateLEMonitor()
    
    let screenStack = UIStackView()
    let buttonStack = UIStackView()

    let sceneView = SCNView()
    var cameraNode = SCNNode()
    let scene = SCNScene()
    
    let light = SCNNode()
    let spotLight = SCNLight()
    
    let ball = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.15)

    let ballNode = SCNNode()
    
    var player: AVAudioPlayer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hrMonitor.startUpCentralManager()
        
        setupScreenStack()
        setupButtonStack()
        setupScene()
        setupCamera()
        
        playSound(name: "Ice_Cream")
        
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.1
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.darkGray
        let cyanMaterial = SCNMaterial()
        cyanMaterial.diffuse.contents = UIColor.cyan
        let anOrangeMaterial = SCNMaterial()
        anOrangeMaterial.diffuse.contents = UIColor.orange
        let aPurpleMaterial = SCNMaterial()
        aPurpleMaterial.diffuse.contents = UIImage(named: "grid")
        groundGeometry.materials = [groundMaterial]
        
        let ground = SCNNode(geometry: groundGeometry)
        ground.position = SCNVector3(5, 0, -20)

        setupLight(ground)
        
        scene.rootNode.addChildNode(light)
        scene.rootNode.addChildNode(ground)
        scene.rootNode.addChildNode(cameraNode)
        
        ballNode.geometry = ball
        ballNode.position = SCNVector3(0,2.5,0)
        ball.materials.first?.diffuse.contents = UIColor.cyan
        scene.rootNode.addChildNode(ballNode)
        
        createButtons()
     
        let lookDown = SCNAction.rotateBy(x: -0.15, y: 0.01, z: -0.01, duration: 0.5)
        let lookDownWait = SCNAction.wait(duration: 1.4)
        let lookDownScan = SCNAction.rotateBy(x: 0, y: -0.01, z: -0.01, duration: 0.8)
        let lookDownScanBack = SCNAction.rotateBy(x: 0, y: 0.01, z: 0.01, duration: 1.9)
        let lookUp = SCNAction.rotateBy(x: 0.15, y: -0.01, z: 0.01, duration: 2.0)

        let cameraRight = SCNAction.rotateBy(x: 0.09, y:  1.0, z: 0, duration: 2.8)
        cameraRight.timingMode = .easeInEaseOut
        let cameraWait = SCNAction.wait(duration: 0.7)
        let cameraLeft = SCNAction.rotateBy(x: -0.09, y: -1.0, z: 0, duration: 3.5)
        let cameraRight2 = SCNAction.rotateBy(x: -0.06, y:  -1.1, z: 0, duration: 2.8)
        let cameraLeft2 = SCNAction.rotateBy(x: 0.06, y: 1.1, z: 0, duration: 3.1)
        let hoverSequence2 = SCNAction.sequence([lookDownWait, lookDown, lookDownWait, lookDownScan, lookDownScanBack, lookUp])
        let hoverSequence3 = SCNAction.sequence([cameraWait, cameraWait, cameraWait, cameraWait, cameraRight,cameraWait, cameraWait, cameraLeft, cameraRight2, cameraWait, cameraWait, cameraLeft2])
        let lookGroup = SCNAction.group([hoverSequence2, hoverSequence3])
        hoverSequence2.timingMode = .easeInEaseOut
        hoverSequence3.timingMode = .easeInEaseOut
        _ = SCNAction.repeatForever(hoverSequence3)
        cameraNode.runAction(lookGroup)
        addHoverSpin(node: ballNode)
    }
    
    func addHoverSpin(node: SCNNode) {
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 4.0)
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 2.5)
        let hoverDown = SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 2.5)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let rotateAndHover = SCNAction.group([rotateOne, hoverSequence])
        let repeatForever = SCNAction.repeatForever(rotateAndHover)
        node.runAction(repeatForever)
    }
    
    func createButtons() {
        let playButton = UIButton(type: .system)
        playButton.setTitle(NSLocalizedString("Play", comment: ""), for: .normal)
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
        sceneView.backgroundColor = .blue
        sceneView.scene = scene
        sceneView.scene?.fogStartDistance = 2
        sceneView.scene?.fogDensityExponent = 3
        sceneView.scene?.fogEndDistance = 50
        sceneView.scene?.fogColor = UIColor.white
        sceneView.allowsCameraControl = true
    }
    
    fileprivate func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.bloomIntensity = 0.8
        //cameraNode.camera?.colorFringeIntensity = 1.0
        cameraNode.camera?.vignettingIntensity = 2.0
        cameraNode.camera?.vignettingPower = 0.1
        cameraNode.position = SCNVector3(0, 5, 10)
        cameraNode.rotation = SCNVector4(0, 0, 0, -1)
    }
    
    fileprivate func setupLight(_ ground: SCNNode) {
        spotLight.type = SCNLight.LightType.spot
        spotLight.castsShadow = true
        spotLight.spotInnerAngle = 50.0
        spotLight.spotOuterAngle = 100.0
        spotLight.zFar = 70
        light.light = spotLight
        light.position = SCNVector3(x: 0, y: 3, z: 10)
        light.constraints = [SCNLookAtConstraint(target: ground)]
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

extension ViewController {
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: SCNSceneRendererDelegate {

}


