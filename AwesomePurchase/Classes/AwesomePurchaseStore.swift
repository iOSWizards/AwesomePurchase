//
//  AwesomePurchaseHelper.swift
//  AwesomePurchase
//
//  Created by Evandro Harrison Hoffmann on 2/15/18.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductRequestCompletionHandler = (_ product: SKProduct?, _ message: String?) -> Void
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?, _ message: String?) -> Void
public typealias ProductPurchasedCompletionHandler = (_ success: Bool, _ receipt: String?, _ message: String?) -> Void

public class AwesomePurchaseStore: NSObject {
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    fileprivate var productPurchasedCompletionHandler: ProductPurchasedCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        
        print("AwesomeIAPHelper refreshed with \(productIds.count) products:")
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
        clearRequestAndHandler()
    }
    
}

// MARK: - StoreKit API

extension AwesomePurchaseStore {
    
    public func requestProducts(completion: @escaping ProductsRequestCompletionHandler) {
        //cancel previous request
        clearRequestAndHandler()
        
        //setup completion handler
        productsRequestCompletionHandler = completion
        
        //perform the request
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    public func product(withIdentifier identifier: String, completion:@escaping ProductRequestCompletionHandler) {
        requestProducts { (_, products, message) in
            if let products = products {
                for product in products where product.productIdentifier == identifier {
                    completion(product, message)
                    return
                }
            }
            
            completion(nil, message)
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
    
    public func restorePurchases(completion:@escaping ProductPurchasedCompletionHandler) {
        guard SKPaymentQueue.canMakePayments() else {
             completion(false, nil, nil)
            return
        }

        productPurchasedCompletionHandler = completion
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        print("AwesomePurchase restoring purchases...")
    }
}

// MARK: - SKProductsRequestDelegate

extension AwesomePurchaseStore: SKProductsRequestDelegate {
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
            productPurchasedCompletionHandler?(false, nil, error.localizedDescription)
            clearPurchaseAndHandler()
        }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Loaded list of products...")
        print("Found \(products.count) products")
        productsRequestCompletionHandler?(true, products, nil)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil, error.localizedDescription)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest?.delegate = nil
        productsRequest?.cancel()
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension AwesomePurchaseStore: SKPaymentTransactionObserver {
    
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
            @unknown default:
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
                
                NotificationCenter.default.post(name: AwesomePurchaseNotification.purchased.notification, object: jsonObjectString)
                
                productPurchasedCompletionHandler?(true, jsonObjectString, nil)
            } else {
                productPurchasedCompletionHandler?(false, nil, "Unable to read receipt.")
            }
        } else {
            productPurchasedCompletionHandler?(false, nil, "Receipt is nil.")
        }
        
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        clearPurchaseAndHandler()
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("failed to purchase product (\(transaction.payment.productIdentifier): \( transaction.error?.localizedDescription ?? "")")
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        NotificationCenter.default.post(name: AwesomePurchaseNotification.failedRequest.notification, object: nil)
        
        productPurchasedCompletionHandler?(false, nil, transaction.error?.localizedDescription)
        clearPurchaseAndHandler()
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: AwesomePurchaseNotification.deliverPurchase.notification, object: identifier)
    }
    
    private func clearPurchaseAndHandler() {
        productPurchasedCompletionHandler = nil
    }
}
