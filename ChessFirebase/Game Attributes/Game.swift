//
//  Game.swift
//  Chess
//
//  Created by hyperactive on 04/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class Game: NSObject {
    
    var moves: [Move] = []
    let board: Board
    let gameId: String
    let playerColor: String
    
    let db = Firestore.firestore()
    
    var isWhiteTurn: Bool! {
        didSet {
            if isWhiteTurn {
                afterMoveAction("white")
            } else {
                afterMoveAction("black")
            }
        }
    }

    init(_ board: Board, _ gameId : String, _ playerColor: String) {
        self.board = board
        self.gameId = gameId
        self.playerColor = playerColor
    }
    
    func start() {
        isWhiteTurn = true
        
        for piece in board.pieceViews {
            if playerColor == "white" {
                if piece.piece.isWhite() {
                    piece.isUserInteractionEnabled = true
                } else {
                    piece.isUserInteractionEnabled = false
                }
            } else {
                if piece.piece.isWhite() {
                    piece.isUserInteractionEnabled = false
                } else {
                    piece.isUserInteractionEnabled = true
                }
            }
        }
        
        SocketIOManager.sharedInstance.listenToMoves()
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToAnimateMoves), name: NSNotification.Name(rawValue: "animateMove"), object: nil)
    }
    
    @objc func listenToAnimateMoves(notification: Notification) {
        let move = notification.object as! [String : Any]
        
        if !self.isValidData(move) { return }
        self.listenerActionFor(move)
    }

    @objc func dragging(_ p: UIPanGestureRecognizer) {
        let v = p.view as! PieceView
        
        switch p.state {
        case .began, .changed:
            movePiece(v: v, p: p)
        case .ended, .cancelled:
            dropPiece(v: v, p: p)
        default: break
        }
    }
    
    func movePiece(v: PieceView, p: UIPanGestureRecognizer) {
        
        if p.state == .began { board.pieceOrigin = v.center }
        
        let delta = p.translation(in: v.superview)
        board.bringSubviewToFront(v)
        var c = v.center
        c.x += delta.x
        c.y += delta.y
        v.center = c
        p.setTranslation(.zero, in: v.superview)
    }
    
    func afterMoveAction(_ color : String) {
        deInitializeAttack(squares: board.squares)
        initializeAttack(pvs: board.pieceViews, squares: board.squares)
        let kingInCheck = color == "white" ? board.whiteKing.isInCheck : board.blackKing.isInCheck
        
        if kingInCheck {
            if isCheckMate(forColor: color) {
                endGame()
                board.animateCheckMate(forColor: color)
                return
            }
        } else {
            if moves.count > 18 && isStaleMate(forColor: color) { endGame()
                return
            }}
            if board.pieceViews.count < 5 { if isInsufficientMaterial() { endGame()
            return
            }}
            if moves.count > 100 { if isFiftyMovesRuleDraw() {endGame()
            return
            }}
            if isThreeFoldRepetition() { endGame()
            return
        }
    }
    
    func dropPiece(v: PieceView, p: UIPanGestureRecognizer) {
        let dropLocation = v.center
       
        let initialPiecePosition = (v.piece.row,v.piece.col)
        
        if playerColor == "white" && !isWhiteTurn {
            board.animateIllegalMove(p: p, from: v)
            return
        } else if playerColor == "black" && isWhiteTurn {
            board.animateIllegalMove(p: p, from: v)
            return
        }
        
        for square in board.squares {
            if square.path.contains(dropLocation) {
                
                if let king = v.piece as? King {
                    if king.isLegalCastling(to: square, board: board.squares) {
                        moves.append(board.animateCastling(p: p, from: v, to: square))
                        markMoved(piece: v.piece)
                       
                        sendMove("castle", initialPiecePosition, square)
                        isWhiteTurn = !isWhiteTurn
                        return
                    }
                }
                
                if !v.piece.isLegalMove(to: square, board :board.squares) {
                    if let pawn = v.piece as? Pawn {
                        if pawn.isLegalEnpassant(to: square, board: board.squares, moves: moves) {
                            moves.append(board.animateEnpassant(p: p, from: v, to: square, lastMove: moves.last!))
                            sendMove("enpassant", initialPiecePosition, square)
                            isWhiteTurn = !isWhiteTurn
                            return
                        }
                    }
                    board.animateIllegalMove(p: p, from: v)
                    return
                }
                
                if !isLegalImitatedMove(from: v, to: square){
                    board.animateIllegalMove(p: p, from: v)
                    return
                }
                
                markMoved(piece: v.piece)
                moves.append(board.animateMove(p: p, from: v, to: square))
                //promote the pawn
                if (v.piece as? Pawn) != nil {
                    if square.row == 0 || square.row == 7{
                        board.animatePromotion("promotion", initialPiecePosition, square)
                        return
                    } 
                }
                
                sendMove("regular", initialPiecePosition, square)
                isWhiteTurn = !isWhiteTurn
                return
            }
        }
    }
    
    func sendMoveWithPromotion( _ promotionView : String, _ move: String, _ from : (row: Int, col: Int), _ to: Square) {
        
        let fromRow = from.row
        let fromCol = from.col
        let toRow = to.row
        let toCol = to.col
        
        let move = ["moveId" : moves.count ,"fromRow" : fromRow, "fromCol" : fromCol, "toRow" : toRow, "toCol" : toCol, "move" : move ,"isMade" : false, "moveColor" : playerColor, "promotionView" : promotionView] as [String : Any]
        
        SocketIOManager.sharedInstance.move(move, gameId)

    }
    
    func sendMove(_ move: String, _ from : (row: Int, col: Int), _ to: Square) {
        let fromRow = from.row
        let fromCol = from.col
        let toRow = to.row
        let toCol = to.col
        
        let move = ["moveId" : moves.count ,"fromRow" : fromRow, "fromCol" : fromCol, "toRow" : toRow, "toCol" : toCol, "move" : move ,"isMade" : false, "moveColor" : playerColor] as [String : Any]
        
        SocketIOManager.sharedInstance.move(move, gameId)
    }
    
    func markMoved(piece: Piece) {
        if let p = piece as? Pawn {
            p.moved = true
        } else if let k = piece as? King {
            k.moved = true
        } else if let r = piece as? Rook {
            r.moved = true
        }
    }
    
    func isLegalImitatedMove(from: PieceView, to: Square) -> Bool{
        
        let checkColor = board.whiteKing.isInCheck ? "white" : (board.blackKing.isInCheck ? "black" : "" )
        
        var pieceViewsCopy: [PieceView] = []
        var squaresCopy: [Square] = []
        var fromCopy: PieceView!
        var toCopy: Square!
        var whiteKing: King!
        var blackKing: King!
        
        for p in board.pieceViews {
            let copy = PieceView(image: p.image, piece: p.piece.copy())
            if p === from { fromCopy = copy }
            pieceViewsCopy.append(copy)
        }
    
        for s in board.squares {
            let copy = s.copy()
            if let k = copy.pieceView?.piece as? King {
                if k.isWhite() {
                    whiteKing = k
                } else {
                    blackKing = k
                }
            }
            
            if s === to { toCopy = copy}
            squaresCopy.append(copy)
        }

        if !toCopy.isEmpty() {
            pieceViewsCopy.removeAll(where: {$0.piece.row  == toCopy.pieceView!.piece.row && $0.piece.col == toCopy.pieceView!.piece.col })
        }
  
        movePieceFromSquare(squaresCopy, fromCopy, toCopy, toCopy)
        deInitializeAttack(squares: squaresCopy)
        initializeAttack(pvs: pieceViewsCopy, squares: squaresCopy)
        
        if whiteKing.isInCheck && blackKing.isInCheck { return false }
        
        return isInCheckAfterMove(squares: squaresCopy, checkColor: checkColor)
    }
    
    func movePieceFromSquare(_ squaresCopy: [Square], _ fromCopy: PieceView, _ toCopy: Square, _ to: Square) {
        for square in squaresCopy {
            if square.row == fromCopy.piece.row && square.col == fromCopy.piece.col {
                square.pieceView = nil
                break
            }
        }
        
        toCopy.pieceView = fromCopy
        toCopy.pieceView!.piece.row = to.row
        toCopy.pieceView!.piece.col = to.col
    }
    
    func isInCheckAfterMove(squares: [Square], checkColor: String) -> Bool {
        for square in squares {
            if square.pieceView != nil {
                if let king = square.pieceView?.piece as? King {
                    if king.isInCheck {
                        if king.isWhite() {
                            if !isWhiteTurn { return true }
                            if checkColor == "white" || checkColor == ""{
                            return false
                            }
                        
                        } else {
                            if isWhiteTurn { return true }
                            if checkColor == "black" || checkColor == ""{
                            return false
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    func initializeAttack(pvs: [PieceView], squares: [Square]) {
        for pieceView in pvs {
            for square in squares {
               
                if let pawn = pieceView.piece as? Pawn {
                    if pawn.isCapture(to: square) {
                        if pawn.isWhite() {
                            square.isAttackedByWhite = true
                        } else {
                            square.isAttackedByBlack = true 
                        }
                    }
                } else {
                    if pieceView.piece.isLegalMove(to: square, board: squares) {
            
                        if pieceView.piece.isWhite() {
                            square.isAttackedByWhite = true
                        } else {
                            square.isAttackedByBlack = true
                        }
                    }
                }
            }
        }
    }
    
    func deInitializeAttack(squares: [Square]) {
        for square in squares {
            square.isAttackedByWhite = false
            square.isAttackedByBlack = false
        }
    }
    
    func isCheckMate(forColor: String) -> Bool{
        
        for pv in board.pieceViews {
            if forColor == "white" && !pv.piece.isWhite() { continue }
            else if forColor == "black" && pv.piece.isWhite() { continue }
            for square in board.squares {
                if pv.piece.isLegalMove(to: square, board: board.squares) {
                    if isLegalImitatedMove(from: pv, to: square) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func endGame() {
        for pv in board.pieceViews {
            pv.isUserInteractionEnabled = false
        }
        if let vc = board.parentViewController {
            vc.view.backgroundColor = .red
            vc.navigationController?.navigationBar.isHidden = false 
        }
    }
 
    func isThreeFoldRepetition() -> Bool{
        let j = moves.count - 1
        if j < 4  {return false}
        
        if moves[j].isEqualReversedMove(move: moves[j - 2]) && moves[j - 1].isEqualReversedMove(move: moves[j - 3]) && moves[j].isEqual(move: moves[j - 4]) {
            return true 
        }
        
        return false
    }
    
    func isStaleMate(forColor: String) -> Bool {
        for pv in board.pieceViews {
            if forColor == "white" && !pv.piece.isWhite() { continue }
            else if forColor == "black" && pv.piece.isWhite() { continue }
            for square in board.squares {
                if pv.piece.isLegalMove(to: square, board: board.squares) {
                    if isLegalImitatedMove(from: pv, to: square) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func isInsufficientMaterial() -> Bool{
        if board.pieceViews.count == 2 { return true }
        for pv in board.pieceViews {
            if pv.piece is Rook || pv.piece is Queen {
                return false
            }
        }
        if board.pieceViews.count == 3 { return true }
        
        var b1: Bool?
        var b2: Bool?
        
        if board.pieceViews.count == 4 {
            for square in board.squares {
                if !square.isEmpty() {
                    if (square.pieceView!.piece as? Bishop) != nil {
                        if square.isLightSquare! {
                            if b1 == nil { b1 = true }
                            else { b2 = true }
                        } else { if b1 == nil { b1 = false }
                        else { b2 = false }}
                    }
                }
            }
        }
        
        if b1 == nil || b2 == nil { return false }
        if b1 == b2 { return true }
        return false
    }
    
    func isFiftyMovesRuleDraw() -> Bool{
        for i in stride(from: moves.count - 1, through: moves.count - 100, by: -1) {
            if moves[i].isCapture || moves[i].pieceMoved() == "P" { return false }
        }
        return true
    }
    
    //HERE GOES THE LISTENER FUNCTIONS FOR COLLECTION!!
    
    func isValidData(_ data: [String : Any]) -> Bool {
        if moves.count == 0 && self.playerColor == "white" { return false }
        if data["isMade"] as! Bool { return false }
        if data["movedColor"] != nil {
            if data["moveColor"] as! String == self.playerColor { return false }
        }
        return true
    }
    
    func listenerActionFor(_ data: [String : Any]) {
        let p = UIPanGestureRecognizer()
        let i = self.getPieceViewIndexFor(data["fromRow"] as! Int, data["fromCol"] as! Int)
        let j = self.getSquareIndexFor(data["toRow"] as! Int , data["toCol"] as! Int)
        if i < 0 || j < 0 { print("failed to find something"); return;}
        
        self.makeMoveForOpponent(data, p, self.board.pieceViews[i], self.board.squares[j])
    }
    
    func getPieceViewIndexFor(_ row : Int, _ col: Int) -> Int{
        let result = -1
        for i in 0..<board.pieceViews.count {
            if board.pieceViews[i].piece.row == row && board.pieceViews[i].piece.col == col {
                return i
            }
        }
        return result
    }
    
    func getSquareIndexFor(_ row: Int, _ col: Int) -> Int {
        let result = -1
        for i in 0..<board.squares.count {
            if board.squares[i].row == row && board.squares[i].col == col {
                return i
            }
        }
        return result
    }
    
    func makeMoveForOpponent(_ data: [String: Any], _ p: UIPanGestureRecognizer, _ from: PieceView, _ to: Square) {
        let move = data["move"] as! String
        
        switch move {
        case "promotion":
            if data["promotionView"] != nil {
                self.moves.append(self.board.animateMove(p: p, from: from, to: to))
                self.board.changePromotionView(data["promotionView"] as! String, to)
            } else { return }
        
        case "enpassant":
            self.moves.append(self.board.animateEnpassant(p: p, from: from, to: to, lastMove: self.moves.last!))
        case "castle" :
            self.moves.append(self.board.animateCastling(p: p, from: from, to: to))
        case "regular":
            self.moves.append(self.board.animateMove(p: p, from: from, to: to))
        default: return
        }
        
        self.markMoved(piece: from.piece)
        self.isWhiteTurn = !self.isWhiteTurn
    }
}
