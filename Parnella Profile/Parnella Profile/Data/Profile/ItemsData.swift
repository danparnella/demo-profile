//
//  ItemsData.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

protocol ItemsDataDelegate: class {
    func itemsLoaded(data: ItemsData)
}

final class ItemsData: ListDiffable {
    enum ItemSource {
        case yours, others
    }
    
    var source: ItemSource
    var items = [Item]()
    var headerTitle: String?
    
    weak var delegate: ItemsDataDelegate?
    
    init(delegate: ItemsDataDelegate, source: ItemSource, headerTitle: String?) {
        self.delegate = delegate
        self.source = source
        self.headerTitle = headerTitle
        self.getRandomItemData()
    }
    
    func getRandomItemData() {
        let timeStamp = String(describing: Date().timeIntervalSince1970)
        let stringToConvert = "\(timeStamp)8106d4f20bb85aa99ebf0d8d26721409a7b3fe6d1ef56758b1bca5e8c20487af3e11a458"
        guard let url = URL(string: "https://gateway.marvel.com/v1/public/characters?ts=\(timeStamp)&apikey=1ef56758b1bca5e8c20487af3e11a458&hash=\(self.apiHash(stringToConvert))") else {
            print("URL broke :(")
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with:url) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    self.createItems(data: response)
                } catch let error as NSError {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }
        urlSession.resume()
    }
    
    func createItems(data: Any) {        
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
                self.items.append(nextItem)
            }
            
            self.delegate?.itemsLoaded(data: self)
        }
    }
    
    func apiHash(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "itemsList" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}
