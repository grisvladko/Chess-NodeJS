//
//  Pawn.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Pawn : Piece {
    
    var moved = false
    
    override func copy() -> Pawn {
        let copy = Pawn(row: row, col: col,imageName: imageName)
        copy.moved = moved
        return copy
    }
    
    override func isLegalMove(to: Square,board: [Square]) -> Bool {
        if !super.isLegalMove(to: to, board: board) { return false }
        if to.isEmpty() {
            if self.col != to.col { return false }
            if !self.moved { if isBlocked(to: to, board: board) { return false } }
            
            if self.isWhite() {
                if (self.row - 1 == to.row || (self.row - 2 == to.row && !moved )) && to.isEmpty() {
                    return true
                }
            } else {
                if (self.row + 1 == to.row || (self.row + 2 == to.row && !moved )) && to.isEmpty() {
                    return true
                }
            }
        } else {
            
            let result = isCapture(to: to)
            if result && !moved { moved = true }
            return result
        }
        
        return false
    }
    
    func isCapture(to: Square) -> Bool {
        
        if self.isWhite() {
            if self.row - 1 == to.row && (self.col + 1 == to.col || self.col - 1 == to.col ) {
                if to.isEmpty() {
                    to.isAttackedByWhite = true 
                    return false
                }
                if self.isSameColor(piece: to.pieceView!.piece ) {
                    to.isAttackedByWhite = true
                    return false
                } else { return true }
            }
        } else {
            if self.row + 1 == to.row && (self.col + 1 == to.col || self.col - 1 == to.col ) {
                if to.isEmpty() {
                    to.isAttackedByBlack = true
                    return false
                }
                if self.isSameColor(piece: to.pieceView!.piece ) {
                    to.isAttackedByBlack = true
                    return false
                } else { return true }
            }
        }
        return false
    }
    
    func isBlocked(to: Square,board: [Square]) -> Bool {
        for square in board {
            if square.col == self.col && square !== to {
                if self.isWhite() {
                    if square.row + 1 == self.row && !square.isEmpty() {
                        return true
                    }
                } else {
                    if square.row - 1 == self.row && !square.isEmpty() {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isLegalEnpassant(to: Square,board: [Square], moves: [Move]) -> Bool{
        if  self.row - 1 == to.row || self.row + 1 == to.row && (self.col + 1 == to.col || self.col - 1 == to.col ) && to.isEmpty() {
            if moves.last?.pieceMoved() == "P" {
                if moves.last!.to.row == self.row && (moves.last!.to.col + 1 == self.col || moves.last!.to.col - 1 == self.col ) {
                    return true
                }
            }
        }
        
        return false 
    }
}
