//
//  ViewController.swift
//  MapKitARCLDemo
//
//  Created by RakeSanzzy Shrestha on 25/02/2024.
//

import UIKit
import CoreLocation
import MapKit
import ARCL
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // Array storing diiferent type of businesses
    var businessPlaces = ["Gym", "Restaurant", "Hospital", "Bank"]
    var scenceLocationView = SceneLocationView()
    lazy private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for camera and location permissions
                if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
                    // Display a message view
                    displayPermissionRequiredView()
                } else {
                    checkCameraPermission()
                    // Start AR scene
                    scenceLocationView.run()
                    self.view.addSubview(scenceLocationView)

                    // Configure Location Manager
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.requestAlwaysAuthorization()
                    self.locationManager.startUpdatingLocation()
                }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scenceLocationView.frame = self.view.bounds
    }
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {
                return
            }
            // Stop updating location once it's obtained
            locationManager.stopUpdatingLocation()
            
            // Calling the function to find nearby businesses
            findNearbyBusiness(at: location)
        }

    private func findNearbyBusiness(at location: CLLocation) {
        // Get user's current location
        guard let location = self.locationManager.location else { return }
        
        for businessPlace in businessPlaces {
            // Creating search request for current business type
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = businessPlace
            
           // let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 4000, longitudinalMeters: 4000)
            var region = MKCoordinateRegion()
            region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            request.region = region
            
            // Searching nearby businesses
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                
                if error != nil {
                    return
                }
                
                guard let response = response else { return }
                
                var annotationNodes = [LocationNode]()
                
                for item in response.mapItems {
                    
                    guard let businessLocation = (item.placemark.location) else { return }
                 //   guard let image = self.imageForBusinessPlace(businessPlace) else { return }
//                    let annotationNode = LocationAnnotationNode(location: businessLocation, image: image)
                    let annotationNode = CustomAnnotation(location: businessLocation, title: item.placemark.name!, imageName: self.imageForBusinessPlace(businessPlace)!)
                    annotationNode.scaleRelativeToDistance = true
                    let distance = location.distance(from: businessLocation)
                    if (distance < 4000){
                        print("The placemark name is: \(item.placemark.name) and Distance is : \(distance) meters")
                        
                        annotationNodes.append(annotationNode)
                    }
                }
                
                DispatchQueue.main.async {
                    self.scenceLocationView.addLocationNodesWithConfirmedLocation(locationNodes: annotationNodes)
                }
            }
        }
    }
    
    private func imageForBusinessPlace(_ businessPlace: String) -> String? {
        switch businessPlace {
        case "Gym":
                return "gym"
            case "Restaurant":
                return "restaurant"
            case "Hospital":
                return "hospital"
            case "Bank":
                return "bank"
            default:
                return "mappin.and.ellipse.circle"
        }
    }

    private func displayPermissionRequiredView() {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
            messageLabel.center = self.view.center
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.text = "Camera and location access are required to use this app. Please enable them in Settings."
            self.view.addSubview(messageLabel)
        }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            // Camera access granted
            break
        case .notDetermined:
            // Request camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // Camera access granted, do nothing
                } else {
                    // Camera access denied, display a message to the user
                    DispatchQueue.main.async {
                        self.displayPermissionRequiredView()
                    }
                }
            }
        case .denied, .restricted:
            // Camera access denied, display a message to the user
            displayPermissionRequiredView()
        @unknown default:
            break
        }
    }
}

