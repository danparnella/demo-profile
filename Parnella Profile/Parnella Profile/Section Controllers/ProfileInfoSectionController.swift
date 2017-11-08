//
//  ProfileInfoSectionController.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ProfileInfoSectionController: ListBindingSectionController<ProfileDetailsData> {
    var updateData: ProfileDetailsData?
    var backgroundImageHeight: CGFloat = 0
    
    override init() {
        super.init()
        self.dataSource = self
    }
}

extension ProfileInfoSectionController: ListBindingSectionControllerDataSource {
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ProfileDetailsData else { fatalError() }
        
        if self.updateData == nil {
            self.updateData = object
        }
        
        guard let data = self.updateData else { fatalError() }
        var viewModels: [ListDiffable] = [
            ProfilePhotoLineViewModel(
                friendsCount: data.friendsCount,
                ownProfile: data.ownProfile,
                followingCount: data.followingCount,
                profileImageURLString: data.profileImageURLString
            ),
            ProfileDetailsViewModel(
                fullName: data.fullName,
                firstName: data.firstName,
                location: data.location,
                birthday: data.birthday,
                isFriend: data.isFriend,
                relationshipName: data.relationshipName
            )
        ]
        
        if !data.ownProfile && !data.isFriend, let firstName = data.firstName {
            let friendViewModel = ProfileFriendingViewModel(friendName: firstName, requestSent: data.requestSent, awaitingResponse: data.awaitingResponse)
            viewModels.append(friendViewModel)
        }
        
        return viewModels
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = self.collectionContext?.insetContainerSize.width, let data = self.updateData else { fatalError() }
        
        let height: CGFloat = {
            switch viewModel {
            case is ProfilePhotoLineViewModel:
                return (self.backgroundImageHeight - 55) + (width * (5/14))
            case is ProfileDetailsViewModel:
                var height: CGFloat = 34 + 10 // profile name height + top padding
                if data.location != nil || data.birthday != nil {
                    height += 22
                }
                if data.ownProfile {
                    if data.relationshipName != nil {
                        height += 28
                    }
                } else if data.isFriend {
                    height += 28
                }
                return height
            case is ProfileFriendingViewModel:
                if !data.ownProfile {
                    return 80
                }
                return 0
            default:
                return 0
            }
        }()
        
        return CGSize(width: width, height: height)
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let cellIdentifier: String = {
            switch viewModel {
            case is ProfilePhotoLineViewModel: return ProfilePhotoCollectionViewCell.reuseIdentifier
            case is ProfileDetailsViewModel: return ProfileDetailsCollectionViewCell.reuseIdentifier
            case is ProfileFriendingViewModel: return ProfileFriendButtonCollectionViewCell.reuseIdentifier
            default: return String()
            }
        }()
        
        guard let cell = self.collectionContext?.dequeueReusableCell(withNibName: cellIdentifier, bundle: .main, for: self, at: index) as? UICollectionViewCell & ListBindable else {
            fatalError()
        }
        
        if let cell = cell as? ProfilePhotoCollectionViewCell {
            cell.backgroundPhotoButtonHeightConstraint.constant = self.backgroundImageHeight
            cell.backgroundPhotoButtonVerticalSpacingConstraint.constant = -self.backgroundImageHeight * (5/13)
            cell.layoutIfNeeded()
            
            if let viewController = self.viewController as? ProfileViewController {
                viewController.delegate = cell
            }
        } else if let cell = cell as? ProfileDetailsCollectionViewCell {
            cell.ownProfile = self.updateData?.ownProfile ?? false
        }
        
        return cell
    }
}
