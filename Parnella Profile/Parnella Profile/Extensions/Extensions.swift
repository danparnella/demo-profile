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
    
    func addShadow(opacity: Float = 0.1, radius: CGFloat = 2) {
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = radius
    }
    
    func fadeTransition(_ duration: CFTimeInterval = 0.25, isEnabled: Bool = true) {
        if isEnabled {
            let animation:CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            animation.duration = duration
            self.layer.add(animation, forKey: kCATransitionFade)
        } else {
            self.layer.removeAllAnimations()
        }
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
    
    func heightFromText(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func apiHash() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
}

extension UIImageView {
    func changeImageColor(to color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}

public func randomBool() -> Bool {
    return (arc4random_uniform(2) == 0)
}

public func runAfterDelay(_ delay: Double, function: @escaping () -> Void){
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: function)
}
