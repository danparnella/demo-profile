//
//  Extensions.swift
//  Parnella Profile
//
//  Created by Daniel Parnella on 10/27/17.
//  Copyright © 2017 Daniel Parnella. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideNavigationBarBkgd() {
        if let navBar = self.navigationController?.navigationBar {
            navBar.isTranslucent = true
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
        }
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    func makeCircle() {
        layoutIfNeeded()
        layer.cornerRadius = bounds.height/2
        clipsToBounds = true
    }
    
    func setupNib(_ nibName: String) {
        func loadViewFromNib() -> UIView {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: nibName, bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            
            return view
        }
        
        var view = UIView()
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
    }
}

extension String {
    func convertToDisplayDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}

extension UIImageView {
    func changeImageColor(to color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}
