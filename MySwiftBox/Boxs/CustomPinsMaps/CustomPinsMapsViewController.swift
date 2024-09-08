//
//  MapsViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 19/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MapKit

class CustomPinAnnotation: MKPointAnnotation {
    
    let id : String
    var color: UIColor
    var value: String?
    
    init(id : String, color : UIColor, value : String?, coordinate : CLLocationCoordinate2D) {
        self.color = color
        self.id = id
        
        super.init()
        self.coordinate = coordinate
        self.value = value
    }
}

class CustomPinsMapsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Custom Pins"
        self.mapView.delegate = self
       
        self.addPins()
        self.fitAllAnnotations()
    }
    
    //MARK: - Map
    private func addPins() {
        self.removeAllAnnotations()
        let annotations : [CustomPinAnnotation] = [
            .init(id: UUID().uuidString, color: .systemRed, value: "10.1", coordinate: CLLocationCoordinate2D(latitude: 44.797163, longitude: -0.602132)),
            .init(id: UUID().uuidString, color: .systemGreen, value: "8.2", coordinate: CLLocationCoordinate2D(latitude: 44.800756, longitude: -0.605050)),
            .init(id: UUID().uuidString, color: .systemBlue, value: "6.4", coordinate: CLLocationCoordinate2D(latitude: 44.805445, longitude: -0.599643))
        ]
        self.mapView.addAnnotations(annotations)
    }
    
    private func removeAllAnnotations() {
        let annotations = mapView.annotations.filter({!($0 is MKUserLocation)})
        mapView.removeAnnotations(annotations)
    }
    
    func fitAllAnnotations() {
        var zoomRect = MKMapRect.null
        for annotation in self.mapView.annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }
        self.mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 200, right: 50), animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension CustomPinsMapsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView : CustomAnnotationContainerView?
        let reuseIdentifier = "custom"
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CustomAnnotationContainerView {
            annotationView = dequedView
        } else {
            annotationView = CustomAnnotationContainerView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }

        let customAnnotation = annotation as? CustomPinAnnotation
        annotationView?.customView.pinColor = customAnnotation?.color
        annotationView?.customView.text = customAnnotation?.value
        annotationView?.canShowCallout = false

        return annotationView

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinAnnotation = view.annotation as? CustomPinAnnotation
        print(pinAnnotation?.id ?? "")
    }
}
