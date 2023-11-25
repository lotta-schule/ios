//
//  RemoveNullsFromDict.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 25/11/2023.
//

import Foundation

func removeNullsFromDict<Value>(dict: Dictionary<String, Value>) -> Dictionary<String, Value> {
    var result = [String:Value]()
    for key in dict.keys {
        if let value = dict[key] {
            result[key] = value
        }
    }
    
    return result;
}

extension Dictionary<String, Any> {
    func removeNullValues() -> Dictionary {
        return removeNullsFromDict(dict: self)
    }
}
