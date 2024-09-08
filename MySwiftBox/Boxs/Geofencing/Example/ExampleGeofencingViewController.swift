//
//  ExampleGeofencingViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 20/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MapKit

class ExampleGeofencingViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Geofencing"
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
        
        // Get Offers and start Geofence
        let worker = OfferWorker()
        worker.getOffers { [weak self] result in
            switch result {
                case .success(let offers):
                    GeofencingManager.shared.start(offers: offers)
                case .failure(let error):
                    self?.showAlert(title: nil, message: error.localizedDescription)
            }
        }
        
        // Show All genfencesMonitored in maps
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            GeofencingManager.shared.geofencesMonitored.forEach { geofence in
                self.mapView.addOverlay(MKCircle(center: geofence.coordinate,
                                                  radius: GeofencingManager.defaultAccuracyRadius))
            }
        }
        
        // Draw Route when user change location
        GeofencingManager.shared.onCommitLocationUpdate = { [weak self] userLocation in            
            self?.addRouteOverLayForMapView(sourcelocation: self?.previousLocation ?? userLocation, destinationLocation: userLocation)
            self?.previousLocation = userLocation
            
        }
    }
    
    func addRouteOverLayForMapView(sourcelocation: CLLocation, destinationLocation: CLLocation) {
        
        var source: MKMapItem?
        var destination: MKMapItem?
        
        let sourcePlacemark = MKPlacemark(coordinate: sourcelocation.coordinate, addressDictionary: nil)
        source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate, addressDictionary: nil)
        destination = MKMapItem(placemark: destinationPlacemark)
        
        let request: MKDirections.Request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate {
            response, error in
            guard let response = response else {
                return print("trace the error \(error?.localizedDescription ?? "")")
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension ExampleGeofencingViewController {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.lineWidth = 1
            renderer.strokeColor = .blue
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.4)
            return renderer
        }
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .black
            renderer.lineWidth = 4
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}
