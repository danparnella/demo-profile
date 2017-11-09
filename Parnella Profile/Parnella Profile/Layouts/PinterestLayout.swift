//
//  PinterestLayout.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
    var photoHeight: CGFloat = 0
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class PinterestLayout: UICollectionViewLayout {
    var itemsCalc: ItemsCalc!
    var cache = [PinterestLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else { fatalError() }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override class var layoutAttributesClass: AnyClass {
        return PinterestLayoutAttributes.self
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView else { fatalError() }
        
        if self.cache.isEmpty {
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            
            let columnWidth = self.itemsCalc.columnWidth
            var xOffset: [CGFloat] = [0, columnWidth]
            var column = 0
            var yOffset: [CGFloat] = [0, 0]
            
            if numberOfItems == 0 {
                return
            }
            
            for itemIndex in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let currentItem = self.itemsCalc.items[itemIndex]
                
                guard let photoHeight = currentItem.photoHeight, let height = currentItem.cardHeight else {
                    return
                }
                
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: self.itemsCalc.itemPaddingX, dy: self.itemsCalc.itemPaddingY)
                
                let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                self.cache.append(attributes)
                
                yOffset[column] = yOffset[column] + height
                
                if yOffset[0] == yOffset[1] {
                    column = (column == 0) ? 1 : 0
                } else {
                    column = (yOffset[0] > yOffset[1]) ? 1 : 0
                }
            }
            
            self.contentHeight = self.itemsCalc.containerHeight
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in self.cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
}
