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
    func dataUpdated()
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
    
    init() {
        self.profileData = [self.profileDetails, self.items]
        
        self.profileDetails = ProfileDetailsData()
        if let ownProfile = self.profileDetails?.ownProfile {
            self.ownProfile = ownProfile
            let source: ItemsData.ItemSource = (ownProfile) ? .yours : .others
            self.items = ItemsData(source: source)
        }
    }
    
    private func updateDataInSection(_ section: DataSection, data: ListDiffable?) {
        let index = section.rawValue
        let newData = data
        self.profileData[index] = newData
        
        self.delegate?.dataUpdated()
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
