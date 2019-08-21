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

    var hrMonitor:HeartRateLEMonitor!
    
    let screenStack = UIStackView()
    let buttonStack = UIStackView()
    
    let sceneView = SCNView()
    var cameraNode = SCNNode()
    let scene = SCNScene()
    
    let lightNode = SCNNode()
    let spotLight = SCNLight()
    
    var player: AVAudioPlayer?
    let name = "So_Lit"
    
    var hudLabelNode:SKLabelNode!
    var hudNode:SCNNode!
    
    var alertLabelNode:SKLabelNode!
    var alertNode:SCNNode!
    
    var timer:Timer!
    var timerCount = 30
    

    
    fileprivate func buildHud(_ hudPosition: SCNVector3) {
        //buildAlert()
        //alertLabelNode.text = "Squats"
        let hudComponents = buildHud(position: hudPosition)
        hudNode = hudComponents.0
        hudLabelNode = hudComponents.1
        hudLabelNode.text = "4"
        cameraNode.addChildNode(hudNode)
        hudLabelNode.text = "A_Rising_Wave"
    }
    
    fileprivate func buildAlert(_ alertPosition: SCNVector3) {
        let alertComponents = buildHud(position: alertPosition)
        alertNode = alertComponents.0
        alertLabelNode = alertComponents.1
        cameraNode.addChildNode(alertNode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupScreenStack()
        setupButtonStack()
        setupScene()
        setupCamera(cameraNode: cameraNode)
        
        playSound(name: name)

        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.1
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.darkGray
        let ground = SCNNode(geometry: groundGeometry)
        ground.position = SCNVector3(0, 0, -20)
        
        setupLight(light: spotLight, node: lightNode, ground)
        
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ground)
        scene.rootNode.addChildNode(cameraNode)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startWorkout), userInfo: nil, repeats: true)
        
        

        let hudPosition = SCNVector3( -15, 5, -18)
        let alertPosition = SCNVector3( 38, 5, -18)
        
        
        buildHud(hudPosition)
        
        buildAlert(alertPosition)
        alertLabelNode.text = "Go"
        
        let hudToRight = SCNAction.move(to: SCNVector3(25, 5, -18), duration: 0)
        let hudScrollLeft = SCNAction.move(by: SCNVector3(-34, 0, 0), duration: 1.5)
        let hudWait = SCNAction.wait(duration: 4)
        let call = SCNAction.run { (node) in
            self.timer.fire()
        }
        let hudScrollRight = hudScrollLeft.reversed()
        let hudSequence = SCNAction.sequence([hudScrollLeft, hudWait, hudScrollRight])
        hudSequence.timingMode = .easeInEaseOut
        alertNode.runAction(hudSequence)
    }
    
    @objc func startWorkout() {
        print("start workout")
        hudLabelNode.text = "Squats for \(timerCount)"
        timerCount -= 1
        
        timerCount = timerCount == 0 ? 30 : timerCount
        
    }
    
    //https://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
    //answered Aug 24 '15 at 14:47
    //
    //Edward
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor * 0.9
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    fileprivate func buildHud(position: SCNVector3) -> (SCNNode, SKLabelNode) {
        let skHudScene = SKScene(size: CGSize(width: 1000, height: 500))
        skHudScene.backgroundColor = UIColor.clear
        skHudScene.scaleMode = .aspectFill
        let rect = CGRect(x: 0, y: 0, width: 1000, height: 500)
        let rrectangle = SKShapeNode(rect: rect, cornerRadius: 20)
        rrectangle.fillColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        rrectangle.strokeColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        rrectangle.lineWidth = 5
        rrectangle.alpha = 0.1
        
        let labelNode = SKLabelNode(text: "Heart Rate: \(hrMonitor.currentHeartRate)")
        adjustLabelFontSizeToFitRect(labelNode: labelNode, rect: rect)
        print(labelNode)
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
        node.eulerAngles = SCNVector3(CGFloat.pi, 0, 0)
        return (node, labelNode)
    }

    fileprivate func setupScene() {
        screenStack.addArrangedSubview(sceneView)
        screenStack.addArrangedSubview(buttonStack)
        sceneView.heightAnchor.constraint(equalToConstant: 800).isActive = true
        sceneView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = Constants.colors.blueSky
        sceneView.scene = scene
        sceneView.scene?.fogStartDistance = 2
        sceneView.scene?.fogDensityExponent = 2
        sceneView.scene?.fogEndDistance = 100
        sceneView.scene?.fogColor = UIColor.init(white: 1.0, alpha: 0.9)
        sceneView.allowsCameraControl = true
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



}

class HudNode: SCNNode {
    
    var message:String
    
    func set(message: String) {
        self.message = message
    }
    
    init(message: String) {
        self.message = message
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
