import Foundation
import UIKit

class MessagingFileThumbnailConstrainedView: BaseConstrainedView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.textColor = .white
    }
}
