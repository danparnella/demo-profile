//
//  LatoFont.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/30/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit

final class LatoFont: UIFont {
    enum FontWeight: String {
        case black = "Lato-Black"
        case bold = "Lato-Bold"
        case regular = "Lato-Regular"
        case light = "Lato-Light"
        case italic = "Lato-Italic"
    }
    
    var black: UIFont {
        get {
            return self.getFont(weight: .black)
        }
    }
    var bold: UIFont {
        get {
            return self.getFont(weight: .bold)
        }
    }
    var regular: UIFont {
        get {
            return self.getFont(weight: .regular)
        }
    }
    var light: UIFont {
        get {
            return self.getFont(weight: .light)
        }
    }
    var italic: UIFont {
        get {
            return self.getFont(weight: .italic)
        }
    }
    
    func getFont(weight: FontWeight) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: 17) else { fatalError() }
        return font
    }
}

