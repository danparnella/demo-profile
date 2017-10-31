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
        case toDo, completed, neither
    }
    
    enum Category: Int {
        case entertainment, foodDrink, travel, events, activities
    }
    
    var state: ItemState?
    var viewerState: ItemState?
    var category: Category?
    var name: String?
    var description: String?
    var imageURLString: String?
    var aspectRatio: CGFloat = 0
    
    var itemID: Int!
    
    var skipItem = false
    
    init(data: [String: Any]) {
        if let state = ItemState(rawValue: Int(arc4random_uniform(2))) {
            self.state = state
        }
        if let category = Category(rawValue: Int(arc4random_uniform(5))) {
            self.category = category
        }
        self.processData(data)
    }
    
    init(itemToCopy item: Item) {
        self.state = item.state
        self.viewerState = item.viewerState
        self.category = item.category
        self.description = item.description
        self.name = item.name
        self.imageURLString = item.imageURLString
        self.aspectRatio = item.aspectRatio
        self.itemID = item.itemID
    }
    
    func processData(_ data: [String: Any]) {
        self.itemID = data["id"] as? Int
        self.name = data["name"] as? String
        self.description = data["description"] as? String
        
        if let thumbnail = data["thumbnail"] as? [String: String],
            var path = thumbnail["path"],
            let pathExt = thumbnail["extension"]
        {
            path = path.replacingOccurrences(of: "http", with: "https")
            self.imageURLString = path + "/portrait_fantastic." + pathExt
            self.aspectRatio = 2/3
        }
        
        if (self.description ?? "").isEmpty || (self.imageURLString ?? "").contains("image_not_available") {
            // commented to reduce api calls, uncomment to only see those with images and descriptions
            //self.skipItem = true
        }
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.itemID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Item else { return false }
        
        if self.diffIdentifier().isEqual(object.diffIdentifier()) {
            return self.state == object.state && self.viewerState == object.viewerState
        }
        return false
    }
}

// MARK: Item Height Calc
extension Item {
    public func getItemHeight(width: CGFloat) -> CGFloat {
        guard let itemName = self.name else { return 0 }
        let item = self
        
        let stackViewSpacing: CGFloat = 8
        let topPadding: CGFloat = 18
        let bottomPadding: CGFloat = 15
        let buttonsPadding: CGFloat = 46
        let sidePadding: CGFloat = (8 * 2)
        let nameFontSize: CGFloat = 14
        let descriptionFontSize: CGFloat = 11
        
        var height: CGFloat = 0
        
        let nameFont = LatoFont().bold.withSize(nameFontSize)
        let nameHeight = itemName.heightFromText(font: nameFont, width: width - sidePadding)
        
        height += topPadding + nameHeight + bottomPadding + buttonsPadding
        
        if let description = item.description {
            let descriptionFont = LatoFont().bold.withSize(descriptionFontSize)
            let descriptionHeight = description.heightFromText(font: descriptionFont, width: width - sidePadding)
            if descriptionHeight > 0 {
                height += stackViewSpacing + descriptionHeight
            }
        } else {
            height += 3
        }
        
        return height
    }
}
