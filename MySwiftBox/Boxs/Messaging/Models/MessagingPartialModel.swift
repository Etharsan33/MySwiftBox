import Foundation
import ObjectMapper

public class MessagingPartialModel: BaseModel {
    
    let id              : Int
    let offset          : Int?
    let count           : Int
    let userA           : UserModel
    let userB           : UserModel
    let lastReadIndex   : Int?
    let name            : String?
    var comments        : [CommentModel]?
    
    public required init(map: Map) throws {
        
        do {
            id              = try   map.value(attributs.id.string)
            offset          = try?  map.value(attributs.offset.string)
            count           = try   map.value(attributs.count.string)
            userA           = try   map.value(attributs.userA.string)
            userB           = try   map.value(attributs.userB.string)
            lastReadIndex   = try?  map.value(attributs.lastReadIndex.string)
            name            = try?  map.value(attributs.name.string)
            
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
        
        id              >>> map[attributs.id.string]
        offset          >>> map[attributs.offset.string]
        count           >>> map[attributs.count.string]
        userA           >>> map[attributs.userA.string]
        userB           >>> map[attributs.userB.string]
        lastReadIndex   >>> map[attributs.lastReadIndex.string]
        name            >>> map[attributs.name.string]
        let context = CommentMapContext(thread : id)
        map.context = context
        comments        <-  map[attributs.comments.string]

    }
    
    enum attributs : String {
        case id
        case offset
        case count
        case userA = "user"
        case userB = "user_share"
        case lastReadIndex = "comment_info.up_to_index"
        case name
        case comments
        
        var string : String {
            return self.rawValue
        }
    }
}
