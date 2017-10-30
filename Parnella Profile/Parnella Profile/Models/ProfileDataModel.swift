//
//  ProfileDataModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import Foundation
import IGListKit

protocol ProfileDataModelDelegate: class {
    func bkgdImageLoaded(_ urlString: String?)
    func dataLoaded()
}

final class ProfileDataModel {
    enum DataSection: Int {
        case profileDetails, items
    }

    var ownProfile = false
    weak var delegate: ProfileDataModelDelegate?

    var profileDetails: ProfileDetailsData? {
        willSet {
            self.updateDataInSection(.profileDetails, data: newValue)
        }
    }
    var items: ItemsData? {
        willSet {
            self.updateDataInSection(.items, data: newValue)
        }
    }
    
    var profileData: [ListDiffable?]
    
    init(ownProfile: Bool) {
        self.profileData = [self.profileDetails, self.items]
        _ = ProfileDetailsData(delegate: self, ownProfile: ownProfile)
    }
    
    private func updateDataInSection(_ section: DataSection, data: ListDiffable?) {
        let index = section.rawValue
        let newData = data
        self.profileData[index] = newData
        
        self.delegate?.dataLoaded()
    }
    
    func removeDataForSection(_ section: DataSection) {
        switch section {
        case .profileDetails: self.profileDetails = nil
        case .items: self.items = nil
        }
    }
    
    func getData() -> [ListDiffable] {
        var data = [ListDiffable]()
        for object in self.profileData {
            if let realData = object {
                data.append(realData)
            }
        }
        
        return data
    }
}

// MARK: Delegate
extension ProfileDataModel: ProfileDetailsDataDelegate {
    func backgroundImageLoaded(urlString: String?) {
        self.delegate?.bkgdImageLoaded(urlString)
    }
    
    func detailsLoaded(data: ProfileDetailsData) {
        self.profileDetails = data
        
        if let ownProfile = self.profileDetails?.ownProfile {
            self.ownProfile = ownProfile
            let source: ItemsData.ItemSource = (ownProfile) ? .yours : .others
            self.items = ItemsData(source: source)
        }
    }
}
