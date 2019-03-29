//
//  AwesomePurchaseProtocol.swift
//  AwesomePurchase
//
//  Created by Evandro Harrison on 29/03/2019.
//

import Foundation
import StoreKit

public protocol AwesomePurchaseProtocol {
    var products: [SKProduct] {get set}
    func receiptConfirmed(isValid: Bool)
}

extension AwesomePurchaseProtocol {
    
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
    
    public func confirmReceipt(receipt: String?, completion: @escaping (Bool) -> Void) {
        AwesomePurchase.shared.receiptManager?.confirmReceipt(receipt: receipt, appStoreSecret: "d36434e7bb364e92a73736fbefe1e616", completion: completion)
    }
    
}
