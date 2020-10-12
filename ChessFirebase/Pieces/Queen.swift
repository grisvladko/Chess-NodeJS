//
//  Queen.swift
//  Chess
//
//  Created by hyperactive on 28/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit

class Queen : Piece {
    
    override func copy() -> Queen {
        return Queen(row: row, col: col, imageName: imageName)
    }
    
    override func isLegalMove(to: Square, board: [Square]) -> Bool {
        
        let rook = Rook(row: self.row, col: self.col, imageName: self.imageName)
        let bishop = Bishop(row: self.row, col: self.col, imageName: self.imageName)
        
        return rook.isLegalMove(to: to, board: board) || bishop.isLegalMove(to: to, board: board)
    }
}
