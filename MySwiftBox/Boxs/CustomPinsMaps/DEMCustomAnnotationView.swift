//
//  DEMCustomAnnotationView.swift
//  Demeter
//
//  Created by ELANKUMARAN Tharsan on 11/06/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import MapKit
import UIKit

class
IView {
    
    @IBOutlet private weak var bgView: UIView!
    @IBOutlet private weak var pinImgView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    var pinColor : UIColor? {
        didSet {
            pinImgView?.tintColor = pinColor ?? .systemRed
        }
    }

    var text : String? {
        didSet {
            textLabel?.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView?.backgroundColor = .systemBlue
        textLabel?.font = .boldSystemFont(ofSize: 17)
        textLabel?.textColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.setCornerRadius(bgView.frame.height/2)
    }
}
