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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.locationIcon.changeImageColor(to: VivaneerColors.darkGreyTextColor())
        self.birthdayIcon.changeImageColor(to: VivaneerColors.darkGreyTextColor())
        self.relationshipIcon.changeImageColor(to: VivaneerColors.a7a7a7Color())
    }
    
    @IBAction func relationshipButtonTapped(_ sender: UIButton) {
        self.delegate?.relationshipButtonTapped()
    }
}

//MARK: CELL SETUP
extension ProfileDetailsCollectionViewCell {
    func setupCell(data: ProfileDetailsViewModel) {
        self.nameLabel.text = data.profileName
        
        self.locationStackView.isHidden = data.location.isEmpty
        self.birthdayStackView.isHidden = data.birthday.isEmpty
        self.locationBirthdayStackView.isHidden = (data.location.isEmpty && data.birthday.isEmpty)
        self.relationshipStackView.isHidden = (data.relationshipFriend == nil)
        self.relationshipProfileButton.isHidden = (data.relationshipFriend == nil)
        
        self.detailsStackView.isHidden = (self.locationBirthdayStackView.isHidden && self.relationshipStackView.isHidden)
        
        for stackView in self.allStackViews {
            if stackView.isHidden {
                stackView.spacing = 0
            }
        }
        
        self.locationLabel.text = data.location
        self.birthdayLabel.text = data.birthday
        self.relationshipLabel.text = data.relationshipFriend?.fullName()
    }
}

//MARK: LIST BINDING
extension ProfileDetailsCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfileDetailsViewModel else { return }
        self.setupCell(data: viewModel)
    }
}
