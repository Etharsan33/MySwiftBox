//
//  InfiniteScrollWorker.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 28/02/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import MySwiftSpeedUpTools

struct InfiniteScrollWorker: InfiniteScrollWorkerProtocol {
    
    func fetchItems(startIndex: Int, endIndex: Int, completion: @escaping (Result<[InfiniteScrollItemModel], Error>) -> ()) {
        
        let result = JSONFile(fileName: "infiniteScrollItems")
            .decode([InfiniteScrollItemModel].self,
                    dateStrategy: .formatted(Date.ddMMyyyySeparatedBySlashFormatter))
        completion(result)
    }
}
