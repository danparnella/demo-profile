//
//  ItemsData.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

protocol ItemsInitialDataDelegate: class {
    func itemsLoaded(data: ItemsData)
}

protocol ItemsUpdateDataDelegate: class {
    func itemsUpdated(newItems: [Item])
}

final class ItemsData: ListDiffable {
    enum ItemSource {
        case yours, others
    }
    
    var source: ItemSource
    var items = [Item]()
    var headerTitle: String?
    var headerDescription: String?
    var offset = 20 * Int(arc4random_uniform(75))
    var pageNumber = 0
    
    var gettingData = false
    weak var loadDelegate: ItemsInitialDataDelegate?
    weak var updateDelegate: ItemsUpdateDataDelegate?
    
    init(loadDelegate: ItemsInitialDataDelegate, source: ItemSource, headerTitle: String?, headerDescription: String?) {
        self.loadDelegate = loadDelegate
        self.source = source
        self.headerTitle = headerTitle
        self.headerDescription = headerDescription
        self.getRandomItemData()
    }
    
    func getRandomItemData(nextPage: Bool = false) {
        guard offset <= 1491, pageNumber <= 5 else { return }
        
        self.gettingData = true
        
        let timeStamp = String(describing: Date().timeIntervalSince1970)
        let stringToConvert = "\(timeStamp)8106d4f20bb85aa99ebf0d8d26721409a7b3fe6d1ef56758b1bca5e8c20487af3e11a458"
        guard let url = URL(string: "https://gateway.marvel.com/v1/public/characters?offset=\(self.offset)&ts=\(timeStamp)&apikey=1ef56758b1bca5e8c20487af3e11a458&hash=\(stringToConvert.apiHash())") else {
            print("URL broke :(")
            return
        }
        
        self.offset += 20
        self.pageNumber += 1
        
        let urlSession = URLSession.shared.dataTask(with:url) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    self.createItems(data: response, nextPage: nextPage)
                } catch let error as NSError {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }
        urlSession.resume()
    }
    
    func createItems(data: Any, nextPage: Bool) {
        var nextPageArray = [Item]()
        
        if let container = data as? [String: Any],
            let characterDataContainer = container["data"] as? [String: Any],
            let characterResults = characterDataContainer["results"] as? [[String: Any]]
        {
            for character in characterResults {
                let nextItem = Item(data: character)
                if source == .others {
                    if let viewerState = Item.ItemState(rawValue: Int(arc4random_uniform(3))) {
                        nextItem.viewerState = viewerState
                    }
                }
                if !nextItem.skipItem {
                    if nextPage {
                        nextPageArray.append(nextItem)
                    } else {
                        self.items.append(nextItem)
                    }
                }
            }
            
            if nextPage {
                self.updateDelegate?.itemsUpdated(newItems: nextPageArray)
            } else {
                if self.items.count > 5 {
                    self.loadDelegate?.itemsLoaded(data: self)
                } else {
                    self.getRandomItemData()
                }
            }
        }
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "itemsList" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}
