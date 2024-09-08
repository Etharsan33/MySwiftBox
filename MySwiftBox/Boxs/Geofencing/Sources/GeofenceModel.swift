//
//  GeofenceModel.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 29/07/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import MapKit

class GeofenceModel: NSObject, MKAnnotation {
    
    var id: String
    var coordinate: CLLocationCoordinate2D
    var name: String
    var content: String
    
    init(id: String, coordinate: CLLocationCoordinate2D, name: String, content: String) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
        self.content = content
    }
}
