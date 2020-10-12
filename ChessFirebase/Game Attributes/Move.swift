//
//  Move.swift
//  Chess
//
//  Created by hyperactive on 13/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Move: NSObject {
    
    var imageName: String
    var from: (row: Int, col: Int)
    var to: (row: Int, col: Int)
    var isCapture: Bool
    
    init(imageName: String, from: (Int,Int), to: (Int,Int), isCapture: Bool) {
        self.imageName = imageName
        self.from = from
        self.to = to
        self.isCapture = isCapture
    }
    
    func pieceMoved() -> Character {
        return imageName.last!
    }
    
    func isWhite() -> Bool {
        return imageName.hasPrefix("W")
    }
    
    func isEqualReversedMove(move: Move) -> Bool {
        if self.from == move.to && self.to == move.from {
            return true 
        }
        return false
    }
    
    func isEqual(move: Move) -> Bool {
        if self.from == move.from && self.to == move.to && self.imageName == move.imageName && self.isCapture == move.isCapture {
            return true
        }
        return false
    }
}
