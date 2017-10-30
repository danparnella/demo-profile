//
//  ProfileBackgroundBlurView.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit

final class ProfileBackgroundBlurView: UIVisualEffectView {
    var animator: UIViewPropertyAnimator?
    var currentScrollViewOffset: CGFloat = 0
    
    init(profileBackgroundView: ProfileBackgroundHeader) {
        super.init(effect: nil)
        guard let container = profileBackgroundView.imageBlurContainerView else { fatalError() }
        self.setupView(inside: container)
        self.setupAnimator()
        self.registerNotifications()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView(inside container: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        container.addSubview(self)
        self.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
    }
}

// MARK: Operational Funcs
extension ProfileBackgroundBlurView {
    func setupAnimator() {
        self.animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            self.effect = UIBlurEffect(style: .dark)
        }
        self.animator?.startAnimation()
        self.animator?.pauseAnimation()
    }
    
    @objc func stopAnimator() {
        if self.animator?.state != .stopped {
            self.animator?.pauseAnimation()
            self.animator?.stopAnimation(false)
        }
    }
    
    func clearAnimator() {
        self.animator?.finishAnimation(at: .current)
        self.effect = nil
        self.animator = nil
    }
    
    @objc func restartAnimator() {
        self.clearAnimator()
        self.setupAnimator()
        self.scrubAnimator(scrollViewOffset: self.currentScrollViewOffset)
    }
    
    func scrubAnimator(scrollViewOffset offset: CGFloat) {
        self.currentScrollViewOffset = offset
        let blurFraction: CGFloat = {
            if offset <= -20 {
                return -(offset + 20)/150
            }
            if offset > 20 {
                return (offset - 20)/100
            }
            return 0
        }()
        
        self.animator?.fractionComplete = (blurFraction < 0.75) ? blurFraction : 0.75
    }
}

// MARK: Notifications
extension ProfileBackgroundBlurView {
    func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.stopAnimator),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.restartAnimator),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }
}
