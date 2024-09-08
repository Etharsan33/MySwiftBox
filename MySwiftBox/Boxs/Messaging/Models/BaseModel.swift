//
//  BaseModel.swift
//  rodinclip
//
//  Created by ELANKUMARAN Tharsan on 14/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import ObjectMapper

/// A simple model from which all models should have as parent
open class BaseModel: ImmutableMappable {
    
    public init() {}
    
    public required init(map: Map) throws {
        //
    }
    
    open func mapping(map: Map) {
        //
    }
}
