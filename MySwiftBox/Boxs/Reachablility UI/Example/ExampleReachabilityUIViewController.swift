//
//  ExampleReachabilityUIViewController.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 22/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

class ExampleReachabilityUIViewController: UIViewController, ReachabilityUIProtocol {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var reachabilityConstraint: NSLayoutConstraint! {
        return self.bottomConstraint
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start Listening
        // Add this in AppDelegate
        _ = Connectivity.shared
        
        self.reachabilityUIStartObserving()
    }
}
