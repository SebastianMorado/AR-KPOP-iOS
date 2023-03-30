//
//  ViewController.swift
//  AR Videos
//
//  Created by Sebastian Morado on 6/25/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var videoNodes : [String : SKVideoNode] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "images", bundle: Bundle.main) {
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            print("Images Successfully Added")
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        DispatchQueue.main.async {
            if let imageAnchor = anchor as? ARImageAnchor {
                
                var videoName = ""
                var videoYScale : CGFloat = -1.0
                var videoXScale : CGFloat = 1.0
                
                if imageAnchor.referenceImage.name == "victon"{
                    videoName += "victon.mov"
                    videoYScale = -1.5
                    videoXScale = 1.5
                } else if imageAnchor.referenceImage.name == "monstax" {
                    videoName += "monstax.mov"
                    videoYScale = -1.5
                } else {
                    videoName += "fromis.mov"
                }
                
                let videoNode = SKVideoNode(fileNamed: videoName)
                videoNode.play()
                
                let videoScene = SKScene(size: CGSize(width: 1920, height: 1080))
                videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                videoNode.yScale = videoYScale
                videoNode.xScale = videoXScale
                videoScene.addChild(videoNode)
                
                
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                plane.firstMaterial?.diffuse.contents = videoScene
                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles.x = -.pi / 2
                node.addChildNode(planeNode)
                
                self.videoNodes[videoName] = videoNode
                node.name = videoName
                
            }
        }
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if node.isHidden {
            if let imageAnchor = anchor as? ARImageAnchor {
                if let nodeName = node.name, let videoNode = videoNodes[nodeName] {
                    videoNode.pause()
                    sceneView.session.remove(anchor: imageAnchor)
                }
            }
        }
        
    }

}
