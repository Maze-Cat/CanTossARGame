//
//  ViewController.swift
//  PaperTossAR
//
//  Created by Yuchen Yang on 2020/4/5.
//  Copyright © 2020 Yuchen Yang. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

/*
 ViewController class for the main ARView. Set up the ARView. Handle the touch gesture. Create alert message and pop up view. Maintain the level and score for the game.
 writer: RealityKit group
 mainainer: RealityKit group
 */
class ViewController: UIViewController, ARSessionDelegate, UITextViewDelegate {

    @IBOutlet weak var scoreText: UITextView!
    @IBOutlet var arView: ARView!
    
    // variables for alert message
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    var baseMessage: String?
    
    // game controller for the game
    var gameController = GameController()
    
    // level and score
    var level = 1
    var score = 0 {
        // set wathcer for score value
        didSet {
            // restart and increase level when score reaches 5
            if score >= 5 {
                level += 1
                restart()
                if level == 2 {
                    showAlertMsg(title: "Level Up!", message: "Go to level 2", time: 100)
                    gameController.setMovingBasket()
                } else if level == 3 {
                    showAlertMsg(title: "Level Up!", message: "Go to level 3", time: 100)
                    gameController.setRotatingBasket()
                } else {
                    showAlertMsg(title: "You win!", message: "Retry!", time: 100)
                    level = 1
                }
            }
        }
    }

    // MARK: - AR View Setting
    /*
     Override viewDidLoad function to set the score text delegate.
     input: none.
     output: none.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreText.delegate = self // Without setting the delegate you won't be able to track UITextView events
    }
    
    /*
     Override viewDidAppear function to set the session delegate. Set up the AR view. Add gesture recognizer to handle the touch gesture.
     input: animated.
     output: none.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARView()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
       
    /*
     Set up the AR view. Create AR wrold tracking configuration. Add horizontal plane detection. Set environment texturing as automatic.
     input: none.
     output: none.
     */
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    /*
     The function to handle the tap gesture. To get a 3D world position that corresponds to the tap location, cast a ray from the camera’s origin through the touch location to check for intersection with any real-world surfaces along that ray. If no horizontal plane is detected, pop up reminder; else, tell the game controller to put things.
     input: UITapGestureRecognizer
     output: none.
     corner case: If the model fails to load, error message would print.
     */
    @objc
    func handleTap(recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        // return an array of horizontal surfaces detected
        guard let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first else {
            popUpReminder()
            return
        }
        // map the tapped point into the 3D coordinate space
        let goal =  arView.unproject(location, ontoPlane: raycastResult.worldTransform)
        score = gameController.putThing(arView, scoreText, goal!, raycastResult)
        if score == -1 {
            print("Error: No model loaded!")
        }
    }
    
    // MARK: - Popup View Setting
    /*
     Set up pop-up reminder when no plane detected
     input: none.
     output: none.
     */
    func popUpReminder() {
        // vibrate to notify plane detection failed
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        // direct to pop up window
        let popVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "popID") as! PopUpViewController
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)

        print("ERROR-- No surface detected")
    }
    
    // MARK: - Restart Setting
    /*
     Restart function. Clear all objects in AR view. Set the socre and text to 0. Restart the game controller.
     input: none.
     output: none.
     */
    func restart() {
        
        score = 0
        scoreText.text = String(0)
        gameController.restart()
    }

    /*
     This is the function for cleaning up entities and reset all relative values.
     input: sender.
     output: none.
    */
    @IBAction func deleteAllObjects(_ sender: Any) {
        restart()
        arView.scene.anchors.removeAll()
        showAlertMsg(title: "New Game", message: "Start!", time: 5)
        level = 1
    }
    
    // MARK: - Buttons Setting
    /*
     Change mode to throw a soda can.
     input: sender.
     output: none.
     */
    @IBAction func addBottle(_ sender: Any) {
        gameController.status = .Can
    }
        
    /*
     Change mode to throw a box.
     input: sender.
     output: none.
     */
    @IBAction func addBox(_ sender: Any) {
        gameController.status = .Box
    }
    
    // MARK: - Alert Message Setting
    /*
     This is the function for pop up msg when restart game or level increase. The pop up window will disapper afer 3s if user does not respond.
     input: title, message, time.
     output: none.
     */
    func showAlertMsg(title: String, message: String, time: Int) {
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        baseMessage = message
        remainingTime = time
        alertController = UIAlertController(title: title, message: self.alertMessage(), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Go!", style: .cancel) { (action) in
            print("Go to next level")
            self.alertController = nil
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.arView.scene.anchors.removeAll()
        }
        alertController!.addAction(cancelAction)
        alertTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.countDown), userInfo: nil, repeats: true)
        present(alertController!, animated: true, completion: nil)
    }
    
    /*
     Count down function to count time.
     input: none.
     output: none.
     */
    @objc func countDown() {
        remainingTime -= 1
        if (remainingTime < 0) {
            alertTimer?.invalidate()
            alertTimer = nil
            alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
        } else {
            alertController!.message = alertMessage()
        }

    }
    
    /*
     This is the function to convert msg into string
     input: none.
     output: message String.
    */
    func alertMessage() -> String {
        var message = ""
        if let baseMessage = baseMessage {
            message = baseMessage + " "
        }
        return(message)
    }
}



