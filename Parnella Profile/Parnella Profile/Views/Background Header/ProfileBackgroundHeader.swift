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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBlurContainerView: UIView!
    @IBOutlet weak var changePhotoView: UIView!
    @IBOutlet weak var changePhotoIcon: UIImageView!
    var imageBlurView: ProfileBackgroundBlurView?
    
    let nibName = ProfileBackgroundHeader.reuseIdentifier
    
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
        } else if offset > 0 {
            self.changePhotoView.alpha = 1 - offset/30
        }
    }
}
