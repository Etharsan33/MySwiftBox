import Foundation
import UIKit

public protocol ConstrainedViewProtocol : class {
    
    var widthConstraint : NSLayoutConstraint! {get}
    var heightConstraint : NSLayoutConstraint! {get}
}

extension ConstrainedViewProtocol where Self: UIView {
    
}
