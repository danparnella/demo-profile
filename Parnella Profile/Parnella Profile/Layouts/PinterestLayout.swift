//
//  PinterestLayout.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: class {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath: IndexPath,
        withWidth:CGFloat
    ) -> CGFloat
    
    func collectionView(
        _ collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: IndexPath,
        withWidth width: CGFloat
    ) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
    var photoHeight: CGFloat = 0
    var aspectRatio: CGFloat = 0
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        copy.aspectRatio = aspectRatio
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes {
            if attributes.photoHeight == photoHeight && attributes.aspectRatio == aspectRatio {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class PinterestLayout: UICollectionViewLayout {
    weak var delegate: PinterestLayoutDelegate?
    
    var cellPaddingX: CGFloat = 8
    var cellPaddingY: CGFloat = 10
    var itemSourceLabelHeight: CGFloat = 20
    
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
        guard let collectionView = self.collectionView, let delegate = self.delegate else { fatalError() }
        
        if self.cache.isEmpty {
            self.contentHeight = 0
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            
            let columnWidth = self.contentWidth/2
            var xOffset: [CGFloat] = [0, columnWidth]
            var column = 0
            var yOffset: [CGFloat] = [0, 0]
            
            if numberOfItems == 0 {
                return
            }
            
            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                let width = columnWidth - self.cellPaddingX * 2
                
                var photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                photoHeight = (photoHeight == 0) ? width : photoHeight
                let aspectRatio = width/photoHeight
                
                let annotationHeight = delegate.collectionView(collectionView, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = self.cellPaddingY + self.itemSourceLabelHeight + photoHeight + annotationHeight + self.cellPaddingY
                
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: self.cellPaddingX, dy: self.cellPaddingY)
                
                let attributes = PinterestLayoutAttributes(forCellWith: indexPath)
                attributes.photoHeight = photoHeight
                attributes.aspectRatio = aspectRatio
                attributes.frame = insetFrame
                self.cache.append(attributes)
                
                self.contentHeight = max(self.contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                if yOffset[0] == yOffset[1] {
                    column = (column == 0) ? 1 : 0
                } else {
                    column = (yOffset[0] > yOffset[1]) ? 1 : 0
                }
            }
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
