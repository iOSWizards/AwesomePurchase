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
    
    public static var store: AwesomeIAPHelper?
    
    public static var productIdentifiers: Set<ProductIdentifier> = []
    
    public static func setupStore(productIds: Set<ProductIdentifier>) {
        AwesomePurchase.productIdentifiers = productIds
        store = AwesomeIAPHelper(productIds: AwesomePurchase.productIdentifiers)
    }
    
    public static func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }
    
    // MARK: - Requests
    
    public static func product(withIdentifier identifier: String, completion: @escaping ProductRequestCompletionHandler) {
        guard let store = AwesomePurchase.store else {
            print("Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            completion(nil)
            return
        }
        
        store.product(withIdentifier: identifier, completion: completion)
    }
    
    public static func products(completion: @escaping ProductsRequestCompletionHandler) {
        guard let store = AwesomePurchase.store else {
            print("Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            completion(false, nil)
            return
        }
        
        store.requestProducts(completion: completion)
    }
    
    public static func purchaseProduct(withIdentifier identifier: String, completion:@escaping ProductPurchasedCompletionHandler) {
        guard let store = AwesomePurchase.store else {
            print("Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            completion(false, nil)
            return
        }
        
        store.product(withIdentifier: identifier) { (product) in
            if let product = product {
                store.buyProduct(product) { (success, receipt) in
                    completion(true, receipt)
                }
            } else {
                completion(false, nil)
            }
        }
    }
}
