//
//  Square.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Square {
    
    var row: Int
    var col: Int
    var center: CGPoint
    let path: UIBezierPath
    var isLightSquare: Bool?
    var pieceView: PieceView?
    var isAttackedByWhite = false {
        didSet {
            if self.isAttackedByWhite {
                if let king = pieceView?.piece as? King {
                    if !king.isWhite() {
                        king.isInCheck = true
                        pieceView!.addShadowOnCheck()
                    }
                }
            } else {
                if let king = pieceView?.piece as? King {
                    if !king.isWhite() {
                        king.isInCheck = false
                        pieceView!.removeShadow()
                    }
                }
            }
        }
    }
    var isAttackedByBlack = false {
        didSet {
            if self.isAttackedByBlack {
                if let king = pieceView?.piece as? King {
                    if king.isWhite() {
                        king.isInCheck = true
                        pieceView!.addShadowOnCheck()
                    }
                }
            } else {
                if let king = pieceView?.piece as? King {
                    if king.isWhite() {
                        king.isInCheck = false
                        pieceView!.removeShadow()
                    }
                }
            }
        }
    }
    
    func copy() -> Square {
        let copy = Square(row: row, col: col, path: path)
        copy.center = center
        copy.pieceView = self.pieceView?.copy()
        copy.isAttackedByWhite = isAttackedByWhite
        copy.isAttackedByBlack = isAttackedByBlack
        return copy
    }
    
    func isEmpty() -> Bool {
        return pieceView == nil
    }
    
    init(row: Int, col: Int, path: UIBezierPath) {
        self.row = row
        self.col = col
        self.path = path
        center = CGPoint(x: path.bounds.midX, y: path.bounds.midY)
    }
}
