

import UIKit
import ObjectMapper

class UserModel: BaseModel {
    
    let id: Int
    let email: String?
    let name: String?
    let firstname: String?
    let language: String?
    let role: String?
    let login: String?
    
    func getFullname() -> String? {
        if let firstname = firstname, let lastname = name {
            return lastname.uppercased() + " " + firstname
        }
        return name
    }
    
    public required init(map: Map) throws {
        do {
            id = try map.value(attributs.id.string)
            email = try? map.value(attributs.email.string)
            name = try? map.value(attributs.name.string)
            firstname = try? map.value(attributs.firstname.string)
            language = try? map.value(attributs.language.string)
            role = try? map.value(attributs.role.string)
            login = try? map.value(attributs.login.string)
            
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
        email >>> map[attributs.email.string]
        name >>> map[attributs.name.string]
        firstname >>> map[attributs.firstname.string]
        language >>> map[attributs.language.string]
        role >>> map[attributs.role.string]
        login >>> map[attributs.login.string]
    }
    
    enum attributs: String {
        case id
        case email
        case name
        case firstname
        case language
        case role
        case login
        
        var string : String {
            return self.rawValue
        }
    }
}
