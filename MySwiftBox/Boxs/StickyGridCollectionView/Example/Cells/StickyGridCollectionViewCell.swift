//
//  StickyGridCollectionViewCell.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 19/06/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

class StickyGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        borderView?.backgroundColor = .systemBlue
        dataLabel?.textColor = .black
        dataLabel?.font = .boldSystemFont(ofSize: 16)
    }
}
