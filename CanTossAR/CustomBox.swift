//
//  CustomBox.swift
//  PaperTossAR
//
//  Created by guran on 4/17/20.
//  Copyright © 2020 Yuchen Yang. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

/*
 Cunstom box class. Create box model entity programmingly.
 writer: Zhuojun Huang
 mainainer: RealityKit group
*/
class CustomBox: Entity, HasModel, HasAnchoring, HasCollision {
    required init(color: UIColor) {
        super.init()
        // set up model components
        // set up model shape, box size and color
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.07),
            materials: [SimpleMaterial(
                color: color,
                isMetallic: false)
            ]
        )
    }
    
    // initializer for setting up color and position of the box
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
