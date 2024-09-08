//
//  DataModel.swift
//  rodinclip
//
//  Created by ELANKUMARAN Tharsan on 14/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit
import ObjectMapper

class DataModel: BaseModel {
    
    let content: String?
    let attachment: String?
    let attachment_thumbnail: String?
    let width: CGFloat?
    let height: CGFloat?
    
    public required init(map: Map) throws {
        do {
            content = try? map.value(attributs.content.string)
            attachment = try? map.value(attributs.attachment.string)
            attachment_thumbnail = try? map.value(attributs.attachment_thumbnail.string)
            width = try? map.value(attributs.width.string)
            height = try? map.value(attributs.height.string)
            
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
        
        content >>> map[attributs.content.string]
        attachment >>> map[attributs.attachment.string]
        attachment_thumbnail >>> map[attributs.attachment_thumbnail.string]
        width >>> map[attributs.width.string]
        height >>> map[attributs.height.string]
    }
    
    enum attributs: String {
        case content
        case attachment
        case attachment_thumbnail = "attachment_thumb"
        case width
        case height
        
        var string : String {
            return self.rawValue
        }
    }
}
