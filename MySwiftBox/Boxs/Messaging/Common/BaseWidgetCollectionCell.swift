import Foundation
import UIKit

open class BaseWidgetCollectionCell : UICollectionViewCell {
    
    open var widget : BaseWidget? {
        didSet {
            self.updateView()
        }
    }
    
    class public func registerForWidget(widgetType :BaseWidget.Type) {
        WidgetToViewerMapping.shared.register(widgetType: widgetType , viewerType: self)
    }
    
    open func updateView() {
        
    }
}
