//
//  ProfileFriendButtonCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/26/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit

protocol ProfileFriendButtonDelegate: class {
    func addFriendButtonTapped()
    func cancelRequestButtonTapped()
    func ignoreButtonTapped()
}

class ProfileFriendButtonCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var respondButtonsStackView: UIStackView!
    @IBOutlet weak var addFriendMessageLabel: UILabel!
    
    weak var delegate: ProfileFriendButtonDelegate?
    
    @IBAction func friendButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            self.delegate?.addFriendButtonTapped()
        } else {
            self.delegate?.cancelRequestButtonTapped()
        }
    }
    
    @IBAction func ignoreButtonTapped(_ sender: UIButton) {
        self.delegate?.ignoreButtonTapped()
    }
}

// MARK: Cell Setup
extension ProfileFriendButtonCollectionViewCell {
    func setupCell(data: ProfileFriendingViewModel) {
//        self.addFriendMessageLabel.text = self.addFriendMessageLabel.text?.replacingOccurrences(of: "*blank*", with: data.friendName)
        if data.requestSent {
            self.addFriendButton.setTitle("Cancel Request", for: .normal)
            self.addFriendButton.setTitleColor(Colors().red, for: .normal)
            self.addFriendButton.borderColor = Colors().red
            self.addFriendButton.tag = 1
        } else if data.awaitingResponse {
            self.addFriendButton.isHidden = true
            self.respondButtonsStackView.isHidden = false
        }
    }
}

// MARK: List Binding
extension ProfileFriendButtonCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfileFriendingViewModel else { return }
        self.setupCell(data: viewModel)
    }
}
