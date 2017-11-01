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
    
    @IBOutlet weak var photoViews: UIView!
    @IBOutlet weak var photoDropShadowView: UIImageView!
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
    var photoViewsYOrigin: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.changePhotoIcon.changeImageColor(to: Colors().white)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoBorderView.makeCircle()
        self.photoContainerView.makeCircle()
        if self.photoViewsYOrigin == nil {
            self.photoViewsYOrigin = self.photoViews.frame.origin.y
        }
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

// MARK: Cell Setup
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

// MARK: List Binding
extension ProfilePhotoCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfilePhotoLineViewModel else { return }
        self.setupCell(data: viewModel)
    }
}

// MARK: Delegate
extension ProfilePhotoCollectionViewCell: ProfileViewControllerDelegate {
    func updateBasedOnScroll(_ offset: CGFloat, backgroundPhotoView: ProfileBackgroundHeader) {
        guard let originalYOrigin = self.photoViewsYOrigin else { return }

        if backgroundPhotoView.originalNameTopConstraintConstant == nil {
            backgroundPhotoView.originalNameTopConstraintConstant = self.frame.height - self.backgroundPhotoButtonHeightConstraint.constant + 18
        }
        
        if offset <= self.backgroundPhotoButtonHeightConstraint.constant {
            if offset > 0 {
                var scale = 1 - offset/350
                scale = (scale <= 0) ? 0.1 : scale
                self.photoViews.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                let originOffset = offset/2.65
                self.photoViews.frame.origin.y = originalYOrigin + originOffset
                self.photoDropShadowView.alpha = 1 - offset/85
            } else {
                self.photoViews.transform = CGAffineTransform.identity
                self.photoViews.frame.origin.y = originalYOrigin
                self.photoDropShadowView.alpha = 1
            }
        } else if let originalTopConstraint = backgroundPhotoView.originalNameTopConstraintConstant {
            var newConstant = originalTopConstraint - (offset - self.backgroundPhotoButtonHeightConstraint.constant)
            newConstant = (newConstant >= -32.5) ? newConstant : -32.5
            backgroundPhotoView.profileNameLabelTopConstraint.constant = newConstant
            backgroundPhotoView.layoutIfNeeded()
        }
    }
}
