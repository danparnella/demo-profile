//
//  ItemsCalc.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import Foundation
import UIKit

struct ItemsCalc {
    let items: [Item]
    
    let columnWidth: CGFloat
    let itemWidth: CGFloat
    var containerHeight: CGFloat = 0
    
    let itemPaddingX: CGFloat = 8
    let itemPaddingY: CGFloat = 10
    
    init(items: [Item], contentWidth: CGFloat) {
        self.items = items
        self.columnWidth = contentWidth/2
        self.itemWidth = columnWidth - (self.itemPaddingX * 2)
    }
    
    mutating func getContainerHeight() -> CGFloat {
        var containerHeight: CGFloat = 0
        
        var xOffset: [CGFloat] = [0, self.columnWidth]
        var column = 0
        var yOffset: [CGFloat] = [0, 0]
        
        for item in self.items {
            let height = self.getItemHeight(forItem: item)
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: self.columnWidth, height: height)
            
            containerHeight = max(containerHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            if yOffset[0] == yOffset[1] {
                column = (column == 0) ? 1 : 0
            } else {
                column = (yOffset[0] > yOffset[1]) ? 1 : 0
            }
        }
        
        self.containerHeight = containerHeight
        return containerHeight
    }
    
    func getPhotoHeight(forItem item: Item) -> CGFloat {
        if item.aspectRatio > 0 {
            return self.itemWidth/item.aspectRatio
        }
        return self.itemWidth
    }
    
    func getItemHeight(forItem item: Item) -> CGFloat {
        if item.cardHeight == nil {
            let photoHeight = self.getPhotoHeight(forItem: item)
            let annotationHeight = item.getItemHeight(width: self.itemWidth)
            item.photoHeight = photoHeight
            item.annotationHeight = annotationHeight
            item.cardHeight = self.itemPaddingY + photoHeight + annotationHeight + self.itemPaddingY
        }
        
        if let cardHeight = item.cardHeight {
            return cardHeight
        }
        return 0
    }
}
