//
//  Item.swift
//  prompter
//
//  Created by szj on 2026/2/16.
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
