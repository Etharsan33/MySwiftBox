//
//  IAPConfiguration.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 20/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation

struct IAPConfiguration {
    
    static let secretKey = ""
    static let annualPassKey = ""
}

extension Notification.Name {
    public static let iAPManagerFinishPurchaseOrRestore = Notification.Name(rawValue: "MySwiftBox.iAPManagerFinishPurchaseOrRestore")
    public static let iAPManagerFinishWorking = Notification.Name(rawValue: "MySwiftBox.iAPManagerFinishWorking")
}
