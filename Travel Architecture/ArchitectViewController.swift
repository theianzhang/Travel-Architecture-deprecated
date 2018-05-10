//
//  ARTwoViewController.swift
//  Travel Architecture
//
//  Created by Ian Zhang on 4/15/18.
//  Copyright © 2018 icz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ArchitectViewController: UIViewController, ARSCNViewDelegate
{

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // Show features
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapGestureToSceneView()
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ArchitectViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /*
     ************************************************************************************************************
     
     building object functions
     
     ************************************************************************************************************
     */
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer)
    {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        guard let shipScene = SCNScene(named: "ship.scn"),
            let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
            else { return }
        
        shipNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(shipNode)
    }
    
    /*
     ************************************************************************************************************
     
     nodes and anchors functions
     
     ************************************************************************************************************
     */
    
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
     {
        // Ensure we have detected a valid plane
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Visualize that plane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // Add blue color to make it easy
        plane.materials.first?.diffuse.contents = UIColor.blue
        
        // Initialize a node
        let planeNode = SCNNode(geometry: plane)
        
        // Position it
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add node
        node.addChildNode(planeNode)
        
     }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
    }
    
    /*
     ************************************************************************************************************
 
        error handling functions
     
     ************************************************************************************************************
    */
    
    func session(_ session: ARSession, didFailWithError error: Error)
    {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession)
    {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession)
    {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

}

extension matrix_float4x4
{
    func position() -> SCNVector3
    {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
