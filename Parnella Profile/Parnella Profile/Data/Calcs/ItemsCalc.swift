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
    
    let itemPaddingX: CGFloat = 8
    let itemPaddingY: CGFloat = 10
    let itemSourceLabelHeight: CGFloat = 20
    
    init(items: [Item], contentWidth: CGFloat) {
        self.items = items
        self.columnWidth = contentWidth/2
        self.itemWidth = columnWidth - (self.itemPaddingX * 2)
    }
    
    func getContainerHeight() -> CGFloat {
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
        
        return containerHeight
    }
    
    func getPhotoHeight(forItem item: Item) -> CGFloat {
        if item.aspectRatio > 0 {
            return self.itemWidth/item.aspectRatio
        }
        if item.state == .completed {
            return self.itemWidth
        }
        return self.itemWidth * (3/4)
    }
    
    func getItemHeight(forItem item: Item) -> CGFloat {
        let photoHeight = self.getPhotoHeight(forItem: item)
        let annotationHeight = item.getItemHeight(width: self.itemWidth)
        return self.itemPaddingY + self.itemSourceLabelHeight + photoHeight + annotationHeight + self.itemPaddingY
    }
}
