//
//  ExampleInfiniteScrollCSConfig.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 19/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

//MARK: - Interactor

protocol InfiniteScrollBusinessCSProtocol {
    func fetchItems(_ request: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Request)
}

protocol InfiniteScrollInteractorCSProtocol {
    var presenter : InfiniteScrollPresentationCSProtocol! {get}
    var worker: InfiniteScrollWorkerProtocol! {get}
}

//MARK: - Presenter

protocol InfiniteScrollPresentationCSProtocol {
    func presentItems(response: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Response)
    func presentLoading()
}

protocol InfiniteScrollPresenterCSProtocol {
    var controller : InfiniteScrollDisplayCSProtocol! {get}
}


//MARK: - Controller

protocol InfiniteScrollDisplayCSProtocol : class {
    func displayItems(_ presentation: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation)
    func displayLoading()
    func displayError(_ error: Error)
}

protocol InfiniteScrollControllerCSProtocol {
    var interactor : InfiniteScrollBusinessCSProtocol! {get}
}

class ExampleInfiniteScrollCSConfig {
    
    //MARK: - Setup
    func setup(_ controller : ExampleInfiniteScrollViewController) {
        
        let interactor = InfiniteScrollInteractor()
        let presenter = InfiniteScrollPresenter()
        
        //Controller
        controller.interactor = interactor
        
        //Interactor
        interactor.presenter = presenter
        interactor.worker = InfiniteScrollWorker()
        
        //Presenter
        presenter.controller = controller
    }
    
    //MARK: - DataModel
    struct DataModels {
        
        //MARK: - FetchItems
        struct FetchItems {
            
            struct Request {
                var startIndex: Int
                var endIndex: Int
                var isSilently: Bool = false
            }
            
            struct Response {
                var result : Result<[InfiniteScrollItemModel], Error>
            }
            
            struct Presentation {
                struct Item {
                    var id: String
                    var dayNumber: String
                    var day: String
                    var title: String
                }
                
                var total: Int
                var startIndex: Int
                var endIndex: Int
                var items: [Item]
            }
        }
    }
}

