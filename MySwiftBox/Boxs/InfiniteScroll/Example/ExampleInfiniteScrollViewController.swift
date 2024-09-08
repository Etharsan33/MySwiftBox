//
//  ExampleInfiniteScrollViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 19/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

class ExampleInfiniteScrollViewController: InfinityScrollViewController, CSControllerProtocol, InfiniteScrollControllerCSProtocol, InfiniteScrollDisplayCSProtocol, EmptyViewProtocol {
    
    // MARK: - CSControllerProtocol
    func setupCS() {
        ExampleInfiniteScrollCSConfig().setup(self)
    }
    
    // MARK: - InfiniteScrollControllerCSProtocol
    var interactor: InfiniteScrollBusinessCSProtocol!
    
    typealias Item = ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation.Item
    private var items: [Item] = []
    
    private static let numberFetchItem: Int = 10
    
    override var numberFetchItem: Int {
        return ExampleInfiniteScrollViewController.numberFetchItem
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Infinite Scroll"
        self.view.backgroundColor = UIColor(hexa: "#ecf0f1")
        
        ExampleInfiniteScrollItemViewCell.registerNibFor(collectionView: collectionView)
        InfiniteScrollLoadingCollectionViewCell.registerNibFor(collectionView: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        
        self.fetchItems()

        self.onCommitReachInfinityScroll = { [weak self] in
            print("FETCH NEW")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.fetchItems(isSilently: true)
            }
        }
    }
    
    private func fetchItems(isSilently: Bool = false) {
        self.interactor.fetchItems(ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Request(startIndex: startIndex, endIndex: endIndex, isSilently: isSilently))
    }
}

// MARK: - UICollectionViewDataSource
extension ExampleInfiniteScrollViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ExampleInfiniteScrollItemViewCell.cellForCollection(collectionView: collectionView, indexPath: indexPath)
        cell.item = self.items[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ExampleInfiniteScrollViewController {
    
    // Size Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 30, height: ExampleInfiniteScrollItemViewCell.preferredHeight)
    }
}

// MARK: - CalendarListDisplayCSProtocol
extension ExampleInfiniteScrollViewController {
    
    func displayItems(_ presentation: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation) {
        self.emptyViewState = .none
        
        let isFirstTimeLoad = (self.total == nil)
        
        if presentation.total == 0 {
            self.emptyViewState = .empty
        }
        
        self.total = presentation.total
        
        func storeItems() {
            self.items.append(contentsOf: presentation.items)
        }
        
        if isFirstTimeLoad {
            self.items.removeAll()
            storeItems()
            self.startIndex = presentation.startIndex
            self.endIndex = presentation.endIndex
            self.collectionView.reloadData()
        } else {
            storeItems()
            self.collectionView.reloadData()
        }
    }
    
    func displayLoading() {
        self.emptyViewState = .loading
    }
    
    func displayError(_ error: Error) {
        let isFirstTimeLoad = (self.total == nil)
        
        if isFirstTimeLoad {
            self.emptyViewState = .error(.withMsg(error.localizedDescription))
        } else {
            self.emptyViewState = .none
            self.showAlert(title: nil, message: error.localizedDescription)
        }
    }
}

// MARK: - EmptyViewProtocol
extension ExampleInfiniteScrollViewController {
    
    //** EmptyViewProtocol
    var emptyViewContainer: UIView? {
        return self.collectionView
    }
    var emptyViewBackgroundColor: UIColor? {
        return .clear
    }
    var emptyViewText: String? {
        return "No data"
    }
    var emptyViewImage: UIImage? {
        return nil
    }
    var emptyViewTryAgainBackgroundColor: UIColor? {
        return .systemRed
    }
    var emptyViewFont: UIFont? {
        return .systemFont(ofSize: 16)
    }
    var emptyViewTextColor: UIColor? {
        return .black
    }
    var emptyViewLoaderColor: UIColor? {
        return .black
    }
    func emptyViewTryAgainAction() {
        self.fetchItems()
    }
    //***//
}
