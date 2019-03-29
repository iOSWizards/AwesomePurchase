//
//  RenewalInfo.swift
//  Zentra
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public class RenewalInfo: Codable {
    public let autoRenewProductId: String?
    public let originalTransactionId: String?
    public let productId: String?
    public let autoRenewStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case autoRenewProductId = "auto_renew_product_id"
        case originalTransactionId = "original_transaction_id"
        case productId = "product_id"
        case autoRenewStatus = "auto_renew_status"
    }
}
