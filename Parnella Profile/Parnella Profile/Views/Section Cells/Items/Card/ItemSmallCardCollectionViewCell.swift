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
    case add, remove, complete
}

protocol ItemActionDelegate: class {
    func itemButtonTapped(_ action: ItemAction, index: Int)
}

class ItemSmallCardCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var itemStateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryIcon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var leftButtonIcon: UIImageView!
    @IBOutlet weak var leftButtonLabel: UILabel!
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var rightButtonIcon: UIImageView!
    @IBOutlet weak var rightButtonLabel: UILabel!
    
    var index = 0
    var source: ItemsData.ItemSource!
    weak var delegate: ItemActionDelegate?
    var isUpdate = false
    
    override func awakeFromNib () {
        super.awakeFromNib()
        self.shadowView.addShadow()
        self.leftButtonIcon.changeImageColor(to: Colors().green)
        self.rightButtonIcon.changeImageColor(to: Colors().blue)
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
    
    func updateCell(_ item: Item) {
//        guard let catid = item.getCategoryIdAsInt(), let category = VivaneerCategory(rawValue: catid) else {
//            return
//        }
        
        self.imageView.fadeTransition(isEnabled: self.isUpdate)
        if let url = URL(string: item.imageURLString ?? "") {
            Nuke.loadImage(with: url, into: self.imageView)
        }
        
        self.itemStateLabel.fadeTransition(isEnabled: self.isUpdate)
        if item.state == .completed {
            self.itemStateLabel.text = "COMPLETED"
            self.itemStateLabel.backgroundColor = Colors().blue
            self.imageView.backgroundColor = Colors().blue
        } else {
            self.itemStateLabel.text = "TO DO"
            self.itemStateLabel.backgroundColor = Colors().green
            self.imageView.backgroundColor = Colors().green
        }
        
//        self.categoryLogo.fadeTransition(isEnabled: self.isUpdate)
//        self.categoryLogo.image = category.getImage()
        
        self.name.text = item.name
        self.descriptionLabel.text = item.description
        
        self.setFooterButtons(item)
    }

    func setFooterButtons(_ item: Item) {
        self.leftButtonLabel.fadeTransition(isEnabled: self.isUpdate)
        self.rightButtonLabel.fadeTransition(isEnabled: self.isUpdate)
        self.rightButtonLabel.text = "Complete"
        
        if self.source == .yours {
            if item.state == .completed {
                self.youCompleted()
            } else {
                self.youAdded()
            }
        } else if item.viewerState == .completed {
            self.othersYouCompleted()
        } else if item.viewerState == .toDo {
            self.othersYouAdded()
        } else {
            self.othersNotAddedOrCompleted()
        }
        
        self.isUpdate = true
    }
    
    func youAdded() {
        self.togglePlusIcon(showAdd: false)
        self.leftButtonLabel.text = "Remove"
        self.leftButton.tag = 1
    }
    
    func youCompleted() {
        self.togglePlusIcon(showAdd: true)
        self.leftButtonLabel.text = "Add Again"
        self.rightButtonLabel.text = "Complete Again"
        self.leftButton.tag = 0
    }
    
    func othersYouAdded() {
        self.togglePlusIcon(showAdd: false)
        self.leftButtonLabel.text = "On Your List"
        self.leftButton.tag = 1
    }
    
    func othersYouCompleted() {
        self.youCompleted()
    }
    
    func othersNotAddedOrCompleted() {
        self.togglePlusIcon(showAdd: true)
        self.leftButtonLabel.text = "Add To Do"
        self.leftButton.tag = 0
    }
    
    func togglePlusIcon(showAdd: Bool) {
        func animate(toColor color: UIColor) {
            var duration = (self.isUpdate) ? 0.5 : 0
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.leftButtonIcon.transform = self.leftButtonIcon.transform.rotated(by: .pi/4)
            })
            
            duration = (self.isUpdate) ? 0.3 : 0
            UIView.animate(withDuration: duration) {
                self.leftButtonIcon.changeImageColor(to: color)
            }
        }
        
        if showAdd {
            if self.leftButtonIcon.tintColor == Colors().red {
                animate(toColor: Colors().green)
            }
        } else {
            if self.leftButtonIcon.tintColor == Colors().green {
                animate(toColor: Colors().red)
            }
        }
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 { // ADD
            sender.isUserInteractionEnabled = false
            self.delegate?.itemButtonTapped(.add, index: self.index)
        } else { // REMOVE
            self.delegate?.itemButtonTapped(.remove, index: self.index)
        }
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 { // COMPLETE
            self.delegate?.itemButtonTapped(.complete, index: self.index)
        }
    }
}

extension ItemSmallCardCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let item = viewModel as? Item else { return }
        self.updateCell(item)
    }
}
