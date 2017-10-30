//
//  ContentContainerViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ContentContainerViewModel: ListDiffable {
    let items: [ListDiffable]
    
    init(items: [ListDiffable]) {
        self.items = items
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "itemsContainer" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ContentContainerViewModel else { return false }
        
        if self.items.count == object.items.count {
            for (index, selfItem) in self.items.enumerated() {
                if !selfItem.isEqual(toDiffableObject: object.items[index]) {
                    return false
                }
            }
            return true
        }
        return false
    }
}
