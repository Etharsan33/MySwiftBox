//
//  StickyTopCollectionViewCell.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 19/06/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

class StickyTopCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        borderView?.backgroundColor = .systemBlue
        
        dateLabel?.textColor = .black
        dateLabel?.font = .boldSystemFont(ofSize: 15)
        hourLabel?.textColor = .lightGray
        hourLabel?.font = .boldSystemFont(ofSize: 15)
    }
}
