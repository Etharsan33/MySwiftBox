import UIKit
import ObjectMapper

class ResourceModel: BaseModel {
    
//    let id:     String
    let name:   String?
    let url:    String?
    let width:  Double?
    let height: Double?

    convenience init?(/*id : String, */name : String?, url : String?, size : CGSize?) {
        
        var json : [String : Any] = [:]
//        json[attributs.id.string]       = id
        json[attributs.name.string]     = name
        json[attributs.url.string]      = url
        json[attributs.width.string]    = size?.width
        json[attributs.height.string]   = size?.height

        
        let map = Map(mappingType: .fromJSON, JSON: json, toObject: false, context: nil, shouldIncludeNilValues: false)
        
        try? self.init(map: map)
    }
    
    public required init(map: Map) throws {
        do {
//            id      = try   map.value(attributs.id.string)
            name    = try?  map.value(attributs.name.string)
            url     = try   map.value(attributs.url.string)
            width   = try?  map.value(attributs.width.string)
            height  = try?  map.value(attributs.height.string)

            
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
        
//        id      >>> map[attributs.id.string]
        name    >>> map[attributs.name.string]
        url     >>> map[attributs.url.string]
        width   >>> map[attributs.width.string]
        height  >>> map[attributs.height.string]
    }
    
    enum attributs: String {
//        case id
        case name
        case url
        case width
        case height
        
        var string : String {
            return self.rawValue
        }
    }
}
