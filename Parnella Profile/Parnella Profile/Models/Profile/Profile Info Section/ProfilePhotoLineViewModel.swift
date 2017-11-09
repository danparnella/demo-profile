//
//  ProfilePhotoLineViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfilePhotoLineViewModel: ListDiffable {
    var numberOfFriends: String
    var ownProfile: Bool
    var numberOfComics: String
    var profileImageURLString: String?
    
    init(friendsCount: Int, ownProfile: Bool, comicsCount: Int, profileImageURLString: String?) {
        self.numberOfFriends = String(describing: friendsCount)
        self.ownProfile = ownProfile
        self.numberOfComics = String(describing: comicsCount)
        self.profileImageURLString = profileImageURLString
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profilePhotoLine" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfilePhotoLineViewModel else { return false }
        
        if self.numberOfFriends == object.numberOfFriends {
            if self.numberOfComics == object.numberOfComics {
                return self.profileImageURLString == object.profileImageURLString
            }
        }
        return false
    }
}
