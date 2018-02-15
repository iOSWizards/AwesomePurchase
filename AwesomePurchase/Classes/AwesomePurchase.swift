//
//  MVAwesomeIAP.swift
//  Quests
//
//  Created by Evandro Harrison Hoffmann on 3/10/17.
//  Copyright © 2017 Mindvalley. All rights reserved.
//

import StoreKit

public let AwesomeIAPFailedRequestNotification = NSNotification.Name(rawValue: "AwesomeIAPFailedRequestNotification")
public let AwesomeIAPDeliverPurchaseNotification = NSNotification.Name(rawValue: "AwesomeIAPDeliverPurchaseNotification")
public let AwesomeIAPPurchasedNotification = NSNotification.Name(rawValue: "AwesomeIAPPurchasedNotification")


public struct AwesomePurchase {
    
    public static var store: AwesomeAwesomeIAP?
    
    public static var productIdentifiers: Set<ProductIdentifier> = []
    
    public static func setupStore(productIds: Set<ProductIdentifier>) {
        AwesomePurchase.productIdentifiers = productIds
        store = AwesomeAwesomeIAP(productIds: AwesomePurchase.productIdentifiers)
    }
    
    public static func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }
}
