import Foundation
import UIKit

protocol MessagingSimpleMessageCellDelegate : class {
    
    func messagingSimpleMessageCell(_ cell : MessagingSimpleMessageCell, didChose attachmentResource: ResourceModel, from resourcesWithSameCategory : [ResourceModel])
    
}

open class MessagingSimpleMessageCell : MessagingBaseMessageCell {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var contentToBubbleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentToBubbleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingView: UIView!
    @IBOutlet weak var trailingView: UIView!
    @IBOutlet weak var timeLabelContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var attachmentStackView: UIStackView!
    @IBOutlet weak var attachmentBg: UIView!
    @IBOutlet weak var txtViewBg: UIView!
    @IBOutlet weak var attachmentContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet var textLeadingConstraint: NSLayoutConstraint!
//    @IBOutlet var textTrailingVariableConstraint: NSLayoutConstraint!
//    @IBOutlet var textLeadingVariableConstraint: NSLayoutConstraint!
    @IBOutlet var textTrailingConstraint: NSLayoutConstraint!
    
    weak var delegate : MessagingSimpleMessageCellDelegate?
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    open override func updateView() {
        
        guard let widget = widget as? MessagingSimpleMessageWidget else {
            return
        }
        
        //Constraints
        textLeadingConstraint?.isActive = !widget.isMe
//        textTrailingVariableConstraint?.isActive = !widget.isMe
//        
//        textLeadingVariableConstraint?.isActive = widget.isMe
        textTrailingConstraint?.isActive = widget.isMe
        
        //TextView
        textView?.text = widget.text
        textView?.textColor = UIColor.black
//        textView?.setup()
        
        //Constraint
        leadingView?.isHidden = !widget.isMe
        trailingView?.isHidden = widget.isMe
        contentToBubbleLeadingConstraint?.constant = 5.0//widget.isMe ? 5.0 : 15.0
        contentToBubbleTrailingConstraint?.constant = 5.0//widget.isMe ? 15.0 : 5.0
        
        //time
        timeLabel?.text = widget.time
        timeLabel.textColor = UIColor.lightGray
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textAlignment = widget.isMe ? .right : .left
        
        //bubble
        attachmentBg.setCornerRadius(4.0)
        attachmentBg.clipsToBounds = true
        attachmentBg.backgroundColor = .white

        txtViewBg.setCornerRadius(4.0)
        txtViewBg.clipsToBounds = true
        txtViewBg.backgroundColor = widget.isMe ? .white : .systemPink

        
        self.attachmentBg?.isHidden = widget.attachmentsWithThumbnail?.isEmpty ?? true
        self.txtViewBg?.isHidden = widget.text == nil || widget.text == ""
        
        self.attachmentContainer?.isHidden = widget.attachmentsWithThumbnail?.isEmpty ?? true
        self.textContainer?.isHidden = widget.text == nil || widget.text == ""

        //Attachment
        self.addAttachments(widget: widget)
        
        self.layoutIfNeeded()
    }
    
    fileprivate func addAttachments(widget : MessagingSimpleMessageWidget) {
        
        var contentMaxWidth = (widget.attachedCellMaxWidth! * (260/335)) - (contentToBubbleLeadingConstraint?.constant ?? 0) - (contentToBubbleTrailingConstraint?.constant ?? 0)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            contentMaxWidth = contentMaxWidth/2
        }
        
        attachmentStackView.removeAllArrangedSubviews()
        
        widget.attachmentsWithThumbnail?.forEach({ (constrainedViewProtocol, messagingAttachmentWithThumbnail) in
            
            attachmentStackView?.addArrangedSubview(constrainedViewProtocol as! UIView)
            constrainedViewProtocol.heightConstraint.constant = self.imageAttachmentHeight(width: contentMaxWidth, ratio: messagingAttachmentWithThumbnail.thumbnailRatio)
            constrainedViewProtocol.widthConstraint.constant = contentMaxWidth
            
            (constrainedViewProtocol as! UIView).addTapGestureRecognizer {
                let resource = messagingAttachmentWithThumbnail.resource
                self.delegate?.messagingSimpleMessageCell(self, didChose: resource, from: [])
            }
        })
    }
    
    fileprivate func imageAttachmentHeight(width: CGFloat, ratio: Double) -> CGFloat {
        
        return width * CGFloat(ratio)
        
    }
}
