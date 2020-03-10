//
//  ViewController.swift
//  iSmartForm
//
//  Created by Parker McLain on 3/5/20.
//  Copyright © 2020 Parker McLain. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    var box: ModelEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0]
    
    let hip = AnchorEntity()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        let box1 = MeshResource.generateBox(size: 0.06)
        let entity1 = ModelEntity(mesh: box1)
        self.box = entity1
        
        arView.scene.addAnchor(hip)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            // Access to the position of root node
            let hipWorldPosition = bodyAnchor.transform
            // Accessing the Skeleton Geometry
            let skeleton = bodyAnchor.skeleton
            // Accessing list of transforms of all joints relative to root
            let jointTransforms = skeleton.jointModelTransforms
            
            // Set root box
            let bodyPosition = simd_make_float3(hipWorldPosition.columns.3)
            hip.position = bodyPosition
            hip.orientation = Transform(matrix: hipWorldPosition).rotation
            if let box = box, box.parent == nil {
                hip.addChild(box)
                print("A12: The box has been added ...")
            }
            
            // Iterating over All joints
            for(i, jointTransform) in jointTransforms.enumerated() {
                // Extract parent index from definition
                let parentIndex = skeleton.definition.parentIndices[i]
                // Check if it's not root
                guard parentIndex != -1 else { continue }
                // Find position of parent joint
                let parentJointTransform = jointTransforms[parentIndex]
            }
        }
    }
}
