//
//  ContentHeaderViewModel.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/28/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit
import IGListKit

final class ContentHeaderViewModel: ListDiffable {
    let title: String
    let description: String?
    
    let kHeaderDefaultHeight: CGFloat = 40
    let kHeaderBottomPadding: CGFloat = 3
    
    init(title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }
    
    func getDescriptionHeight(_ width: CGFloat) -> CGFloat {
        let descriptionFont = LatoFont().bold.withSize(14)
        if let textHeight = self.description?.heightFromText(font: descriptionFont, width: width) {
            return textHeight + self.kHeaderBottomPadding
        }
        return 0
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "header" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ContentHeaderViewModel else { return false }
        return self.title == object.title && self.description == object.description
    }
}
