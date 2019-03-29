//
//  Receipt.swift
//  Zentra
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

public class Receipt: Codable {
    
    public let receiptType: String?
    public let adamId: Int?
    public let appItemId: Int?
    public let bundleId: String?
    public let applicationVersion: String?
    public let downloadId: Int?
    public let versionExternalIdentifier: Int?
    public let receiptCreationDate: String?
    public let receiptCreationDateMs: String?
    public let receiptCreationDatePst: String?
    public let requestDate: String?
    public let requestDateMs: String?
    public let requestDatePst: String?
    public let originalPurchaseDate: String?
    public let originalPurchaseDateMs: String?
    public let originalPurchaseDatePst: String?
    public let originalApplicationVersion: String?
    public let inApp: [ReceiptInfo]?
    
    enum CodingKeys: String, CodingKey {
        case receiptType = "receipt_type"
        case adamId = "adam_id"
        case appItemId = "app_item_id"
        case bundleId = "bundle_id"
        case applicationVersion = "application_version"
        case downloadId = "download_id"
        case versionExternalIdentifier = "version_external_identifier"
        case receiptCreationDate = "receipt_creation_date"
        case receiptCreationDateMs = "receipt_creation_date_ms"
        case receiptCreationDatePst = "receipt_creation_date_pst"
        case requestDate = "request_date"
        case requestDateMs = "request_date_ms"
        case requestDatePst = "request_date_pst"
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMs = "original_purchase_date_ms"
        case originalPurchaseDatePst = "original_purchase_date_pst"
        case originalApplicationVersion = "original_application_version"
        case inApp = "in_app"
    }
}
