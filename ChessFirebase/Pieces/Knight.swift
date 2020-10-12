//
//  Knight.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Knight : Piece {
    
    override func copy() -> Knight {
        return Knight(row: row, col: col, imageName: imageName)
    }
    
    override func isLegalMove(to: Square, board: [Square]) -> Bool {
        
        if !super.isLegalMove(to: to, board: board) { return false }
        var result = Bool()
        
        if self.col + 1 == to.col && self.row + 2 == to.row { result = true }
        else if self.col + 1 == to.col && self.row - 2 == to.row { result = true }
        else if self.col - 1 == to.col && self.row - 2 == to.row { result = true }
        else if self.col - 1 == to.col && self.row + 2 == to.row { result = true }
        else if self.col + 2 == to.col && self.row - 1 == to.row { result = true }
        else if self.col + 2 == to.col && self.row + 1 == to.row { result = true }
        else if self.col - 2 == to.col && self.row - 1 == to.row { result = true }
        else if self.col - 2 == to.col && self.row + 1 == to.row { result = true }
        
        if !result { return result }
        
        if !to.isEmpty() {
            if self.isSameColor(piece: to.pieceView!.piece) {
                if self.isWhite() { to.isAttackedByWhite = true }
                else { to.isAttackedByBlack = true }
                result = false
            } else {
                if self.isWhite() { to.isAttackedByWhite = true }
                else { to.isAttackedByBlack = true }
            }
        }
        
        return result
    }
}
