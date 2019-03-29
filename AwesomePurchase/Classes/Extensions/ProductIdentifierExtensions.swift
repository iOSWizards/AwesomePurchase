//
//  StringExtensions.swift
//  AwesomePurchase
//
//  Created by Evandro Harrison on 30/03/2019.
//

import StoreKit

extension ProductIdentifier {
    public var resourceName: String? {
        return self.components(separatedBy: ".").last
    }
}
