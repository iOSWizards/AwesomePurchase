//
//  IAPProtocol.swift
//  Zentra
//
//  Created by Evandro Harrison on 28/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public protocol AwesomePurchaseSubscriptionStatusProtocol {
    func updatedSubscriptionStatus()
}

extension AwesomePurchaseSubscriptionStatusProtocol {
    public func addStatusObserver() {
        NotificationCenter.default.addObserver(forName: AwesomePurchaseNotification.updatedSubscriptionStatus.notification, object: nil, queue: .main) { (notification) in
            self.updatedSubscriptionStatus()
        }
    }
}
