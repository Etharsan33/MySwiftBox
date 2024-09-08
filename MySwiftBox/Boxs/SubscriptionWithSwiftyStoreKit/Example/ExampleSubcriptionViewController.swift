//
//  ExampleSubcriptionViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 20/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class ExampleSubcriptionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Subcription"
        
        // ADD THIS TWO FUNCTION IN APPDELEGATE
        // Start InAppPurchase Observers && Fetch Data
        IAPManager.shared.startObserverTransactions()
        IAPManager.shared.fetchDataInBackground()
        
        // Update all
        if IAPManager.shared.isWorking {
            // Show Loading
        } else {
            // Update Info From IAPManager like price, expirationDate or notPurchase...
        }
    }
    
    // MARK: - InAppPurchase
    private func verifyPurchase() {
        // Show Loading
        
        IAPManager.shared.verifyPurchase { [weak self] result in
            // Hide Loading
            
            switch result {
                case .success(_):
                    // Do thing in success
                    break
                case .failure(let purchaseError):
                    switch purchaseError {
                    case .expiredOrNotPurchased:
                        // Do thing
                        break
                    case .other(let error):
                        self?.showAlert(title: nil, message: error.localizedDescription)
                }
            }
        }
    }
    
    private func purchase() {
        // Show Loading
        
        IAPManager.shared.purchase { [weak self] result in
            // Hide Loading
            
            switch result {
                case .success(_):
                    // Do thing
                    self?.verifyPurchase()
                case .failure(let error):
                    switch error {
                    case .cancelled:
                        break
                    case .other(let error):
                        self?.showAlert(title: nil, message: error.localizedDescription)
                    }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func purchaseAction(_ sender: Any) {
        self.purchase()
    }
}
