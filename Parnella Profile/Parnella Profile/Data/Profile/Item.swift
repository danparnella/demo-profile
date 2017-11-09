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
        case following, notFollowing
    }
    
    var viewerState: ItemState = .following
    var name: String?
    var description: String?
    var itemLinkURLString: String?
    var imageURLString: String?
    var aspectRatio: CGFloat = 0
    
    var itemID: Int!
    
    var skipItem = false
    
    // Calc Cache
    var photoHeight: CGFloat?
    var annotationHeight: CGFloat?
    var cardHeight: CGFloat?
    
    init(data: [String: Any]) {
        self.processData(data)
    }
    
    init(itemToCopy item: Item) {
        self.viewerState = item.viewerState
        self.description = item.description
        self.name = item.name
        self.itemLinkURLString = item.itemLinkURLString
        self.imageURLString = item.imageURLString
        self.aspectRatio = item.aspectRatio
        self.itemID = item.itemID
    }
    
    func processData(_ data: [String: Any]) {
        self.itemID = data["id"] as? Int
        self.name = data["name"] as? String
        
        if let description = data["description"] as? String {
            self.description = (description.isEmpty) ? nil : description
        }
        
        if let thumbnail = data["thumbnail"] as? [String: String],
            var path = thumbnail["path"],
            let pathExt = thumbnail["extension"]
        {
            path = path.replacingOccurrences(of: "http", with: "https")
            self.imageURLString = path + "/portrait_fantastic." + pathExt
            self.aspectRatio = 2/3
        }
        
        if let urls = data["urls"] as? [[String: String]] {
            if let wikiURL = urls.filter({ $0["type"] == "wiki" }).first {
                self.itemLinkURLString = wikiURL["url"]
            } else if let detailURL = urls.filter({ $0["type"] == "detail" }).first {
                self.itemLinkURLString = detailURL["url"]
            } else if let comicURL = urls.filter({ $0["type"] == "comicLink" }).first {
                self.itemLinkURLString = comicURL["url"]
            }
        }
        if (self.itemLinkURLString ?? "").isEmpty {
            self.itemLinkURLString = "http://marvel.com"
        }
        
        if (self.description ?? "").isEmpty || (self.imageURLString ?? "").contains("image_not_available") {
            // Commented to reduce api calls, uncomment to only see those with images and descriptions
            //self.skipItem = true
        }
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.itemID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Item else { return false }
        
        if self.diffIdentifier().isEqual(object.diffIdentifier()) {
            return self.viewerState == object.viewerState
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
        
        let descriptionFont = LatoFont().bold.withSize(descriptionFontSize)
        let description = item.description ?? "No description was provided for this character."
        
        let descriptionHeight = description.heightFromText(font: descriptionFont, width: width - sidePadding)
        if descriptionHeight > 0 {
            height += stackViewSpacing + descriptionHeight
        }
        
        return height
    }
}
