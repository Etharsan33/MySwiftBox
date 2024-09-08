import Foundation

open class BaseWidget {
    
    public init(){}
    
    public required init(model : BaseModel){
        
    }
    
    open class func registerForModel(modelType : BaseModel.Type) {
        ModelToWidgetMapping.shared.register(modelType: modelType, widgetType: self)
    }
}
