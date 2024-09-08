//
//  SyncManager.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 30/12/2019.
//  Copyright © 2019 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper
import Alamofire

class SyncManager {
    
    static let shared: SyncManager = SyncManager()
    
    // MARK: - Constant
    static let userDefaultCats: String = "userDefaultsCats"
    static let userDefaultArrayQueue: String = "userDefaultArrayQueue"
    
    // MARK: - Variable
    let worker = SyncWorker()
    var busy: Bool = false {
        didSet {
             UIApplication.shared.isNetworkActivityIndicatorVisible = busy
        }
    }
    
    fileprivate init() {
        
    }
    
    // MARK: - SyncroCatModel
    fileprivate var _syncroCatsModel: [SyncroCatModel]?
    fileprivate var syncroCatsModel: [SyncroCatModel]? {
        get {
            if _syncroCatsModel == nil {
                guard let jsonData = UserDefaults.standard.object(forKey: SyncManager.userDefaultCats) as? Data else {
                    return nil
                }
                
                _syncroCatsModel = try? JSONDecoder().decode([SyncroCatModel].self, from: jsonData)
            }
            return _syncroCatsModel
        }
        set {
            guard let cats = newValue else {
                UserDefaults.standard.removeObject(forKey: SyncManager.userDefaultCats)
                _syncroCatsModel = nil
                return
            }
            
            if let encoded = try? JSONEncoder().encode(cats) {
                UserDefaults.standard.set(encoded, forKey: SyncManager.userDefaultCats)
            }
            
            _syncroCatsModel = cats
        }
    }
    
    public func storeCatsModel(_ newValue: [SyncroCatModel]?) {
        self.syncroCatsModel = newValue
    }
    
    func fetchCats(completion: @escaping (_ result : Result<[SyncroCatModel], Error>)->()) {
        
        // Check if no internet pass stored Cats Model
        if Connectivity.shared.hasNoNetwork, let catsModel = self.syncroCatsModel {
            completion(.success(catsModel))
            return
        }
        
        worker.fetchCats { [weak self] workerResult in
            switch workerResult {
            case .success(let cats):
                self?.syncroCatsModel = cats
                completion(.success(cats))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Array Queue
    fileprivate var _queue: SynchronizedArray<SyncroItem>?
    fileprivate var queue: SynchronizedArray<SyncroItem> {
        get {
            
            if _queue == nil {
                guard let jsonData = UserDefaults.standard.object(forKey: SyncManager.userDefaultArrayQueue) as? Data,
                      let items = try? JSONDecoder().decode([SyncroItem].self, from: jsonData) else {
                    _queue = SynchronizedArray<SyncroItem>()
                    return _queue!
                }
                
                let syncArr = SynchronizedArray<SyncroItem>()
                syncArr.append(items)
                
                _queue = syncArr
            }
            
            return _queue!
        }
        
        set {
            _queue = newValue
        }
    }
    
    var syncFinished: Bool {
        return self.queue.isEmpty
    }
    
    // MARK: - Add & Save SyncItem
    func addToSyncQueue(_ syncroItem: SyncroItem) -> Self {
        self.queue.append(syncroItem)
        return self
    }
    
    func saveSyncQueue() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveSyncQueue"), object: nil)
        
        self.saveUserDefaultAllQueueItems()
        self.syncronize()
    }
    
    private func saveUserDefaultAllQueueItems() {
        let allQueues: [SyncroItem] = queue.all
        let encoded = try? JSONEncoder().encode(allQueues)
        UserDefaults.standard.set(encoded, forKey: SyncManager.userDefaultArrayQueue)
    }
    
    // MARK: - Syncronize
    func syncronize(_ completion: ((_ success: Bool)->())? = nil) {
        
        if busy {
            return
        }
        busy = true
        
        guard let item = queue.first else {
            busy = false
            completion?(true)
            return
        }
        
        self.worker.handleSendSync("", item) { [weak self] (result) in
            switch result {
                case .success(_):
                    if (self?.queue.count ?? 0) > 0 {
                        self?.queue.remove(at: 0)
                    }
                    self?.saveUserDefaultAllQueueItems()
                    self?.busy = false

                    // If Sync Finish Notif
                    if self?.syncFinished == true {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "syncFinished"), object: nil)
                    }

                    self?.syncronize(completion)
                case .failure(_):
                    self?.busy = false
                    completion?(false)
            }
        }
    }
    
    // MARK: - Clean
    func clean() {
        self.queue = SynchronizedArray<SyncroItem>()
        UserDefaults.standard.removeObject(forKey: SyncManager.userDefaultArrayQueue)
        self.syncroCatsModel = nil
        self.busy = false
    }
}
