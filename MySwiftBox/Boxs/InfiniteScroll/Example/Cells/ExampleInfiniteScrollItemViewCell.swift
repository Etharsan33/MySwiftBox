//
//  ExampleInfiniteScrollItemViewCell.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 19/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class ExampleInfiniteScrollItemViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dayTextLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    public static let preferredHeight: CGFloat = 123
    
    var item: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation.Item? {
        didSet {
            self.presentationToViews()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.dayNumberLabel.text = " "
        self.dayTextLabel.text = " "
        self.titleLabel.text = " "
        self.dateRangeLabel.text = " "
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dayNumberLabel.font = .boldSystemFont(ofSize: 40)
        self.dayTextLabel.font = .systemFont(ofSize: 24)
        self.dateRangeLabel.font = .systemFont(ofSize: 13)
        self.titleLabel.font = .boldSystemFont(ofSize: 17)
        self.dateRangeLabel.textColor = .lightGray
        self.dayNumberLabel.textColor = .systemOrange
        self.dayTextLabel.textColor = .systemOrange
    }
    
    private func presentationToViews() {
        self.dayNumberLabel.text = item?.dayNumber
        self.dayTextLabel.text = item?.day
        self.titleLabel.text = item?.title
        self.dateRangeLabel.text = "Une date"
    }
}
