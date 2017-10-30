//
//  ProfileDetailsViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfileDetailsViewModel: ListDiffable {
    var fullName: String?
    var firstName: String?
    var location: String?
    var birthday: String?
    
    var isFriend = false
    var relationshipName: String?
    
    init(fullName: String?, firstName: String?, location: String?, birthday: String?, isFriend: Bool, relationshipName: String? = nil) {
        self.fullName = fullName
        self.firstName = firstName
        self.location = location
        self.birthday = birthday
        self.isFriend = isFriend
        self.relationshipName = relationshipName
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profileDetails" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileDetailsViewModel else { return false }
        
        if self.fullName == object.fullName {
            if self.location == object.location {
                if self.birthday == object.birthday {
                    return self.relationshipName == object.relationshipName
                }
            }
        }
        return false
    }
}
