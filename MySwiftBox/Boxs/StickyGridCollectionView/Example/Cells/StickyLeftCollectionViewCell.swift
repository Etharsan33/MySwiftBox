//
//  StickyLeftCollectionViewCell.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 19/06/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

class StickyLeftCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradiantView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.systemBlue
        
        self.gradiantView?.layer.sublayers?.map({$0 as? CAGradientLayer}).forEach({$0?.removeFromSuperlayer()})
        self.gradiantView?.backgroundColor = .white
        addLeftToRightGradiantLayer()
    }
    
    private func addLeftToRightGradiantLayer() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: 4, height: self.frame.height)
        layer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        layer.opacity = 0.2
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        self.gradiantView?.layer.insertSublayer(layer, at: 0)
    }
}
