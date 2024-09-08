//
//  InfiniteScrollInteractor.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 28/02/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

protocol InfiniteScrollWorkerProtocol {
    func fetchItems(startIndex: Int, endIndex: Int, completion: @escaping (_: Result<[InfiniteScrollItemModel], Error>)->())
}

class InfiniteScrollInteractor: InfiniteScrollInteractorCSProtocol, InfiniteScrollBusinessCSProtocol {
    
    // MARK: - InfiniteScrollInteractorCSProtocol
    var presenter: InfiniteScrollPresentationCSProtocol!
    var worker: InfiniteScrollWorkerProtocol!
    
    // MARK: - InfiniteScrollBusinessCSProtocol
    func fetchItems(_ request: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Request) {
        
        if !request.isSilently {
            self.presenter.presentLoading()
        }
        
        self.worker.fetchItems(startIndex: request.startIndex, endIndex: request.endIndex) { [weak self] (result) in
            self?.presenter.presentItems(response: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Response(result: result))
        }
    }
}
