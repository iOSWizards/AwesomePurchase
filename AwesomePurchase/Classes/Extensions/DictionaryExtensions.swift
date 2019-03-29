//
//  DictionaryExtensions.swift
//  Pods
//
//  Created by Evandro Harrison on 11/03/2019.
//

import Foundation

extension Dictionary {
    
    var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
}
