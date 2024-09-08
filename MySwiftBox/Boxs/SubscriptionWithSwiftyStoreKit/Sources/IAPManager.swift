//
//  IAPManager.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 06/08/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import SwiftyStoreKit
import UIKit

// MARK: - IAPManager
public class IAPManager: NSObject  {
    
    static let shared = IAPManager()
    
    public var expireDate = Date()
    public var isPurchased: Bool? = nil
    public var price: NSDecimalNumber = 19.90
    public var isWorking = false
    
    func startObserverTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            purchases.forEach { purchase in
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    NotificationCenter.default.post(name: .iAPManagerFinishPurchaseOrRestore, object: nil)
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
    }
    
    func fetchDataInBackground() {
        self.isWorking = true
        getProductsInfo { [weak self] result in
            switch result {
            case .success(_):
                self?.verifyPurchase { _ in
                    self?.isWorking = false
                    NotificationCenter.default.post(name: .iAPManagerFinishWorking, object: nil)
                }
            case .failure(_):
                self?.isWorking = false
                NotificationCenter.default.post(name: .iAPManagerFinishWorking, object: nil)
            }
        }
    }
    
    func getProductsInfo(_ completion: @escaping ((Result<Bool, Error>)->())) {
        SwiftyStoreKit.retrieveProductsInfo([IAPConfiguration.annualPassKey]) { result in
            if let error = result.error {
                completion(.failure(error))
                return
            }
            
            if let product = result.retrievedProducts.first {
                self.price = product.price
            }
            completion(.success(true))
        }
    }
    
    enum VerifyPurchaseError: Error {
        case expiredOrNotPurchased
        case other(Error)
    }
    
    func verifyPurchase(_ completion: @escaping ((Result<Bool, VerifyPurchaseError>)->())) {
        var url: AppleReceiptValidator.VerifyReceiptURLType
        #if !DEBUG && PROD
        url = .production
        #else
        url = .sandbox
        #endif
        
        let appleValidator = AppleReceiptValidator(service: url, sharedSecret: IAPConfiguration.secretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
                case .success(let receipt):
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: IAPConfiguration.annualPassKey, inReceipt: receipt)
                    
                    switch purchaseResult {
                        case .purchased(let expireDate, _):
                            self.expireDate = expireDate
                            self.isPurchased = true
                            completion(.success(true))
                        case .expired(_,_), .notPurchased:
                            self.isPurchased = false
                            completion(.failure(.expiredOrNotPurchased))
                    }
                
                case .error(let error):
                    completion(.failure(.other(error)))
            }
        }
    }
    
    enum PurchaseError: Error {
        case cancelled
        case other(Error)
    }
    
    func purchase(_ completion: @escaping ((Result<Bool, PurchaseError>)->())) {
        SwiftyStoreKit.purchaseProduct(IAPConfiguration.annualPassKey, atomically: true) { result in
            switch result {
                case .success(_):
                    completion(.success(true))
                case .error(let error):
                    if error.code == .paymentCancelled {
                        completion(.failure(.cancelled))
                    } else {
                        completion(.failure(.other(error._nsError)))
                    }
                    
            }
        }
    }
    
    enum RestoreError: Error {
        case failRestore
        case nothingToRestore
    }
    
    func restorePurchase(_ completion: @escaping (Result<Void, RestoreError>)->()) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                completion(.failure(.failRestore))
                return
            }
            if results.restoredPurchases.count > 0 {
                completion(.success(()))
                return
            }
            
            completion(.failure(.nothingToRestore))
        }
    }
}
