//
//  CustomAnnotation.swift
//  MapKitARCLDemo
//
//  Created by RakeSanzzy Shrestha on 26/02/2024.
//

import Foundation
import ARCL
import CoreLocation
import SceneKit

class CustomAnnotation: LocationNode{
    
    var title: String
    var annotationNode: SCNNode
    var imageName: String
    
    init(location: CLLocation?, title: String, imageName: String){
        
        self.annotationNode = SCNNode()
        self.title = title
        self.imageName = imageName
        super.init(location: location)
        
        initializeUI()
    }
    
    private func initializeUI() {
        let plane = SCNPlane(width: 100, height: 120)
        plane.cornerRadius = 0.2
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        // Create an image node
        let image = UIImage(named: imageName)
        let imageNode = SCNNode(geometry: SCNPlane(width: 60, height: 60))
        imageNode.geometry?.firstMaterial?.diffuse.contents = image
        imageNode.position = SCNVector3(plane.width / 2, 10, 0.01)
        
        // Create a text node
        let text = SCNText(string: self.title, extrusionDepth: 0)
        text.containerFrame = CGRect(x: 0, y: 0, width: 60, height: 40)
        text.isWrapped = true
        text.font = UIFont(name: "Futura", size: 10.0)
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(20, -65, 0.01)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.addChildNode(imageNode)
        planeNode.addChildNode(textNode)
        
        self.annotationNode.scale = SCNVector3(3, 3, 3)
        self.annotationNode.addChildNode(planeNode)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
        
        self.addChildNode(self.annotationNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
