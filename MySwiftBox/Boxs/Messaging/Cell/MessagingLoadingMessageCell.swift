import Foundation
import UIKit

open class MessagingLoadingMessageCell : MessagingBaseMessageCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    open override func updateView() {
        
        activityIndicator?.startAnimating()
        activityIndicator?.color = UIColor.green
    }
}
