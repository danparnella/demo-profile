//
//  HeaderCollectionViewCell.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import Reusable
import IGListKit

class HeaderCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDescription: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.headerDescription.isHidden = true
    }
    
    func setup(title: String, description: String? = nil) {
        self.headerTitleLabel.text = title
        
        if let description = description {
            self.headerDescription.text = description
            self.headerDescription.isHidden = false
        }
    }
}

extension HeaderCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ContentHeaderViewModel else { return }
        self.setup(title: viewModel.title, description: viewModel.description)
    }
}
