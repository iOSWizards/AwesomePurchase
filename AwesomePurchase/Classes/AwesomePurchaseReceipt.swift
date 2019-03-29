//
//  IAPReceipt.swift
//  Zentra
//
//  Created by Evandro Harrison on 28/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public class AwesomePurchaseReceipt {
    
    private let appStoreProdUrl: String = "https://buy.itunes.apple.com/verifyReceipt"
    private let appStoreStgUrl: String = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    public var appStoreUrl: URL {
        return URL(string: AwesomePurchase.shared.isProduction ? appStoreProdUrl : appStoreStgUrl)!
    }
    
    public func confirmReceipt(receipt: String?, appStoreSecret: String, completion: @escaping (Bool) -> Void) {
        guard let receipt = receipt else {
            completion(false)
            return
        }
        
        var payload: [String: String] = [:]
        payload["receipt-data"] = receipt
        payload["password"] = appStoreSecret
        
        var urlRequest = URLRequest(url: appStoreUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = payload.data
        urlRequest.timeoutInterval = 30
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Confirm Receipt Error: \(error)")
                }
                completion(false)
                return
            }
            
            let receipt: ReceiptResponse? = try? ReceiptResponse.decode(from: data)
            guard receipt?.status == 0 else {
                print("Confirm Receipt Failed with status: \(receipt?.status ?? -1)")
                completion(false)
                return
            }
            
            completion(true)
        }
        dataTask.resume()
    }
}
