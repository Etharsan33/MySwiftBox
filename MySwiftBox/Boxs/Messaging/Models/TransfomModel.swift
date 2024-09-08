import Foundation
import ObjectMapper

/// A simple model from which all models should have as parent
public class TransfomModel: Mappable {
    
    public var transformDateFromISO8601 = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
        guard let value = value else { return nil }
        
        return value.dateFromISO8601
        
    }, toJSON: { (value: Date?) -> String? in
        guard let value = value else { return nil }
        return value.iso8601
    })
    
    public init() {}
    
    public required convenience init?(map: Map) {
        self.init()
    }
    
    open func mapping(map: Map) {
        //
    }
}
