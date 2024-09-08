import Foundation
import UIKit
import MySwiftSpeedUpTools

class MessagingInputRightView: BaseInstanceView {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.color = UIColor.red
        }
    }
    
    var loading = false {
        didSet {
            sendButton.isHidden = loading
            activityIndicator.isHidden = !loading
        }
    }
    
    var onSend: (()->())?
    
    //MARK: - Action
    @IBAction func send(_ sender: Any) {
        self.onSend?()
    }
    
}
