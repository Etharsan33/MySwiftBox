import UIKit

open class MessagingBaseMessageWidget: BaseWidget, MessagingWidgetIdentifierProtocol {
    
    public var identifier: Int = -1
    
    /// date of the message
    let date : Date
    
    /// Max width used to display the cell (defined at display time)
    var attachedCellMaxWidth : CGFloat?
    
    public required init(model: BaseModel) {
        
        if let m = model as? CommentModel {
            self.date = m.created_at
            self.identifier = m.id
        }else {
            self.date = Date()
        }
        
        
        super.init(model: model)
    }
    
}
