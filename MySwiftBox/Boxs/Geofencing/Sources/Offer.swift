//
//  Offer.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 31/07/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation

struct Offer: Decodable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
}
