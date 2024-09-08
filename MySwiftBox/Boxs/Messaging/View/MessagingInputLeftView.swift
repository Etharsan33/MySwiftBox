import Foundation
import UIKit
import MySwiftSpeedUpTools

class MessagingInputLeftView: BaseInstanceView {
    @IBOutlet weak var showModelButton: UIButton!
    
    var onShowModel : (()->())?
    
    //MARK: - Action
    
    @IBAction func showPictures(_ sender: Any) {
        self.onShowModel?()
    }
}
