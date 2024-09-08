//
//  SyncWorker.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 30/12/2019.
//  Copyright © 2019 Elankumaran Tharsan. All rights reserved.
//

import Foundation
import Alamofire

protocol SyncWorkerProtocol {
    func fetchCats(completion: @escaping (_ : Result<[SyncroCatModel], Error>) -> Void)
    func handleSendSync(_ id: String, _ item: SyncroItem, completion: @escaping (Result<Bool, Error>) -> Void)
}

struct SyncWorker: SyncWorkerProtocol {
    
    func fetchCats(completion: @escaping (Result<[SyncroCatModel], Error>) -> Void) {
        struct FetchData: Decodable {
            let all: [SyncroCatModel]
        }
        
        AF.request("https://cat-fact.herokuapp.com/facts").responseDecodable(of: FetchData.self) { response in
            switch response.result {
            case .success(let fetchData):
                completion(.success(fetchData.all))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func handleSendSync(_ id: String, _ item: SyncroItem, completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(true))
    }
    
}
