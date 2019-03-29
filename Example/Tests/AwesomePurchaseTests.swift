//
//  AwesomePurchaseTests.swift
//  AwesomePurchase_Example
//
//  Created by Evandro Harrison Hoffmann on 2/15/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import AwesomePurchase

class AwesomePurchaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProductsWereSetup() {
        XCTAssertEqual(AwesomePurchase.shared.productIdentifiers.count, 0)
        
        AwesomePurchase.shared.setupStore(productIds: ["identifier1", "identifier2"])
        
        XCTAssertEqual(AwesomePurchase.shared.productIdentifiers.count, 2)
    }
    
    func testResourceNameForIdentifierReturnsLastComponent() {
        XCTAssertEqual("com.mindvalley.productIdentifier".resourceName, "productIdentifier")
    }
}
