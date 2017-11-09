//
//  ProfileBackgroundHeader.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable

@IBDesignable
final class ProfileBackgroundHeader: UIView, NibReusable {
    let nibName = ProfileBackgroundHeader.reuseIdentifier

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBlurContainerView: UIView!
    
    @IBOutlet weak var changePhotoView: UIView!
    @IBOutlet weak var changePhotoIcon: UIImageView!
    
    @IBOutlet weak var photoAttrStackView: UIStackView!
    @IBOutlet weak var photoAttrNameLabel: UILabel!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileNameLabelTopConstraint: NSLayoutConstraint!

    var imageBlurView: ProfileBackgroundBlurView?
    
    var originalNameTopConstraintConstant: CGFloat? {
        willSet {
            if let topConstraintConstant = newValue {
                self.profileNameLabelTopConstraint.constant = topConstraintConstant
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib(nibName)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib(nibName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.changePhotoIcon.changeImageColor(to: Colors().white)
    }
    
    func scrubChangePhotoAlpha(scrollViewOffset offset: CGFloat) {
        if offset <= 0 {
            self.changePhotoView.alpha = 1 + offset/75
        } else {
            self.changePhotoView.alpha = 1 - offset/30
        }
    }
    
    func updatePhotoAttribution(name: String?) {
        if let attrName = name, !attrName.isEmpty {
            self.photoAttrNameLabel.text = name
            UIView.animate(withDuration: 0.25) {
                self.photoAttrStackView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.photoAttrStackView.alpha = 0
            }
        }
    }
}
