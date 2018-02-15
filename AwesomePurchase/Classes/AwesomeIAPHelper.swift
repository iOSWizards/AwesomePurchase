//
//  AwesomePurchaseHelper.swift
//  AwesomePurchase
//
//  Created by Evandro Harrison Hoffmann on 2/15/18.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias ProductPurchasedCompletionHandler = (_ success: Bool, _ receipt: String?) -> Void

public class AwesomeAwesomeIAP: NSObject {
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    fileprivate var productPurchasedCompletionHandler: ProductPurchasedCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        
        print("AwesomeAwesomeIAP refreshed with \(productIds.count) products:")
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("---> \(productIdentifier) (Purchased)")
            } else {
                print("---> \(productIdentifier) (Not Purchased)")
            }
        }
        
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
}

// MARK: - StoreKit API

extension AwesomeAwesomeIAP {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        //cancel previous request
        clearRequestAndHandler()
        
        //setup completion handler
        productsRequestCompletionHandler = completionHandler
        
        //perform the request
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func product(withIdentifier identifier: String, completion:@escaping((_ product: SKProduct?) -> Void)) {
        guard let store = AwesomePurchase.store else {
            print("Store is not configured: Make sure you run AwesomePurchase.setupStore()")
            completion(nil)
            return
        }
        
        store.requestProducts { (_, products) in
            if let products = products {
                for product in products where product.productIdentifier == identifier {
                    completion(product)
                    return
                }
            }
            
            completion(nil)
        }
    }
    
    public func buyProduct(_ product: SKProduct, _ completion:@escaping ProductPurchasedCompletionHandler) {
        self.productPurchasedCompletionHandler = completion
        
        DispatchQueue.main.async {
            print("Buying \(product.productIdentifier)...")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension AwesomeAwesomeIAP: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Loaded list of products...")
        print("Found \(products.count) products")
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest?.cancel()
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension AwesomeAwesomeIAP: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("product purchased: \nIdentifier:\(String(describing: transaction.transactionIdentifier))\nDate:\(String(describing: transaction.transactionDate))\nState:\(transaction.transactionState.rawValue)\nPayment:\(transaction.payment)")
        
        processPayment(productIdentifier: transaction.payment.productIdentifier, transaction: transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        print("product restored: \nIdentifier:\(String(describing: transaction.transactionIdentifier))\nDate:\(String(describing: transaction.transactionDate))\nState:\(transaction.transactionState.rawValue)\nPayment:\(transaction.payment)")
        
        processPayment(productIdentifier: transaction.original?.payment.productIdentifier, transaction: transaction)
    }
    
    private func processPayment(productIdentifier: String?, transaction: SKPaymentTransaction) {
        guard let productIdentifier = productIdentifier else {
            return
        }
        
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            if let receipt = NSData(contentsOf: receiptURL) {
                let jsonObjectString = receipt.base64EncodedString(options: .init(rawValue: 0))
                //print("Receipt [\(jsonObjectString)]")
                
                NotificationCenter.default.post(name: AwesomeIAPPurchasedNotification, object: jsonObjectString)
                
                productPurchasedCompletionHandler?(true, jsonObjectString)
            } else {
                productPurchasedCompletionHandler?(false, nil)
            }
        } else {
            productPurchasedCompletionHandler?(false, nil)
        }
        
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        clearPurchaseAndHandler()
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("failed to purchase product (\(transaction.payment.productIdentifier): \(String(describing: transaction.error?.localizedDescription))")
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        NotificationCenter.default.post(name: AwesomeIAPFailedRequestNotification, object: nil)
        
        productPurchasedCompletionHandler?(false, nil)
        clearPurchaseAndHandler()
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: AwesomeIAPDeliverPurchaseNotification, object: identifier)
    }
    
    private func clearPurchaseAndHandler() {
        productPurchasedCompletionHandler = nil
    }
}
