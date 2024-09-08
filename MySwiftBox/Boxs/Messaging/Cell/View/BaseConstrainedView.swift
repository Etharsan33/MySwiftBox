import Foundation
import UIKit
import MySwiftSpeedUpTools

class BaseConstrainedView: BaseInstanceView, ConstrainedViewProtocol {
    
    //MARK: - ConstrainedViewProtocol
    public var widthConstraint: NSLayoutConstraint!
    public var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0.0)
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 0.0)
        
        NSLayoutConstraint.activate([self.widthConstraint, self.heightConstraint])
    }
}
