//
//  ProfileDetailsData.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfileDetailsData: ListDiffable {
    let ownProfile: Bool
    let friendsCount: Int
    let followingCount: Int

    var requestSent = false
    var awaitingResponse = false
    
    var profileImageURLString: String?
    var firstName: String?
    var fullName: String?
    var location: String?
    var birthday: String?
    var relationshipName: String?
    
    var userID: String!
    
    init() {
        self.ownProfile = (arc4random_uniform(2) == 0)
        
        if !self.ownProfile {
            self.requestSent = (arc4random_uniform(2) == 0)
            if !self.requestSent {
                self.awaitingResponse = (arc4random_uniform(2) == 0)
            }
        }
        
        self.friendsCount = Int(arc4random_uniform(1001))
        self.followingCount = Int(arc4random_uniform(301))
        self.getRandomUserData()
    }
    
    func getRandomUserData() {
        guard let url = URL(string: "https://randomuser.me/api/") else {
            print("URL broke :(")
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with:url) { (data, response, error) in
           if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    print(response)
                } catch let error as NSError {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }
        urlSession.resume()
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self.userID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileDetailsData else { return false }
        return self.diffIdentifier().isEqual(object.diffIdentifier())
    }
}
