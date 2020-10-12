//
//  Extensions.swift
//  Chess
//
//  Created by hyperactive on 05/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

extension UIImageView {

    func addShadowOnCheck() {
        self.layer.shadowColor = UIColor.red.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 3
        
        self.layer.shadowPath = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
    }
}

extension UIViewController {
    func setBackgroundImage(_ imageName: String) {
        let backgroundImage = UIImage(named: imageName)
        let frame = CGRect(x: -(self.view.frame.width / 1.35), y: 0, width: self.view.frame.width * 2.5, height: self.view.frame.height)
        let backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.image = backgroundImage
        self.view.insertSubview(backgroundImageView, at: 0)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension UIViewController {
    
    func showUpdate(_ update : String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0).isActive = true
        
        label.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        label.text = "update"
        label.layer.cornerRadius = 25
        label.layer.borderColor = UIColor.white.cgColor
        label.alpha = 0
        
        self.view.addSubview(label)
        
        UIView.animate(withDuration: 1) {
            label.alpha = 1
        }
        
        UIView.animate(withDuration: 1) {
            label.alpha = 1
        }
        
        label.removeFromSuperview()
    }
}
