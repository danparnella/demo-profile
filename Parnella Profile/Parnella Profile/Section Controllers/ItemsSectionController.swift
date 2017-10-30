//
//  ItemsSectionController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

class ItemsSectionController: ListBindingSectionController<ContentContainerViewModel> {
    var itemsSource: ItemsData.ItemSource!
    var items: [Item]?
    var tempItems = [Item]()
    
    var timer: Timer?
    var dataUpdating = false
    
    init(itemsSource: ItemsData.ItemSource) {
        super.init()
        self.itemsSource = itemsSource
        self.dataSource = self
    }
}

extension ItemsSectionController: ListBindingSectionControllerDataSource {    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ContentContainerViewModel else { fatalError() }
        
        if self.items == nil {
            self.items = object.items as? [Item]
        }
        
        guard let items = self.items else { fatalError() }
        return items
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
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

// MARK: Data Update
extension ItemsSectionController {
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
            self.items = self.tempItems
            
            guard let newItems = self.items else { return }
            if !newItems.isEmpty {
                DispatchQueue.main.async {
                    self.collectionContext?.invalidateLayout(for: self, completion: { (finished) in
                        self.update(animated: true, completion: { finished in
                            self.dataUpdating = false
                        })
                    })
//                        guard let collectionContext = self.collectionContext else { fatalError() }
//
//                        self.adapter.performUpdates(animated: true, completion: { finished in
//                            self.dataUpdating = false
//                            if let viewController = self.viewController as? ProfileViewController {
//                                viewController.updateThreshold()
//                                if viewController.profileModel.todosDataVM.retrievingNextPage {
//                                    viewController.profileModel.todosDataVM.retrievingNextPage = false
//                                }
//                            }
//                        })
//                    })
                }
            }
        }
    }
}

// MARK: Delegates
//extension ItemsSectionController: ListsTodosVMPaginationDelegate {
//    func pageRetrieved(todos: [VIVTodo]?) {
//        if let nextPage = todos {
//            self.tempData.append(contentsOf: nextPage)
//            self.runDataChangeOperations()
//        }
//    }
//}

extension ItemsSectionController: ItemActionDelegate {
    func itemButtonTapped(_ action: ItemAction, index: Int) {
        if let item = self.items?[index] {
            switch action {
            case .add:
                if self.itemsSource == .yours {
                    if let index = self.adapterDataIndex(itemID: item.itemID) {
                        self.removeItemFromAdapterData(at: index, refresh: false)
                    }
                    
                    self.addToAdapterData(item)
                } else {
                    // update cell
                }
            case .complete:
                if self.itemsSource == .yours {
                    if let index = self.adapterDataIndexForOriginalItem(itemID: item.itemID) {
                        if index == 0 || item.state == .toDo {
                            self.updateAdapterData(withItem: item, at: index)
                        } else if item.state == .completed {
                            self.removeItemFromAdapterData(at: index, refresh: true)
                            runAfterDelay(0.25, function: {
                                self.addToAdapterData(item)
                            })
                        }
                    } else {
                        self.addToAdapterData(item)
                    }
                } else {
                    // update cell
                }
            case .remove:
                if self.itemsSource == .yours {
                    if let index = self.adapterDataIndex(itemID: item.itemID) {
                        self.removeItemFromAdapterData(at: index, refresh: true)
                    }
                } else {
                    // update cell
                }
            }
        }
    }
    
    func adapterDataIndex(itemID: Int) -> Int? {
        return self.tempItems.index(where: { $0.itemID == itemID })
    }
    
    func adapterDataIndexForOriginalItem(itemID: Int) -> Int? {
        if let index = self.tempItems.index(where: { (item) -> Bool in
            if item.itemID == itemID, item.state != .completed {
                return true
            }
            return false
        }) {
            return index
        }
        return nil
    }
    
    func removeItemFromAdapterData(at index: Int, refresh: Bool) {
        self.tempItems.remove(at: index)
        if refresh {
            self.runDataChangeOperations()
        }
    }
    
    func addToAdapterData(_ item: Item) {
        self.tempItems.insert(item, at: 0)
        self.runDataChangeOperations()
    }
    
    func updateAdapterData(withItem item: Item, at index: Int) {
        self.tempItems[index] = item
        self.runDataChangeOperations()
    }
}
