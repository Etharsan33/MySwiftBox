import UIKit
import ObjectMapper

public class CommentToSendModel: BaseModel {
    
    ///text
    let content     : String?
    /// uuid of the image
    let attachment  : String?
    /// URL path of the image
    let path        : String?
    /// width of the image
    let width       : CGFloat?
    /// height of the image
    let height      : CGFloat?

    
    convenience init?(content : String?, attachment : String?, path : URL?, size : CGSize?) {
        
        var json : [String : Any] = [:]
        json[attributs.content.string]      = content
        json[attributs.attachment.string]   = attachment
        json[attributs.path.string]         = path?.absoluteString
        json[attributs.width.string]        = size?.width
        json[attributs.height.string]       = size?.height

        
        let map = Map(mappingType: .fromJSON, JSON: json, toObject: false, context: nil, shouldIncludeNilValues: false)
        
        try? self.init(map: map)
    }
    
    public required init(map: Map) throws {
        
        do {
            content     = try? map.value(attributs.content.string)
            attachment  = try? map.value(attributs.attachment.string)
            path        = try? map.value(attributs.path.string)
            width       = try? map.value(attributs.width.string)
            height      = try? map.value(attributs.height.string)
            
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
        
        content     >>> map[attributs.content.string]
        attachment  >>> map[attributs.attachment.string]
        path        >>> map[attributs.path.string]
        width       >>> map[attributs.width.string]
        height      >>> map[attributs.height.string]
    }
    
    enum attributs : String {
        case content
        case attachment
        case path
        case width
        case height
        
        var string : String {
            return self.rawValue
        }
    }
}
