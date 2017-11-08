//
//  ItemSmallCardCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit
import Nuke

public enum ItemAction {
    case follow, unfollow
}

protocol ItemActionDelegate: class {
    func itemButtonTapped(_ action: ItemAction, itemID: Int)
}

class ItemSmallCardCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionButtonIcon: UIImageView!
    @IBOutlet weak var actionButtonLabel: UILabel!
    
    var item: Item! {
        didSet {
            self.updateCell()
        }
    }
    
    var source: ItemsData.ItemSource!
    weak var delegate: ItemActionDelegate?
    var isUpdate = false
    
    let kPlaceholderDescription = "No description was provided for this character."
    
    override func awakeFromNib () {
        super.awakeFromNib()
        self.shadowView.addShadow()
        self.actionButtonIcon.changeImageColor(to: Colors().green)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isUpdate = false
        self.imageView.image = nil
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
            self.imageViewHeightConstraint.constant = attributes.photoHeight
        }
    }
    
    func updateCell() {
        self.imageView.fadeTransition(isEnabled: self.isUpdate)
        if let url = URL(string: item.imageURLString ?? "") {
            Nuke.loadImage(with: url, into: self.imageView)
        }
        
        self.name.text = self.item.name
        self.descriptionLabel.text = self.item.description ?? self.kPlaceholderDescription
        
        self.setupActionButton()
    }

    func setupActionButton() {
        self.actionButtonLabel.fadeTransition(isEnabled: self.isUpdate)
        
        if self.source == .yours {
            self.yoursFollowing()
        } else if self.item.viewerState == .following {
            self.othersFollowing()
        } else {
            self.othersNotFollowing()
        }
        
        self.isUpdate = true
    }
    
    func yoursFollowing() {
        self.togglePlusIcon(following: true)
        self.actionButtonLabel.text = "Unfollow"
        self.actionButton.tag = 1
    }
    
    func othersFollowing() {
        self.togglePlusIcon(following: true)
        self.actionButtonLabel.text = "Following"
        self.actionButton.tag = 1
    }
    
    func othersNotFollowing() {
        self.togglePlusIcon(following: false)
        self.actionButtonLabel.text = "Follow"
        self.actionButton.tag = 0
    }
    
    func togglePlusIcon(following: Bool) {
        func animate(toColor color: UIColor) {
            var duration = (self.isUpdate) ? 0.5 : 0
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.actionButtonIcon.transform = self.actionButtonIcon.transform.rotated(by: .pi/4)
            })
            
            duration = (self.isUpdate) ? 0.3 : 0
            UIView.animate(withDuration: duration) {
                self.actionButtonIcon.changeImageColor(to: color)
            }
        }
        
        if following {
            if self.actionButtonIcon.tintColor == Colors().green {
                animate(toColor: Colors().red)
            }
        } else {
            if self.actionButtonIcon.tintColor == Colors().red {
                animate(toColor: Colors().green)
            }
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 { // Follow
            self.delegate?.itemButtonTapped(.follow, itemID: self.item.itemID)
        } else { // Unfollow
            self.delegate?.itemButtonTapped(.unfollow, itemID: self.item.itemID)
        }
    }
}

extension ItemSmallCardCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let item = viewModel as? Item else { return }
        self.item = item
    }
}
