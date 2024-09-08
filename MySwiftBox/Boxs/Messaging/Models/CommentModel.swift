//
//  CommentModel.swift
//  rodinclip
//
//  Created by ELANKUMARAN Tharsan on 14/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit
import ObjectMapper

struct CommentMapContext : MapContext {
    let thread : Int
}

class CommentModel: BaseModel, NSDiscardableContent {
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
        
    }
    
    func discardContentIfPossible() {
        
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
    
    
    let id: Int
    let data: DataModel?
    let created_at: Date
    let user: UserModel
    let thread : Int
    
    public required init(map: Map) throws {
        do {
            id = try map.value(attributs.id.string)
            data = try? map.value(attributs.data.string)
//            created_at = try map.value(attributs.created_at.string, using: TransfomModel().transformDateFromISO8601)
            created_at = Date()
            user = try map.value(attributs.user.string)
            thread = (map.context as? CommentMapContext)?.thread ?? 0
            
            try super.init(map: map)
        }catch{
            #if DEBUG
            assertionFailure(error.localizedDescription)
            #endif
            throw error
        }
    }
    
    override open func mapping(map: Map) {
        super.mapping(map: map)
        
        id >>> map[attributs.id.string]
        data >>> map[attributs.data.string]
        created_at >>> (map[attributs.created_at.string], TransfomModel().transformDateFromISO8601)
        user >>> map[attributs.user.string]
    }
    
    enum attributs: String {
        case id
        case data
        case created_at
        case user
        
        var string : String {
            return self.rawValue
        }
    }
}
