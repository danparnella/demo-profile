//
//  ProfilePhotoCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit
import Nuke

protocol ProfilePhotoCellDelegate: class {
    func friendsButtonTapped()
    func followingButtonTapped()
    func changeBackgroundPhotoTapped()
    func changeProfilePhotoTapped()
}

class ProfilePhotoCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var friendsTallyLabel: UILabel!
    
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var followingTallyLabel: UILabel!
    
    @IBOutlet weak var photoBorderView: UIView!
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var changePhotoView: UIView!
    @IBOutlet weak var changePhotoIcon: UIImageView!
    @IBOutlet weak var changeProfilePhotoButton: UIButton!
    
    @IBOutlet weak var changeBkgdPhotoButton: UIButton!
    @IBOutlet weak var backgroundPhotoButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundPhotoButtonVerticalSpacingConstraint: NSLayoutConstraint!
    
    weak var delegate: ProfilePhotoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.changePhotoIcon.changeImageColor(to: Colors().white)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoBorderView.makeCircle()
        self.photoContainerView.makeCircle()
    }

    @IBAction func friendsButtonTapped(_ sender: UIButton) {
        self.delegate?.friendsButtonTapped()
    }
    
    @IBAction func followingButtonTapped(_ sender: UIButton) {
        self.delegate?.followingButtonTapped()
    }
    
    @IBAction func changeBackgroundPhotoTapped(_ sender: UIButton) {
        self.delegate?.changeBackgroundPhotoTapped()
    }
    
    @IBAction func changeProfilePhotoTapped(_ sender: UIButton) {
        self.delegate?.changeProfilePhotoTapped()
    }
}

//MARK: CELL SETUP
extension ProfilePhotoCollectionViewCell {
    func setupCell(data: ProfilePhotoLineViewModel) {
        self.friendsTallyLabel.text = data.numberOfFriends
        self.followingTallyLabel.text = data.numberOfFollowing
        self.loadProfileImage(urlString: data.profileImageURLString)
        
        if data.ownProfile {
            self.changePhotoView.isHidden = false
            self.changeBkgdPhotoButton.isUserInteractionEnabled = true
            self.changeProfilePhotoButton.isUserInteractionEnabled = true
        }
    }
    
    func loadProfileImage(urlString: String?) {
        if let url = URL(string: urlString ?? "") {
            Nuke.loadImage(with: url, into: self.imageView)
        }
    }
}

//MARK: LIST BINDING
extension ProfilePhotoCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfilePhotoLineViewModel else { return }
        self.setupCell(data: viewModel)
    }
}
