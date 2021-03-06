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
    
    var adapterData: [Item]?
    var itemsCalc: ItemsCalc!
    var tempItems = [Item]()
    var collectionViewCell: ItemsContainerCollectionViewCell?
    
    var timer: Timer?
    var dataUpdating = false
    
    override init() {
        super.init()
        self.dataSource = self
        self.inset = UIEdgeInsets(top: 45, left: 0, bottom: 16, right: 0)
    }
}

extension ItemsListSectionController: ListBindingSectionControllerDataSource {
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ItemsData else { fatalError() }
        
        if self.adapterData == nil {
            self.adapterData = object.items
        }
        
        guard let width = self.collectionContext?.insetContainerSize.width, let items = self.adapterData else { fatalError() }
        self.tempItems = items
        self.itemsCalc = ItemsCalc(items: items, contentWidth: width - (8 * 2))
        
        var data: [ListDiffable] = [
            ContentContainerViewModel(items: items, itemsCalc: self.itemsCalc)
        ]
        
        if let headerTitle = object.headerTitle {
            data.insert(ContentHeaderViewModel(title: headerTitle, description: object.headerDescription), at: 0)
        }
        
        return data
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = self.collectionContext?.insetContainerSize.width else { fatalError() }
        
        let height: CGFloat = {
            if let viewModel = viewModel as? ContentHeaderViewModel {
                return viewModel.kHeaderDefaultHeight + viewModel.getDescriptionHeight(width)
            }
            return self.itemsCalc.getContainerHeight()
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
        guard let items = self.adapterData else { fatalError() }
        return [ProfileItemsViewModel(items: items)]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let source = self.object?.source else { fatalError() }
        let sectionController = ItemsSectionController(itemsSource: source)
        sectionController.delegate = self
        
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

// MARK: Data Update
extension ItemsListSectionController {
    func runDataChangeOperations() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.refreshData),
            userInfo: nil,
            repeats: true
        )
        self.timer?.fire()
    }
    
    @objc func refreshData() {
        if !self.dataUpdating {
            self.timer?.invalidate()
            self.dataUpdating = true
            self.adapterData = self.tempItems
            
            guard let newItems = self.adapterData else { return }
            if !newItems.isEmpty {
                DispatchQueue.main.async {
                    self.update(animated: true, completion: { finished in
                        self.adapter.performUpdates(animated: true, completion: { finished in
                            self.dataUpdating = false
                            if let viewController = self.viewController as? ProfileViewController {
                                viewController.updateThreshold()
                                viewController.dataModel.items?.gettingData = false
                            }
                        })
                    })
                }
            }
        }
    }
}

// MARK: Delegates
extension ItemsListSectionController: ItemsUpdateDataDelegate {
    func itemsUpdated(newItems: [Item]) {
        self.tempItems.append(contentsOf: newItems)
        self.runDataChangeOperations()
    }
}

extension ItemsListSectionController: ItemsSectionActionDelegate {
    func performButtonAction(_ action: ItemAction, on item: Item, itemSource: ItemsData.ItemSource) {
        switch action {
        case .follow:
            if let index = self.adapterDataIndex(itemID: item.itemID) {
                let newItem = Item(itemToCopy: item)
                newItem.viewerState = .following
                self.updateAdapterData(withItem: newItem, at: index)
            }
        case .unfollow:
            if let index = self.adapterDataIndex(itemID: item.itemID) {
                if itemSource == .yours {
                    self.removeItemFromAdapterData(at: index, refresh: true)
                } else {
                    let newItem = Item(itemToCopy: item)
                    newItem.viewerState = .notFollowing
                    self.updateAdapterData(withItem: newItem, at: index)
                }
            }
        }
    }
    
    func adapterDataIndex(itemID: Int) -> Int? {
        return self.tempItems.index(where: { $0.itemID == itemID })
    }
    
    func removeItemFromAdapterData(at index: Int, refresh: Bool) {
        self.tempItems.remove(at: index)
        if refresh {
            self.runDataChangeOperations()
        }
    }
    
    func updateAdapterData(withItem item: Item, at index: Int) {
        self.tempItems[index] = item
        self.runDataChangeOperations()
    }
}
