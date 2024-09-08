//
//  ReachabilityUIProtocol.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 10/08/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

fileprivate let ReachabilityUIViewHeight: CGFloat = 30

fileprivate func ReachabilityLabel() -> UILabel {
    let label = UILabel()
    label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: ReachabilityUIViewHeight)
    label.textColor = .white
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 12)
    return label
}

enum ReachabilityUIPosition {
    case top, bottom
}

extension NSNotification.Name {
    public static let reachabilityUIRefresh = Notification.Name(rawValue: "ReachabilityUI.refresh")
}

fileprivate struct AssociatedKeys {
    static var _reachabilityLabel: UInt8 = 0
}

// MARK: - Protocol
protocol ReachabilityUIProtocol where Self:UIViewController {
    var reachabilityConstraint: NSLayoutConstraint! {get}
    var reachabilityUIPosition: ReachabilityUIPosition! {get}
    var reachabilityNoNetworkAlwaysShow: Bool {get}
    func reachabilityUIStartObserving()
    
    var reachabilityView: UILabel {get}
    
    func updateReachabilityUIOnViewDidAppear()
}

extension ReachabilityUIProtocol {
    
    // MARK: - Stored Variables
    private(set) var _reachabilityLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys._reachabilityLabel) as? UILabel
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._reachabilityLabel, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Must be called in your viewController for updating UI
    func reachabilityUIStartObserving() {
        NotificationCenter.default.addObserver(forName: .reachabilityUIRefresh, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.updateReachabilityUI()
            }
        }
    }
    
    var reachabilityNoNetworkAlwaysShow: Bool {
        return true
    }
    
    var reachabilityUIPosition: ReachabilityUIPosition! {
        return .bottom
    }
    
    var reachabilityView: UILabel {
        if self._reachabilityLabel == nil {
            self._reachabilityLabel = ReachabilityLabel()
        }
        
        return self._reachabilityLabel!
    }
    
    /// Must be called in viewDidAppear for updating view if has no network. This function is useful when your viewController wasn't initiase
    func updateReachabilityUIOnViewDidAppear() {
        if Connectivity.shared.hasNoNetwork {
            self.updateReachabilityUI()
        }
    }
    
    // MARK: - Private
    private func updateReachabilityUI() {
        let hasNoNetwork = Connectivity.shared.hasNoNetwork
        
        if !self.view.subviews.contains(where: {$0 == self.reachabilityView}) {
            self.reachabilityView.frame.origin.y = (self.reachabilityUIPosition == .top) ? 0 : self.view.frame.height - ReachabilityUIViewHeight
            self.reachabilityConstraint.constant += ReachabilityUIViewHeight
            self.view.addSubview(self.reachabilityView)
        }
        
        self.reachabilityView.backgroundColor = hasNoNetwork ? UIColor(hexa: "#e74c3c") : UIColor(hexa: "#2ecc71")
        self.reachabilityView.text = hasNoNetwork ? "Aucune Connexion" : "La connexion est de retour"
        
        if hasNoNetwork {
            self.reachabilityView.frame.origin.y += ReachabilityUIViewHeight
        
            UIView.animate(withDuration: 0.25, animations: {
                self.reachabilityView.frame.origin.y -= ReachabilityUIViewHeight
            }, completion: { _ in
                if !self.reachabilityNoNetworkAlwaysShow {
                    self.hideView()
                }
            })
        } else {
            self.hideView()
        }
    }
    
    private func hideView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.25, animations: {
                self.reachabilityConstraint.constant -= ReachabilityUIViewHeight
                self.reachabilityView.frame.origin.y += ReachabilityUIViewHeight
            }, completion: { _ in
                self.reachabilityView.removeFromSuperview()
            })
        }
    }
}
