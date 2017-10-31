//
//  ProfileItemsViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/31/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

class ProfileItemsViewModel: ListDiffable {
    let items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profileItemsViewModel" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
//        guard let object = object as? ProfileItemsViewModel else { return false }
//
//        if self.items.count == object.items.count {
//            for (index, selfItem) in self.items.enumerated() {
//                if !selfItem.isEqual(toDiffableObject: object.items[index]) {
//                    return false
//                }
//            }
//            return true
//        }
//        return false
    }
}
