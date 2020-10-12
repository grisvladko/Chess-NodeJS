//
//  Rook.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Rook : Piece {
    
    var moved = false
    
    override func copy() -> Rook {
        let copy = Rook(row: row, col: col, imageName: imageName)
        copy.moved = moved
        return copy
    }
    
    override func isLegalMove(to: Square, board: [Square]) -> Bool {
        if !super.isLegalMove(to: to, board: board) { return false }

        if self.col > to.col {
            if self.row != to.row { return false }
            return !isBlocked(to: to, board: board, direction: "hl")
        } else if self.col < to.col {
            if self.row != to.row { return false }
            return !isBlocked(to: to, board: board, direction: "hr")
        } else if self.row > to.row {
            if self.col != to.col { return false }
            return !isBlocked(to: to, board: board, direction: "vu")
        } else {
            if self.col != to.col { return false }
            return !isBlocked(to: to, board: board, direction: "vd")
        }
    }
    
    func isBlocked(to: Square, board: [Square], direction: String) -> Bool {
        var col = self.col
        var row = self.row
        while col != to.col || row != to.row {
            switch direction {
                case "hl": col -= 1;
                case "hr": col += 1;
                case "vu": row -= 1;
                case "vd": row += 1;
                default: break
            }
        
            for square in board {
                if square.col == col && square.row == row && square !== to{
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
    
            return false
        }
        else { return true }
    }
}
