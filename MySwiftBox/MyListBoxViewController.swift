//
//  MyListBoxViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 18/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class MyListBoxViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let padding: CGFloat = 38
    
    struct Box {
        let image: UIImage
        let title: String
        let viewController: UIViewController
    }
    
    private let boxs: [Box] = [
        .init(image: #imageLiteral(resourceName: "infinite_scroll_icon"), title: "<b>Infinite Scroll</b> in CollectionView with trigger before showing the bottom", viewController: ExampleInfiniteScrollViewController.instanceCS),
        .init(image: #imageLiteral(resourceName: "custom_pins_maps_icon"), title: "<b>Custom Pins</b> in Maps with custom Annotation using MapKit", viewController: CustomPinsMapsViewController.instance),
        .init(image: #imageLiteral(resourceName: "sticky_grid_collection_view_icon"), title: "<b>Sticky Grid CollectionView</b> Grid with sticky top and left cell", viewController: ExampleStickyGridCollectionViewController.instance),
        .init(image: #imageLiteral(resourceName: "subcription_swifty_store_kit_icon"), title: "<b>Subscription with SwiftyStoreKit</b> Feature with simple one subcription pass", viewController: ExampleSubcriptionViewController.instance),
        .init(image: #imageLiteral(resourceName: "geofencing_icon"), title: "<b>Geofencing</b> with sending notification local when enter in region", viewController: ExampleGeofencingViewController.instance),
        .init(image: #imageLiteral(resourceName: "reachability_icon"), title: "<b>Reachability UI</b> with Alamofire, show bottom view when no network", viewController: ExampleReachabilityUIViewController.instance),
        .init(image: #imageLiteral(resourceName: "stl_viewer_icon"), title: "<b>STLViewer</b> load STL file from network or local and draw by taking picture", viewController: STLViewerViewController.instance),
        .init(image: #imageLiteral(resourceName: "messaging_icon"), title: "<b>Messaging</b> message app with feature send text and image", viewController: MessagingThreadViewController.instanceWithThreadId(3920)),
        .init(image: #imageLiteral(resourceName: "syncro_data_offline_icon"), title: "<b>SyncroDataOffline</b> queue stack data and refresh it when network is up", viewController: ExampleSyncroDataOfflineViewController.instance),
        .init(image: #imageLiteral(resourceName: "tab_segment_control_icon"), title: "<b>TabSegmentControl</b> custom segmentControl with bottom bar", viewController: ExampleTabSegmentControlViewController.instance)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Boxs"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        MyListBoxViewCell.registerNibFor(collectionView: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension MyListBoxViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.boxs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = MyListBoxViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
        cell.box = self.boxs[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyListBoxViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = self.boxs[indexPath.row].viewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.bounds.width / 2) - (self.padding - self.padding / 4)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.padding / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = self.padding / 2
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
