//
//  Piece.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Piece : NSObject {
    
    var row: Int
    var col: Int
    let imageName: String
    var center: CGPoint!
    
    init(row: Int, col: Int, imageName: String) {
        self.row = row
        self.col = col
        self.imageName = imageName
    }
    
    func copy() -> Piece {
        return Piece(row: row, col: col, imageName: imageName)
    }
    
    func isWhite() -> Bool {
        return imageName.hasPrefix("W")
    }
    
    func isSameColor(piece: Piece) -> Bool {
        return self.isWhite() == piece.isWhite()
    }
    
    func isLegalMove(to: Square, board: [Square]) -> Bool {
        if self.row == to.row && self.col == to.col { return false }
        return true
    }

}

class PieceView: UIImageView {
    
    var piece: Piece!
    
    convenience init(image: UIImage?, piece: Piece) {
        self.init(image: image)
        self.piece = piece
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    //doesnot work for some reason
    func copy() -> PieceView {
        return PieceView(image: self.image, piece: piece.copy())
    }
}

struct pieceInitializer {
    var pieces = Set<Piece>()
    
    mutating func initializeBoard() {
        pieces.insert(Rook(row: 0, col: 0, imageName: "BR"))
        pieces.insert(Rook(row: 0, col: 7, imageName: "BR"))
        pieces.insert(Rook(row: 7, col: 0, imageName: "WR"))
        pieces.insert(Rook(row: 7, col: 7, imageName: "WR"))
        pieces.insert(Knight(row: 0, col: 1, imageName: "BN"))
        pieces.insert(Knight(row: 0, col: 6, imageName: "BN"))
        pieces.insert(Knight(row: 7, col: 1, imageName: "WN"))
        pieces.insert(Knight(row: 7, col: 6, imageName: "WN"))
        pieces.insert(Bishop(row: 0, col: 2, imageName: "BB"))
        pieces.insert(Bishop(row: 0, col: 5, imageName: "BB"))
        pieces.insert(Bishop(row: 7, col: 2, imageName: "WB"))
        pieces.insert(Bishop(row: 7, col: 5, imageName: "WB"))
        pieces.insert(Queen(row: 0, col: 3, imageName: "BQ"))
        pieces.insert(Queen(row: 7, col: 3, imageName: "WQ"))
        pieces.insert(King(row: 0, col: 4, imageName: "BK"))
        pieces.insert(King(row: 7, col: 4, imageName: "WK"))
        pieces.insert(Pawn(row: 1, col: 0, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 1, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 2, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 3, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 4, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 5, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 6, imageName: "BP"))
        pieces.insert(Pawn(row: 1, col: 7, imageName: "BP"))
        pieces.insert(Pawn(row: 6, col: 0, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 1, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 2, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 3, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 4, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 5, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 6, imageName: "WP"))
        pieces.insert(Pawn(row: 6, col: 7, imageName: "WP"))
    }
}
