//
//  MVAwesomeIAP.swift
//  Quests
//
//  Created by Evandro Harrison Hoffmann on 3/10/17.
//  Copyright © 2017 Mindvalley. All rights reserved.
//

import StoreKit

public enum AwesomePurchaseNotification: String {
    case updatedSubscriptionStatus = "AwesomePurchaseUpdatedSubscriptionStatus"
    case failedRequest = "AwesomePurchaseFailedRequest"
    case deliverPurchase = "AwesomePurchaseDeliverPurchase"
    case purchased = "AwesomePurchasePurchased"
    
    public var notification: Notification.Name {
        return Notification.Name(rawValue: rawValue)
    }
}

public class AwesomePurchase {
    
    public static var shared: AwesomePurchase = AwesomePurchase()
    
    public var store: AwesomePurchaseStore?
    public var productIdentifiers: Set<ProductIdentifier> = []
    public var receiptManager: AwesomePurchaseReceipt?
    public var isProduction: Bool = true
    
    public static func start(with productIds: Set<ProductIdentifier>, isProduction: Bool = true) {
        shared.receiptManager = AwesomePurchaseReceipt()
        shared.isProduction = isProduction
        shared.setupStore(productIds: productIds)
    }
    
    public func setupStore(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        store = AwesomePurchaseStore(productIds: productIdentifiers)
    }
    
    // MARK: - Requests
    
    public static func product(withIdentifier identifier: String, completion: @escaping ProductRequestCompletionHandler) {
        guard let store = shared.store else {
            completion(nil, "Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            return
        }
        
        store.product(withIdentifier: identifier, completion: completion)
    }
    
    public static func products(completion: @escaping ProductsRequestCompletionHandler) {
        guard let store = shared.store else {
            completion(false, nil, "Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            return
        }
        
        store.requestProducts(completion: completion)
    }
    
    public static func purchaseProduct(withIdentifier identifier: String, completion:@escaping ProductPurchasedCompletionHandler) {
        guard let store = shared.store else {
            completion(false, nil, "Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            return
        }
        
        store.product(withIdentifier: identifier) { (product, message) in
            if let product = product {
                store.buyProduct(product) { (success, receipt, message) in
                    completion(true, receipt, message)
                }
            } else {
                completion(false, nil, message)
            }
        }
    }
}
