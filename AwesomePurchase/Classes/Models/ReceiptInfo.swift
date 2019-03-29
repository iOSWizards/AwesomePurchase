//
//  ReceiptInfo.swift
//  Zentra
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public class ReceiptInfo: Codable {
    public let quantity: String?
    public let productId: String?
    public let transactionId: String?
    public let originalTransactionId: String?
    public let purchaseDate: String?
    public let purchaseDateMs: String?
    public let purchaseDatePst: String?
    public let originalPurchaseDate: String?
    public let originalPurchaseDateMs: String?
    public let originalPurchaseDatePst: String?
    public let expiresDate: String?
    public let expiresDateMs: String?
    public let expiresDatePst: String?
    public let webOrderLineItemId: String?
    public let isTrialPeriod: String?
    public let isInIntroOfferPeriod: String?
    
    enum CodingKeys: String, CodingKey {
        case quantity
        case productId = "product_id"
        case transactionId = "transaction_id"
        case originalTransactionId = "original_transaction_id"
        case purchaseDate = "purchase_date"
        case purchaseDateMs = "purchase_date_ms"
        case purchaseDatePst = "purchase_date_pst"
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMs = "original_purchase_date_ms"
        case originalPurchaseDatePst = "original_purchase_date_pst"
        case expiresDate = "expires_date"
        case expiresDateMs = "expires_date_ms"
        case expiresDatePst = "expires_date_pst"
        case webOrderLineItemId = "web_order_line_item_id"
        case isTrialPeriod = "is_trial_period"
        case isInIntroOfferPeriod = "is_in_intro_offer_period"
    }
    
}
