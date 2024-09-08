//
//  MyListBoxViewCell.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 18/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

class MyListBoxViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var box: MyListBoxViewController.Box! {
        didSet {
            self.setModelToViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.tintColor = UIColor(hexa: "#f1c40f")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.setCornerRadius(8)
        self.setShadowLayer()
    }
    
    private func setModelToViews() {
        self.imageView.image = box.image.withRenderingMode(.alwaysTemplate)
        self.titleLabel.attributedText = box.title.readableHTML(stylesCSS: [
            .init(balise: .body, fontSize: 13, customCSS: "text-align: center;")
        ])
    }
}
