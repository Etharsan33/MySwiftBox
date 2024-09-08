//
//  OfferWorker.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 31/07/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

struct OfferWorker {
  
    func getOffers(completion: @escaping ((Result<[Offer], Error>)->())) {
        let result = JSONFile(fileName: "offers").decode([Offer].self)
        completion(result)
    }
}
