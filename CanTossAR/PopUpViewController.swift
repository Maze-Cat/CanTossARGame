//
//  PopUpViewController.swift
//  PaperTossAR
//
//  Created by Yuqi Ma on 4/5/20.
//  Copyright © 2020 Yuchen Yang. All rights reserved.
//

import UIKit

/*
 Pop-up ViewController class for the pop-up view.
 writer: Yuqi Ma
 mainainer: RealityKit group
*/
class PopUpViewController: UIViewController {

    /*
    override viewDidLoad function. Set the background color and show the window.
    input: none.
    output: none.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
    }
    
    /*
    back function. When the user click the Try Again button, go back to main ArView and remove animate.
    input: any.
    output: none.
    */
    @IBAction func back(_ sender: Any) {
        removeAnimate()
    }
    
    /*
    Show animation function. Set up the pop-up window as animation in UIView.
    input: none.
    output: none.
    */
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    /*
     Remove animation function. Remove the animation in UIView.
     input: none.
     output: none.
     */
    func removeAnimate() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion: {(finished : Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
}
