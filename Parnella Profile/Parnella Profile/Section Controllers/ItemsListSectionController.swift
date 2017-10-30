//
//  ItemsListSectionController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

class ItemsListSectionController: ListBindingSectionController<ItemsData> {
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()
    
    var adapterData: [ContentContainerViewModel]!
    var collectionViewCell: ItemsContainerCollectionViewCell?
    
    override init() {
        super.init()
        self.dataSource = self
        self.inset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}

extension ItemsListSectionController: ListBindingSectionControllerDataSource {
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ItemsData else { fatalError() }
        
        let content = ContentContainerViewModel(items: object.items)
        self.adapterData = [content]
        
        var data: [ListDiffable] = [content]
        
        if let headerTitle = object.headerTitle {
            data.insert(ContentHeaderViewModel(title: headerTitle), at: 0)
        }
        
        return data
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = self.collectionContext?.insetContainerSize.width, let items = self.object?.items else { fatalError() }
        
        let height: CGFloat = {
            if let viewModel = viewModel as? ContentHeaderViewModel {
                return viewModel.kHeaderDefaultHeight
            }
            
            let itemsCalc = ItemsCalc(items: items, contentWidth: width - (16 * 2))
            return itemsCalc.getContainerHeight()
        }()
        
        return CGSize(width: width, height: height)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let cellIdentifier: String = {
            if viewModel is ContentHeaderViewModel {
                return HeaderCollectionViewCell.reuseIdentifier
            }
            return ItemsContainerCollectionViewCell.reuseIdentifier
        }()
        
        guard let cell = self.collectionContext?.dequeueReusableCell(withNibName: cellIdentifier, bundle: .main, for: self, at: index) as? UICollectionViewCell & ListBindable else {
            fatalError()
        }
        
        if let cell = cell as? ItemsContainerCollectionViewCell {
            self.collectionViewCell = cell
            self.adapter.collectionView = cell.collectionView
        }
        
        return cell
    }
}

extension ItemsListSectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.adapterData
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let source = self.object?.source else { fatalError() }
        return ItemsSectionController(itemsSource: source)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}
