//
//  TodoItem.swift
//  Todoey
//
//  Created by admin on 7/25/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

struct TodoItem: Codable {
    let title: String
    var done: Bool
    
    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
