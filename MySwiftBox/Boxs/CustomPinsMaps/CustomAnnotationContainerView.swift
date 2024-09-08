import MapKit
import UIKit

class CustomAnnotationContainerView: MKAnnotationView {
    
    let customView : CustomAnnotationView = CustomAnnotationView.instance
        
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        customView.frame = CGRect(x: 0, y: 0, width: 69, height: 75)
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.addSubview(customView)
        self.frame = customView.frame
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
