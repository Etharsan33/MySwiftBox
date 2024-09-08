//
//  ExampleSyncroDataOfflineViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 17/10/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

class ExampleSyncroDataOfflineViewController: UIViewController, UITableViewDataSource, EmptyViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var cats: [SyncroCatModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SyncroDataOffline"
        self.tableView.dataSource = self
        
        self.fetchCats()
    }
    
    private func fetchCats() {
        self.emptyViewState = .loading
        
        SyncManager.shared.fetchCats { [weak self] result in
            self?.emptyViewState = .none
            switch result {
            case .success(let cats):
                self?.cats = cats
            case .failure(let error):
                self?.emptyViewState = .error(.withMsg(error.localizedDescription))
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ExampleSyncroDataOfflineViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = self.cats[indexPath.row].text
        return cell
    }
}

// MARK: - EmptyViewProtocol
extension ExampleSyncroDataOfflineViewController {
    var emptyViewContainer: UIView? {
        return self.tableView
    }
    
    var emptyViewText: String? {
        return nil
    }
    
    func emptyViewTryAgainAction() {
        self.fetchCats()
    }
}
