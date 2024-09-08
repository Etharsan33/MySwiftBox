//
//  ExampleStickyGridCollectionViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 19/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class ExampleStickyGridCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout!
    
    struct ImageWithValues {
        let image: UIImage
        let values: [String]
    }
    private var values: [ImageWithValues] = []
    
    struct TopValue {
        let hour: String
        let date: String
    }
    private var topValues: [TopValue] = []
    
    private var previousContentOffset: CGPoint?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StickyGridCollection"
        self.navigationItem.largeTitleDisplayMode = .never
        
        StickyTopCollectionViewCell.registerNibFor(collectionView: gridCollectionView)
        StickyLeftCollectionViewCell.registerNibFor(collectionView: gridCollectionView)
        StickyGridCollectionViewCell.registerNibFor(collectionView: gridCollectionView)
        
        gridCollectionView.bounces = false
        gridCollectionView.isDirectionalLockEnabled = true
        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self
        
        gridLayout.stickyRowsCount = 1
        gridLayout.stickyColumnsCount = 1
        
        // Set Data
        for i in 0...18 {
            self.values.append(.init(image: #imageLiteral(resourceName: "left_grid_icon"), values: ["1.\(i)", "2.\(i)", "3.\(i)", "4.\(i)"]))
        }
        
        for i in 1...6 {
            self.topValues.append(.init(hour: "\(i):00", date: "2\(i)/03"))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ExampleStickyGridCollectionViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.values.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.values.isEmpty {
            return 0
        }
        
        return self.topValues.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //** If sticky
        if gridLayout.isItemSticky(at: indexPath) {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let stickyLeftCell = StickyLeftCollectionViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
                    stickyLeftCell.imageView?.image = #imageLiteral(resourceName: "sticky_grid_collection_view_icon").withRenderingMode(.alwaysOriginal)
                    return stickyLeftCell
                }
                let cellTop = StickyTopCollectionViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
                cellTop.dateLabel?.text = self.topValues[indexPath.row - 1].date
                cellTop.hourLabel?.text = self.topValues[indexPath.row - 1].hour
                
                return cellTop
            }
    
            let stickyLeftCell = StickyLeftCollectionViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
            stickyLeftCell.imageView?.image = self.values[indexPath.section - 1].image.withRenderingMode(.alwaysTemplate)
            stickyLeftCell.imageView?.tintColor = .white
            return stickyLeftCell
        }
        //****//
        
        let cell = StickyGridCollectionViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
        
        if indexPath.row <= self.values[indexPath.section - 1].values.count {
            cell.dataLabel.text = self.values[indexPath.section - 1].values[indexPath.row - 1]
        } else {
            cell.dataLabel.text = "--"
        }
        
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExampleStickyGridCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if gridLayout.isItemSticky(at: indexPath) {
            if indexPath.section == 0 {
                return CGSize(width: 100, height: 80)
            }
            return CGSize(width: 100, height: 70)
        }
        
        return CGSize(width: 100, height: 70)
    }
    
//    //**** Disable scrolling diagonal
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        previousContentOffset = scrollView.contentOffset
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let prevOff = previousContentOffset, scrollView.contentOffset.x != previousContentOffset?.x {
//            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: prevOff.y)
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.previousContentOffset = scrollView.contentOffset
//    }
//    //*****//
}
