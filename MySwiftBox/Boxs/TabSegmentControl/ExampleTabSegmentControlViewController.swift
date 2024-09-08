//
//  ExampleTabSegmentControlViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 17/10/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class ExampleTabSegmentControlViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var barView: UIView!
    
    let selectionBar: UIView = UIView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TabSegmentControl"
        
        // Custom segmentControl
        self.segmentControl.tintColor = .clear
        let textSelAttr: [NSAttributedString.Key: Any] = [.foregroundColor : UIColor.black, .font : UIFont.systemFont(ofSize: 14)]
        let textNotSelAttr: [NSAttributedString.Key: Any] = [.foregroundColor : UIColor.lightGray, .font : UIFont.systemFont(ofSize: 14)]
        segmentControl.setTitleTextAttributes(textSelAttr, for: .normal)
        segmentControl.setTitleTextAttributes(textNotSelAttr, for: .selected)
        
        (0...2).forEach { i in
            segmentControl.setTitle("Tab \(i)", forSegmentAt: i)
        }
        
        segmentControl.setBackgroundImage(UIImage(color: .clear), for: .normal, barMetrics: .default)
        segmentControl.setDividerImage(UIImage(color: .clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // add initial selection bar
        placeSelectionBar()
        self.barView.addSubview(self.selectionBar)
    }
    
    // MARK: - Private
    private func placeSelectionBar() {
        self.selectionBar.frame = CGRect(x: 0, y: 0, width: self.segmentControl.frame.size.width/CGFloat(self.segmentControl.numberOfSegments), height: self.barView.frame.height)
        self.selectionBar.backgroundColor = .systemPink
        var barFrame = self.selectionBar.frame
        barFrame.origin.x = barFrame.size.width * CGFloat(self.segmentControl.selectedSegmentIndex)
        self.selectionBar.frame = barFrame
    }
    
    private func animateSelectionBar() {
        if self.selectionBar.superview == nil {
            self.barView.addSubview(self.selectionBar)
            placeSelectionBar()
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.placeSelectionBar()
            })
        }
    }
    
    // MARK: - Actions
    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
        self.animateSelectionBar()
    }
}

// MARK: - Extension UIImage
public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
