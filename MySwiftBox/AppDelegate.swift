//
//  AppDelegate.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 18/09/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // if no launcher window might be nil
        if self.window == nil {
            self.window = UIWindow(frame:UIScreen.main.bounds)
        }
        
        let viewController = MyListBoxViewController.instance
        self.window?.rootViewController = UINavigationController(rootViewController: viewController)
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

