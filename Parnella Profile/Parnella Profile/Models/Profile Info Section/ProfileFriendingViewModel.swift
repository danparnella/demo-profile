//
//  ProfileFriendingViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfileFriendingViewModel: ListDiffable {
    var friendName: String
    var requestSent = false
    var awaitingResponse = false
    
    init(friendName: String, requestSent: Bool = false, awaitingResponse: Bool = false) {
        self.friendName = friendName
        self.requestSent = requestSent
        self.awaitingResponse = awaitingResponse
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profileFriending" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileFriendingViewModel else { return false }
        
        return self.friendName == object.friendName
    }
}
