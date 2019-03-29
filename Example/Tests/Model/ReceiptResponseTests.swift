//
//  ReceiptResponseTests.swift
//  ZentraTests
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import XCTest
@testable import AwesomePurchase

class ReceiptResponseTests: XCTestCase {

    func testParseResponseFailure() {
        guard let data = MockJSONLoader.loadJSONData(file: "appstore_receipt_error", usingClass: self) else {
            XCTFail("a json FILE is needed in order to proceed with the test")
            return
        }
        
        let response: ReceiptResponse? = try? ReceiptResponse.decode(from: data)
        
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.status, 21004)
        XCTAssertEqual(response?.environment, "Sandbox")
        XCTAssertNil(response?.receipt)
        XCTAssertNil(response?.latestReceiptInfo)
        XCTAssertNil(response?.lastReceipt)
        XCTAssertNil(response?.pendingRenewalInfo)
    }
    
    func testParseResponseSuccess() {
        guard let data = MockJSONLoader.loadJSONData(file: "appstore_receipt", usingClass: self) else {
            XCTFail("a json FILE is needed in order to proceed with the test")
            return
        }
        
        let response: ReceiptResponse? = try? ReceiptResponse.decode(from: data)
        
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.status, 0)
        XCTAssertEqual(response?.environment, "Sandbox")
        XCTAssertNotNil(response?.receipt)
        XCTAssertEqual(response?.receipt?.inApp?.count, 7)
        XCTAssertNotNil(response?.latestReceiptInfo)
        XCTAssertEqual(response?.latestReceiptInfo?.count, 10)
        XCTAssertNotNil(response?.lastReceipt)
        XCTAssertNotNil(response?.pendingRenewalInfo)
        XCTAssertEqual(response?.pendingRenewalInfo?.count, 1)
    }

}
