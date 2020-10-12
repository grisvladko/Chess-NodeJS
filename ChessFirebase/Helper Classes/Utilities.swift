//
//  Utilities.swift
//  ChessFirebase
//
//  Created by hyperactive on 23/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@4#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func editButton(_ button: UIButton) {
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = UIColor(red: 95/255, green: 2/255, blue: 31/255, alpha: 1)
        button.tintColor = .white
        button.layer.masksToBounds = true
    }
}
