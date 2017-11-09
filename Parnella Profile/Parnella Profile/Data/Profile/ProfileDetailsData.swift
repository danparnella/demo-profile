//
//  ProfileDetailsData.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

protocol ProfileDetailsDataDelegate: class {
    func backgroundImageLoaded(urlString: String?)
    func detailsLoaded(data: ProfileDetailsData)
}

final class ProfileDetailsData: ListDiffable {
    let ownProfile: Bool
    let friendsCount: Int
    let comicsCount: Int

    var isFriend = false
    var requestSent = false
    var awaitingResponse = false
    
    var backgroundImageURLString: String?
    var backgroundImageAttrURLString: String?
    var backgroundImageAttrName: String?
    
    var profileImageURLString: String?
    var firstName: String?
    var fullName: String?
    var location: String?
    var birthday: String?

    var inRelationship = false
    var relationshipName: String?
    
    weak var delegate: ProfileDetailsDataDelegate?
    
    init(delegate: ProfileDetailsDataDelegate, ownProfile: Bool) {
        self.delegate = delegate
        
        self.ownProfile = ownProfile
        
        if !self.ownProfile {
            self.isFriend = randomBool()
            if !self.isFriend {
                self.requestSent = randomBool()
                if !self.requestSent {
                    self.awaitingResponse = randomBool()
                }
            }
        }
        
        self.friendsCount = Int(arc4random_uniform(1001))
        self.comicsCount = Int(arc4random_uniform(301))

        self.inRelationship = randomBool()
        
        self.getBackgroundPhoto()
        self.getRandomUserData()
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "profileDetails" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

// MARK: Data Handling
extension ProfileDetailsData {
    func getBackgroundPhoto() {
        guard let url = URL(string: "https://api.unsplash.com/photos/random?orientation=landscape&client_id=d2a3cc6fe413710d74b49502129e0b2f7423b12f0bc121a38776d14613d2959d") else {
            print("URL is broken :(")
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    self.processBackgroundImageData(response)
                } catch let error as NSError {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }
        urlSession.resume()
    }
    
    func getRandomUserData(forRelationship: Bool = false) {
        guard let url = URL(string: "https://randomuser.me/api/?nat=us") else {
            print("URL is broken :(")
            return
        }
        
        let urlSession = URLSession.shared.dataTask(with: url) { (data, response, error) in
           if let data = data {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    if forRelationship {
                        self.processRelationshipData(response)
                    } else {
                        self.processUserData(response)
                    }
                } catch let error as NSError {
                    print(error)
                }
            } else if let error = error {
                print(error)
            }
        }
        urlSession.resume()
    }
    
    func getFullProfileData(_ data: Any) -> [String: Any]? {
        if let container = data as? [String: Any] {
            if let fullProfile = (container["results"] as? [[String: Any]])?.first {
                return fullProfile
            }
        }
        return nil
    }
    
    func processBackgroundImageData(_ data: Any) {
        if let container = data as? [String: Any] {
            if let urls = container["urls"] as? [String: String], let smallSizePhoto = urls["small"] {
                self.backgroundImageURLString = smallSizePhoto
            }
            
            if let userDetails = container["user"] as? [String: Any] {
                self.backgroundImageAttrName = userDetails["name"] as? String
                
                if let userLinks = userDetails["links"] as? [String: String], let htmlLink = userLinks["html"] {
                    self.backgroundImageAttrURLString = htmlLink + "?utm_source=parnella_profile&utm_medium=referral&utm_campaign=api-credit"
                }
            }
        }
        
        self.delegate?.backgroundImageLoaded(urlString: self.backgroundImageURLString)
    }
    
    func processUserData(_ data: Any) {
        if let fullProfile = self.getFullProfileData(data) {
            if let name = fullProfile["name"] as? [String: String],
                let firstName = name["first"],
                let lastName = name["last"]
            {
                self.firstName = firstName.capitalized
                self.fullName = firstName.capitalized + " " + lastName.capitalized
            }
            
            if let photos = fullProfile["picture"] as? [String: String],
                let largeSizePhoto = photos["large"]
            {
                self.profileImageURLString = largeSizePhoto
            }
            
            if let location = fullProfile["location"] as? [String: Any],
                let city = location["city"] as? String,
                let state = location["state"] as? String
            {
                self.location = city.capitalized + ", " + state.capitalized
            }
            
            if let birthday = fullProfile["dob"] as? String {
                self.birthday = birthday.convertToDisplayDate()
            }
        }
        
        if self.inRelationship {
            self.getRandomUserData(forRelationship: true)
        } else {
            self.delegate?.detailsLoaded(data: self)
        }
    }
    
    func processRelationshipData(_ data: Any) {
        if let fullProfile = self.getFullProfileData(data) {
            if let name = fullProfile["name"] as? [String: String],
                let firstName = name["first"],
                let lastName = name["last"]
            {
                self.relationshipName = firstName.capitalized + " " + lastName.capitalized
            }
        }
        
        self.delegate?.detailsLoaded(data: self)
    }
}
