//
//  GameController.swift
//  PaperTossAR
//
//  Created by guran on 4/12/20.
//  Copyright © 2020 Yuchen Yang. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

/*
 Game Controller class. Track the status of the game. Create and load different 3D models. Put models in reality. Detect the collisions between models.
 writer: RealityKit group
 mainainer: RealityKit group
*/
class GameController {
    
    // status for different things to put
    enum Status: String {
        case Can = "sodaCan"
        case Box = "Box"
        case Basket = "wasteBasket"
        case MovingBasket = "movingBasket"
        case RotatingBasket = "rotatingBasket"
    }
    
    var status : Status
    // Array to record all subscription events
    var subscriptions: [Cancellable] = []
    var score = 0
    var audioPlayer: AVAudioPlayer?
    var basketCount = 0
    /*
     Initiate function. Set status to basic basket.
     input: none.
     output: none.
     */
    init() {
        status = .Basket
    }
    
    /*
     Set status to moving basket.
     input: none.
     output: none.
     */
    public func setMovingBasket() {
        restart()
        status = .MovingBasket
    }
    
    /*
     Set status to rotating basket.
     input: none.
     output: none.
     */
    public func setRotatingBasket() {
        restart()
        status = .RotatingBasket
    }
    
    /*
     Restart function. Clear subscriptions, baskets. Set socre to 0 and status to basic basket.
     input: none.
     output: none.
     */
    public func restart() {
        print("Restart!")
        for sub in subscriptions {
            sub.cancel()
        }
        subscriptions.removeAll()
        score = 0
        status = .Basket
        basketCount = 0
    }
    
    /*
     Put things to the reality according to the raycast result. Detect collisions when putting things. If collision occurs, the socre should add one and the bottle should be removed.
     input: arView, scoreText, goal, raycast result.
     output: current socre.
     */
    func putThing(_ arView: ARView, _ scoreText: UITextView, _ goal: simd_float3, _ rayCastResult: ARRaycastResult) -> Int{
        // choose things to put
        switch status {
        //when the user choose to throw a box
        case .Box:
            // create 3D model programmingly
            let transformation = Transform(matrix: rayCastResult.worldTransform)
            let box = CustomBox(color: .yellow)
            box.generateCollisionShapes(recursive: true)

            let mesh = MeshResource.generateText(
                "",
                extrusionDepth: 0.1,
                font: .systemFont(ofSize: 1),
                containerFrame: .zero,
                alignment: .left,
                lineBreakMode: .byTruncatingTail)

            let material = SimpleMaterial(color: .red, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.scale = SIMD3<Float>(0.03, 0.03, 0.1)

            box.addChild(entity)
            box.transform = transformation
            box.name = "canBox"
            entity.setPosition(SIMD3<Float>(-0.05, 0.05, 0), relativeTo: box)
            
            let raycastAnchor = AnchorEntity(raycastResult: rayCastResult)
            raycastAnchor.addChild(box)
            arView.scene.addAnchor(raycastAnchor)
        //when the user choose to throw a soda-can
        case .Can:
            // load model from reality composer
            guard let can = try? Drink.loadScene() else { return -1}
            can.generateCollisionShapes(recursive: true)
            can.position = goal
            can.name = "target"
            can.children[0].children[0].children[0].name = "target"
            arView.scene.anchors.append(can)
           
        //place a moving basket
        case .MovingBasket:
            guard let basket = try? MovingBasket.loadScene() else { return -1}
            basket.generateCollisionShapes(recursive: true)
            basket.position = goal
            arView.scene.anchors.append(basket)
            let basketEntity = basket.children[0].children[0].children[0]
            basketCount += 1
            detectCollision(arView, scoreText, basketEntity)
        //place a rotating basket
        case .RotatingBasket:
            guard let basket = try? RotatingBasket.loadScene() else { return -1}
            basket.generateCollisionShapes(recursive: true)
            basket.position = goal
            arView.scene.anchors.append(basket)
            let basketEntity = basket.children[0].children[0].children[0]
            basketCount += 1
            detectCollision(arView, scoreText, basketEntity)
        //place a basic static basket
        default:
            guard let basket = try? Basket.loadScene() else { return -1}
            basket.generateCollisionShapes(recursive: true)
            basket.position = goal
            print(arView.scene.anchors.count)
            arView.scene.anchors.append(basket)
            let basketEntity = basket.children[0].children[0].children[0]
            basketCount += 1
            detectCollision(arView, scoreText, basketEntity)
        }
        if arView.scene.anchors.count > self.basketCount{
            print("Moving this can!!")
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            arView.scene.anchors.remove(at: arView.scene.anchors.count - 1)
           })
        }
        return score
    }
    
    /*
     This is the function to detect collision. When collision detected, check the collision objects. If object is can or canBox, scores will be recorded and sound will be played.
     input: arView, scoreText.
     output: none.
    */
    func detectCollision(_ arView: ARView, _ scoreText: UITextView, _ basket: Entity) {
        let subscription = arView.scene.subscribe(to: CollisionEvents.Began.self, on: basket) { event in
            let entityB = event.entityB
            if (entityB.name.hasPrefix("can")) {
                self.score += 1
                self.playSound()
                scoreText.text = String(self.score)
                // delay 0.6s and delete the can after throwing it
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    self.removeCan(arView, self.basketCount)
                })
            }
        }
        subscriptions.append(subscription)
    }
    
    /*
     Remove the last added bottle.
     input: arView.
     output: none.
     */
    func removeCan(_ arView: ARView, _ basketCount: Int) {
        if arView.scene.anchors.count > self.basketCount{
            arView.scene.anchors.remove(at: arView.scene.anchors.count - 1)
        }
        
    }
    
    /*
     Add sound effect when the soda-can hit the basket and score up
     input: none.
     output: none.
     */
    func playSound() {
        let path = Bundle.main.path(forResource: "score", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
        catch let error as NSError {
            print(error.description)
        }
    }
}
