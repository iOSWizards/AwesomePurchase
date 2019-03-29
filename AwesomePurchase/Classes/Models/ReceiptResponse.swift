//
//  ReceiptResponse.swift
//  Zentra
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public class ReceiptResponse: Codable {
    public let status: Int
    public let environment: String
    public let receipt: Receipt?
    public let latestReceiptInfo: [ReceiptInfo]?
    public let lastReceipt: String?
    public let pendingRenewalInfo: [RenewalInfo]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case environment
        case receipt
        case latestReceiptInfo = "latest_receipt_info"
        case lastReceipt = "latest_receipt"
        case pendingRenewalInfo = "pending_renewal_info"
    }
    
    public var receiptStatus: String {
        switch status {
        case 21000:
            return "The App Store could not read the JSON object you provided."
        case 21002:
            return "The data in the receipt-data property was malformed or missing."
        case 21003:
            return "The receipt could not be authenticated."
        case 21004:
            return "The shared secret you provided does not match the shared secret on file for your account."
        case 21005:
            return "The receipt server is not currently available."
        case 21006:
            return "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
        case 21007:
            return "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
        case 21008:
            return "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
        case 21010:
            return "This receipt could not be authorized. Treat this the same as if a purchase was never made."
        case 21100, 21199:
            return "Internal data access error."
        default:
            return "unknown"
        }
    }
    
    public var isActiveSubscription: Bool {
        switch status {
        case 21005:
            return true
        default:
            return false
        }
    }
}
