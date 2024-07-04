//
//  Set+Ext.swift
//  Weather
//
//  Created by jonathan saville on 20/06/2024.
//

extension Set {

    enum AddOrRemoveElement { case add, remove }
    
    mutating func update(_ value: Element, operation: AddOrRemoveElement) {
        switch operation {
        case .add: self.insert(value)
        case .remove: self.remove(value)
        }
    }
}
