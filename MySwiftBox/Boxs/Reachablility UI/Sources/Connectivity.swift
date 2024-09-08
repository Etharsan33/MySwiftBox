//
//  Connectivity.swift
//  Gestteam
//
//  Created by ELANKUMARAN Tharsan on 16/01/2020.
//  Copyright © 2020 Innovantic. All rights reserved.
//

import UIKit
import Alamofire

class Connectivity {
    
    static let shared = Connectivity()
    let reachabilityManager = NetworkReachabilityManager()
    
    init() {
        reachabilityManager?.startListening(onUpdatePerforming: { _ in
            NotificationCenter.default.post(name: .reachabilityUIRefresh, object: nil)
        })
    }
    
    deinit {
        reachabilityManager?.stopListening()
    }
    
    var hasNoNetwork: Bool {
        return reachabilityManager?.isReachable == false
    }
}


