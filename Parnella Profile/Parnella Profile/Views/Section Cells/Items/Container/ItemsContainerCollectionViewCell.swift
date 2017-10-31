//
//  ItemsContainerCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit
import AVFoundation

class ItemsContainerCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Item]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateLayout()
    }
    
    func updateLayout() {
        if let layout = self.collectionView.collectionViewLayout as? PinterestLayout {
            layout.cache = [PinterestLayoutAttributes]()
            layout.delegate = self
        }
    }
}

extension ItemsContainerCollectionViewCell: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        if indexPath.item < self.items.count {
            let item = self.items[indexPath.item]
//            let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
            if item.aspectRatio > 0 {
                return width/item.aspectRatio
            }
            if item.state == .completed {
                return width
            }
            return width * (3/4)
//            let height: CGFloat = (item.aspectRatio > 0) ? width/item.aspectRatio : (item.state == .completed) ? width : width * (3/4)
//            let rect = AVMakeRect(aspectRatio: CGSize(width: width, height: height), insideRect: boundingRect)
//            return rect.size.height
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        if indexPath.item < self.items.count {
            let item = self.items[indexPath.item]
            return item.getItemHeight(width: width)
        }
        return 0
    }
}

extension ItemsContainerCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ContentContainerViewModel, let items = viewModel.items as? [Item] else { return }
        self.items = items
        self.updateLayout()
    }
}
