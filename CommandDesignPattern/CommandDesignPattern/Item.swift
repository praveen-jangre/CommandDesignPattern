//
//  Item.swift
//  CommandDesignPattern
//
//  Created by Praveen Jangre on 27/06/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
