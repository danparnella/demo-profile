//
//  ItemsSectionController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

protocol ItemsSectionActionDelegate: class {
    func performButtonAction(_ action: ItemAction, on item: Item, itemSource: ItemsData.ItemSource)
}

class ItemsSectionController: ListBindingSectionController<ProfileItemsViewModel> {
    var itemsSource: ItemsData.ItemSource!
    weak var delegate: ItemsSectionActionDelegate?
    
    init(itemsSource: ItemsData.ItemSource) {
        super.init()
        self.itemsSource = itemsSource
        self.dataSource = self
    }
}

extension ItemsSectionController: ListBindingSectionControllerDataSource {    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ProfileItemsViewModel else { fatalError() }
        return object.items
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        // doesn't matter, size is controlled by PinterestLayout
        guard let context = self.collectionContext else { fatalError() }
        return CGSize(width: context.insetContainerSize.width, height: context.insetContainerSize.height)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = self.collectionContext?.dequeueReusableCell(withNibName: ItemSmallCardCollectionViewCell.reuseIdentifier, bundle: .main, for: self, at: index) as? ItemSmallCardCollectionViewCell & ListBindable else {
            fatalError()
        }
        cell.delegate = self
        cell.source = self.itemsSource
        
        return cell
    }
}

// MARK: Delegate
extension ItemsSectionController: ItemActionDelegate {
    func itemButtonTapped(_ action: ItemAction, itemID: Int) {
        if let item = object?.items.filter({ $0.itemID == itemID }).first {
            self.delegate?.performButtonAction(action, on: item, itemSource: self.itemsSource)
        }
    }
}

