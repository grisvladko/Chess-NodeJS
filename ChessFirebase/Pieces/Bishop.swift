//
//  Bishop.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Bishop : Piece {
    
    override func copy() -> Bishop {
        return Bishop(row: row, col: col, imageName: imageName)
    }
    
    override func isLegalMove(to: Square, board: [Square]) -> Bool {
        
        if !super.isLegalMove(to: to, board: board) { return false }

        if self.col > to.col {
            if self.row > to.row {
                return !isBlocked(to: to, board: board, direction: "dd")
            } else {
                return !isBlocked(to: to, board: board, direction: "id")
            }
        } else {
            if self.row < to.row {
                return !isBlocked(to: to, board: board, direction: "ii")
            } else {
                return !isBlocked(to: to, board: board, direction: "di")
            }
        }
    }
    
    func isBlocked(to: Square, board: [Square], direction: String) -> Bool {
        var col = self.col
        var row = self.row
    
        while col != to.col && row != to.row {
            switch direction {
                case "dd": col -= 1; row -= 1
                case "di": col += 1; row -= 1
                case "ii": col += 1; row += 1
                case "id": col -= 1; row += 1
                default: break
            }
        
            for square in board {
                if square.col == col && square.row == row && square !== to {
                    if self.isWhite() { square.isAttackedByWhite = true }
                    else { square.isAttackedByBlack = true }
                    if !square.isEmpty() {
                        return true
                    }
                }
            }
        }
        
        if col == to.col && row == to.row {
            if self.isWhite() { to.isAttackedByWhite = true }
            else { to.isAttackedByBlack = true }
            if !to.isEmpty() {
                if self.isSameColor(piece: to.pieceView!.piece) {
                    return true
                }
            }
            return false }
        else { return true } 
    }
}
