//
//  ProfileDetailsCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit

protocol ProfileDetailsCellDelegate: class {
    func relationshipButtonTapped()
}

class ProfileDetailsCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var locationBirthdayStackView: UIStackView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var birthdayStackView: UIStackView!
    @IBOutlet weak var birthdayIcon: UIImageView!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var relationshipStackView: UIStackView!
    @IBOutlet weak var relationshipIcon: UIImageView!
    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var relationshipProfileButton: UIButton!
    
    @IBOutlet var allStackViews: [UIStackView]!
    
    weak var delegate: ProfileDetailsCellDelegate?
    var ownProfile = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.locationIcon.changeImageColor(to: Colors().gray666)
        self.birthdayIcon.changeImageColor(to: Colors().gray666)
        self.relationshipIcon.changeImageColor(to: Colors().grayA7)
    }
    
    @IBAction func relationshipButtonTapped(_ sender: UIButton) {
        self.delegate?.relationshipButtonTapped()
    }
}

// MARK: Cell Setup
extension ProfileDetailsCollectionViewCell {
    func setupCell(data: ProfileDetailsViewModel) {
        self.nameLabel.text = data.fullName
        
        let locationPresent = (data.location != nil)
        let birthdayPresent = (data.birthday != nil)
        let relationshipPresent = (data.relationshipName != nil)
        
        self.locationStackView.isHidden = !locationPresent
        self.birthdayStackView.isHidden = !birthdayPresent || (!self.ownProfile && !data.isFriend)
        self.locationBirthdayStackView.isHidden = (!locationPresent && self.birthdayStackView.isHidden)
        self.relationshipStackView.isHidden = ((self.ownProfile && !relationshipPresent) || (!self.ownProfile && !data.isFriend))
        self.relationshipProfileButton.isHidden = self.relationshipStackView.isHidden
        
        self.detailsStackView.isHidden = (!locationPresent && self.birthdayStackView.isHidden && self.relationshipStackView.isHidden)
        
        for stackView in self.allStackViews {
            if stackView.isHidden {
                stackView.spacing = 0
            }
        }
        
        self.locationLabel.text = data.location
        self.birthdayLabel.text = data.birthday
        if relationshipPresent {
            self.relationshipIcon.changeImageColor(to: Colors().red)
            self.relationshipLabel.text = data.relationshipName
        } else if data.isFriend {
            self.relationshipLabel.text = "Send a relationship request to \(data.firstName ?? "them")?"
        }
    }
}

// MARK: List Binding
extension ProfileDetailsCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfileDetailsViewModel else { return }
        self.setupCell(data: viewModel)
    }
}
