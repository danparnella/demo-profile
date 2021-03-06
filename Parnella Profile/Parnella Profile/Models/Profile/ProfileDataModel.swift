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

    var profileDetails: ProfileDetailsData? {
        didSet {
            self.updateDataInSection(.profileDetails, data: self.profileDetails)
        }
    }
    var items: ItemsData? {
        didSet {
            self.updateDataInSection(.items, data: self.items)
        }
    }
    
    var ownProfile = false
    var profileData: [ListDiffable?]
    weak var delegate: ProfileDataModelDelegate?
    
    var threshold: CGFloat = 0
    
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
    
    func removeDataInSection(_ section: DataSection) {
        switch section {
        case .profileDetails: self.profileDetails = nil
        case .items: self.items = nil
        }
    }
    
    func checkThreshold(_ offset: CGFloat) {
        guard let itemsData = self.items else { return }
        
        if offset >= self.threshold && !itemsData.gettingData {
            itemsData.getRandomItemData(nextPage: true)
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

// MARK: Delegates
extension ProfileDataModel: ProfileDetailsDataDelegate {
    func backgroundImageLoaded(urlString: String?) {
        self.delegate?.bkgdImageLoaded(urlString)
    }
    
    func detailsLoaded(data: ProfileDetailsData) {
        self.profileDetails = data
        
        if let ownProfile = self.profileDetails?.ownProfile {
            self.ownProfile = ownProfile
            let source: ItemsData.ItemSource = (ownProfile) ? .yours : .others
            _ = ItemsData(loadDelegate: self, source: source, headerTitle: "Followed Characters", headerDescription: "Data provided by Marvel. © 2014 Marvel")
        }
    }
}

extension ProfileDataModel: ItemsInitialDataDelegate {
    func itemsLoaded(data: ItemsData) {
        self.items = data
    }
}
