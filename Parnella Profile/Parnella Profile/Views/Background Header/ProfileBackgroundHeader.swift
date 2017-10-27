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
    var imageBlurView: ProfileBackgroundBlurView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }
    
    func scrubChangePhotoAlpha(scrollViewOffset offset: CGFloat) {
        if offset <= 0 {
            self.changePhotoView.alpha = 1 + offset/75
        } else if offset > 0 {
            self.changePhotoView.alpha = 1 - offset/30
        }
    }
}

extension ProfileBackgroundHeader {
    func setupNib() {
        var view = UIView()
        view = ProfileBackgroundHeader.loadFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
    }
}
