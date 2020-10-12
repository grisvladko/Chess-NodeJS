//
//  King.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class King : Piece {
    
    var moved = false
    var isInCheck = false
    
    override func copy() -> King {
        let copy = King(row: row, col: col, imageName: imageName)
        copy.moved = moved
        copy.isInCheck = isInCheck
        return copy
    }
    
    override func isLegalMove(to: Square, board: [Square]) -> Bool {
        
        if !super.isLegalMove(to: to, board: board) { return false }
        
        if self.isWhite() { if to.isAttackedByBlack { return false }}
        else { if to.isAttackedByWhite { return false }}
        
        for i in self.row - 1...self.row + 1 {
            for j in self.col - 1...self.col + 1 {
                if i == to.row && j == to.col {
                    if !to.isEmpty() {
                        if self.isSameColor(piece: to.pieceView!.piece) {
                            if self.isWhite() {
                                to.isAttackedByWhite = true
                                return false
                            } else {
                                to.isAttackedByBlack = true
                                return false 
                            }
                        }
                    }
                    return true
                }
            }
        }
    
        return false
    }
    
    func isLegalCastling(to: Square, board: [Square]) -> Bool {
        //white rooks at 7 & 63 black 0 & 56
            if !moved && row == to.row && (col == to.col + 2 || col == to.col - 2) && !self.isInCheck {
                if self.isWhite() {
                    if col == to.col - 2 {
                        if let rook = board[63].pieceView?.piece as? Rook {
                            if !to.isAttackedByBlack && to.isEmpty() && board[47].isEmpty() && !board[47].isAttackedByBlack && !rook.moved {
                                return true
                            }
                        }
                    } else {
                        if let rook = board[7].pieceView?.piece as? Rook {
                            if !to.isAttackedByBlack && to.isEmpty() && board[23].isEmpty() && !board[23].isAttackedByBlack && !rook.moved {
                                return true
                            }
                        }
                    }
                } else {
                    if col == to.col + 2 {
                        if let rook = board[0].pieceView?.piece as? Rook {
                            if !to.isAttackedByWhite && to.isEmpty() && board[16].isEmpty() && !board[16].isAttackedByWhite && !rook.moved {
                                return true
                            }
                        }
                    } else {
                        if let rook = board[56].pieceView?.piece as? Rook {
                            if !to.isAttackedByWhite && to.isEmpty() && board[40].isEmpty() && !board[40].isAttackedByWhite && !rook.moved {
                                return true
                            }
                        }
                    }
                }
            }
        
            return false
    }
}
