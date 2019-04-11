//
//  AwesomePurchaseProtocol.swift
//  AwesomePurchase
//
//  Created by Evandro Harrison on 29/03/2019.
//

import Foundation
import StoreKit

public protocol AwesomePurchaseSubscriptionProtocol {
    var products: [SKProduct] {get set}
    var appStoreSecret: String {get}
    func receiptConfirmed(isValid: Bool)
}

extension AwesomePurchaseSubscriptionProtocol {
    
    public func updateProducts(response: ((_ products: [SKProduct]) -> Void)? = nil) {
        if products.count > 0 {
            response?(products)
        }
        
        AwesomePurchase.shared.store?.requestProducts(completion: { (success, products, message) in
            guard success, let products = products else {
                print("Shit happens. No products from apple: \(message ?? "")")
                response?([])
                return
            }
            response?(products)
        })
    }
    
    public func product(for identifier: String) -> SKProduct? {
        for product in products where product.productIdentifier == identifier {
            return product
        }
        
        return nil
    }
    
    public func buy(_ product: SKProduct, response: @escaping (Bool, String?, String?) -> Void) {
        AwesomePurchase.shared.store?.buyProduct(product, { (success, receipt, message) in
            response(success, receipt, message)
        })
    }
    
    // MARK: - Purchase check
    
    public func addPurchaseObservers() {
        NotificationCenter.default.addObserver(forName: AwesomePurchaseNotification.purchased.notification, object: nil, queue: .main) { (notification) in
            guard let receipt = notification.object as? String else {
                return
            }
            
            print("AwesomePurchaseHelper: receipt [\(receipt)]")
            self.confirmReceipt(receipt: receipt) { (subscribed) in
                print("AwesomePurchaseHelper: subscription status [\(subscribed)]")
                self.receiptConfirmed(isValid: subscribed)
            }
        }
    }
    
    public func restorePurchases() {
        AwesomePurchase.shared.store?.restorePurchases()
    }
    
    public func confirmReceipt(receipt: String?, completion: @escaping (Bool) -> Void) {
        AwesomePurchase.shared.receiptManager?.confirmReceipt(receipt: receipt, appStoreSecret: appStoreSecret, completion: completion)
    }
    
    public static var isSubscribed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSubscribed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSubscribed")
            NotificationCenter.default.post(name: AwesomePurchaseNotification.updatedSubscriptionStatus.notification, object: newValue)
            print("Subscription status updated: \(newValue)")
        }
    }
}
