import Foundation

/// class responsible Model to widget mapping
public class ModelToWidgetMapping {
    
    public static let shared : ModelToWidgetMapping = ModelToWidgetMapping()
    
    struct ItemMapper {
        var modelType : BaseModel.Type?
        var widgetType : BaseWidget.Type?
    }
    
    var mappers : [ItemMapper] = []
    
    fileprivate init() {
        
    }
    
    public func register(modelType : BaseModel.Type, widgetType : BaseWidget.Type) {
        
        if let index = mappers.firstIndex(where: {$0.modelType == modelType}) {
            mappers.remove(at: index)
        }
        
        mappers.append(ItemMapper(modelType: modelType, widgetType: widgetType))
    }
    
    public func map(_ model : BaseModel) -> BaseWidget? {
        
        let index = mappers.firstIndex { (item : ItemMapper) -> Bool in
            
            return type(of:model) == item.modelType
        }
        
        guard let idx = index, let widgetType = self.mappers[idx].widgetType else {
            print("No mapper found for model : \(model)")
            return nil
        }
        
        let widget = widgetType.init(model: model)
        
        return widget
        
    }
    
    func map(_ modelType : BaseModel.Type) -> BaseWidget.Type? {
        let item = mappers.first { (item : ItemMapper) -> Bool in
            modelType == item.modelType
        }
        
        return item?.widgetType
    }
}

/// class responsible Widget to Viewer mapping
public class WidgetToViewerMapping {
    
    public static let shared : WidgetToViewerMapping = WidgetToViewerMapping()
    
    var mappers : [WidgetMapper] = []
    
    struct WidgetMapper {
        var widgetType : BaseWidget.Type?
        var viewer : BaseWidgetCollectionCell.Type?
    }
    
    public func register(widgetType : BaseWidget.Type, viewerType : BaseWidgetCollectionCell.Type) {
        
        if let index = mappers.firstIndex(where: {$0.widgetType == widgetType}) {
            mappers.remove(at: index)
        }
        
        mappers.append(WidgetMapper(widgetType: widgetType, viewer: viewerType))
    }
    
    public func viewerTypeForWidget(_ widget : BaseWidget) -> BaseWidgetCollectionCell.Type? {
        
        let index = mappers.firstIndex { (widgetMapper : WidgetMapper) -> Bool in
            return type(of: widget) == widgetMapper.widgetType
        }
        
        guard let idx = index else {
            print("No mapper found for widget : \(widget)")
            return nil
        }
        
        return self.mappers[idx].viewer
    }
    
    public var registeredWidgetViewers : [BaseWidgetCollectionCell.Type] {
        
        return mappers.map{ return $0.viewer }.compactMap{ $0 }
        
    }
}
