//
//  Item.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class Item: ListDiffable {
    enum ItemState: Int {
        case toDo, completed
    }
    
    enum Category: Int {
        case entertainment, foodDrink, travel, events, activities
    }
    
    var state: ItemState?
    var category: Category?
    var name: String?
    var description: String?
    var imageURLString: String?
    
    var itemID: Int!
    
    init(data: Any) {
        if let state = ItemState(rawValue: Int(arc4random_uniform(2))) {
            self.state = state
        }
        if let category = Category(rawValue: Int(arc4random_uniform(5))) {
            self.category = category
        }
        self.processData(data)
    }
    
    func processData(_ data: Any) {
        
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.itemID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Item else { return false }
        return self.diffIdentifier().isEqual(object.diffIdentifier())
    }
}
