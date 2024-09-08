import Foundation

public protocol MessagingDataHandlerDelegate : class {
    func messagingDataHandlerDidUpdatePartialItems(channelDataHandler : MessagingDataHandler)
    func messagingDataHandlerDidUpdatePartial(channelDataHandler : MessagingDataHandler, partial : MessagingPartialModel)
}

public class MessagingDataHandler {
    
    var partial : MessagingPartialModel
    var loader : MessagingPartialLoader?
    weak var delegate : MessagingDataHandlerDelegate?
    
    var count : Int {
        return partial.count
    }
    
    init(partial : MessagingPartialModel,
         delegate : MessagingDataHandlerDelegate?) {
        
        self.partial = partial
        self.delegate = delegate
        
        self.loader = MessagingPartialLoader(partial: partial, onPartialUpdate: { [weak self] (messagingPartialModel) in
            
            guard let strongSelf = self else {return}
            
            strongSelf.delegate?.messagingDataHandlerDidUpdatePartial(channelDataHandler: strongSelf, partial: messagingPartialModel)
            
            }, onPartialItemsUpdate: { [weak self] in
                
                guard let strongSelf = self else {return}
                
                strongSelf.delegate?.messagingDataHandlerDidUpdatePartialItems(channelDataHandler: strongSelf)
        })
        
    }
    
    public func itemAtIndex(index : Int, fetch : Bool = true) -> MessagingBaseMessageWidget? {
        
        if index < 0 { return nil }
        
        if let loader = self.loader {
            
            if let messageItem = loader.getItemAtIndex(/*(loader.total - */index/* - 1)*/, fetch: fetch) {
                return ModelToWidgetMapping.shared.map(messageItem) as? MessagingBaseMessageWidget
            }
        }
        
        if !fetch {
            return nil
        }
        // we return a widget corresponding to the an empty item (this widget will be replaced later when the real item is loaded)
        return MessagingLoadingMessageWidget(model: BaseModel())
            
    }
    
    static public func viewerTypeForWidget(_ widget : MessagingBaseMessageWidget) -> BaseWidgetCollectionCell.Type {
        return WidgetToViewerMapping.shared.viewerTypeForWidget(widget) ?? BaseWidgetCollectionCell.self
    }
}
