//
//  SyncroCatModel.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 16/10/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation

//https://alexwohlbruck.github.io/cat-facts/docs/

struct SyncroCatModel: Codable {
    let id: String
    let text: String
    let upvotes: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case upvotes
    }
}
