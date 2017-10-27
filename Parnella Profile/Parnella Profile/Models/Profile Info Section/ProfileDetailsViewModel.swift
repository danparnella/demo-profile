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
    var profileName: String?
    var location: String?
    var birthday: String?
    var relationshipName: String?
    
    init(name: String?, location: String?, birthday: String?, relationshipName: String? = nil) {
        self.profileName = name
        self.location = location
        self.birthday = birthday
        self.relationshipName = relationshipName
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profileDetails" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileDetailsViewModel else { return false }
        
        if self.profileName == object.profileName {
            if self.location == object.location {
                if self.birthday == object.birthday {
                    return self.relationshipName == object.relationshipName
                }
            }
        }
        return false
    }
}
