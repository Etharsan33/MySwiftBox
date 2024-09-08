//
//  InfiniteScrollPresenter.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 28/02/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

class InfiniteScrollPresenter: InfiniteScrollPresenterCSProtocol, InfiniteScrollPresentationCSProtocol {
    
    // MARK: - InfiniteScrollPresenterCSProtocol
    var controller: InfiniteScrollDisplayCSProtocol!
    
    // MARK: - InfiniteScrollPresentationCSProtocol
    func presentItems(response: ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Response) {
        switch response.result {
        case .success(let itemsModel):
            self.controller.displayItems(ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation(
                total: 40,
                startIndex: 0,
                endIndex: 10,
                items: itemsModel.map(self.itemToPresentation(_:))
            ))
        case .failure(let error):
            self.controller.displayError(error)
        }
    }
    
    func presentLoading() {
        self.controller.displayLoading()
    }
    
    // MARK: - Transform
    typealias InfiniteScrollItem = ExampleInfiniteScrollCSConfig.DataModels.FetchItems.Presentation.Item
    func itemToPresentation(_ item: InfiniteScrollItemModel) -> InfiniteScrollItem {
        let date = item.date
        return InfiniteScrollItem(
            id: item.slug,
            dayNumber: date.day,
            day: date.weekDay.prefix(3).uppercased(),
            title: item.title
        )
    }
}
