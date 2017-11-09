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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func updateLayout(itemsCalc: ItemsCalc) {
        if let layout = self.collectionView.collectionViewLayout as? PinterestLayout {
            layout.itemsCalc = itemsCalc
            layout.cache = [PinterestLayoutAttributes]()
        }
    }
}

extension ItemsContainerCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ContentContainerViewModel else { return }
        self.updateLayout(itemsCalc: viewModel.itemsCalc)
    }
}
