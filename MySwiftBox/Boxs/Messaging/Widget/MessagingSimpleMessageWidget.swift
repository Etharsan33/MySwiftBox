import Foundation
import UIKit

open class MessagingSimpleMessageWidget : MessagingBaseMessageWidget, MessagingWidgetNewMessageDividerProtocol, MessagingWidgetDateProtocol {
    
    public struct MessagingAttachmentWithThumbnail {
        let name : String?
        let thumbnailRatio : Double
        let resource : ResourceModel
    }
    
    public struct MessagingAttachmentWithoutThumbnail {
        let name : String?
        let resource : ResourceModel
    }
    
    /// message text
    let text: String?
    /// collection attachment and display view with thumbnail
    let attachmentsWithThumbnail: [(ConstrainedViewProtocol, MessagingAttachmentWithThumbnail)]?
//    /// /// collection attachment and display view without thumbnail
//    let attachmentsWithoutThumbnail: [(ConstrainedViewProtocol, MessagingAttachmentWithoutThumbnail)]?
    /// date time of the message
    let time: String
    /// nil if user, Contact id otherwise
    let author  : UserModel
    /// if user is the author of the message
    var isMe : Bool {
        return author.id == UserManager.shared.id
    }
    let thread : Int
    
    //MARK: MessagingWidgetNewMessageDividerProtocol
    public var showNewMessageDivider: Bool = false
    public var numberOfNewMessages: Int = 0
    
    //MARK: MessagingWidgetDateProtocol
    public var previousMessageDate: Date?
        
    //MARK: -
    
    public required init(model: BaseModel) {
        
        let m = model as! CommentModel
    
        self.author = m.user
        self.text = m.data?.content
        self.time = m.created_at.messageTimeStyle
        self.thread = m.thread
        if let uuid = m.data?.attachment {
            
            var thumbnailUrlId = uuid
            if let identifier = m.data?.attachment_thumbnail {
                thumbnailUrlId = identifier
            }
            
            let view = ImageViewConstrained.instance
//            ResourcesManager.shared.loadImageWithUrl(imageViewer: view.imageView, placeholder: #imageLiteral(resourceName: "placeholder"), url: thumbnailUrl, completionHandler: nil)
            view.imageView.backgroundColor = UIColor.white
            view.backgroundColor = .clear
            view.imageView.setCornerRadius(4.0)
            
            let thumbnailRatio = 1.0
            
            var resourceSize : CGSize? = nil
            if let height = m.data?.height, let width = m.data?.width {
                resourceSize = CGSize(width: width, height: height)
            }
//            let imageUrl = ResourcesManager.shared.serverUrlForImageWithIdentifier(uuid, thread: thread)
            let imageUrl = "https:"
            let attachment = (view as ConstrainedViewProtocol, MessagingAttachmentWithThumbnail(name: nil, thumbnailRatio: thumbnailRatio, resource: ResourceModel(name: nil, url: imageUrl, size: resourceSize)!))
            
            attachmentsWithThumbnail = [attachment]
        }else {
            attachmentsWithThumbnail = nil
        }
        
        super.init(model: model)
        
    }
}
