//
//  Board.swift
//  Chess
//
//  Created by hyperactive on 18/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit

class Board: UIView {
    
    let tileSize = UIScreen.main.bounds.width / 8
    
    var pieces = Set<Piece>()
    var pieceViews : [PieceView] = []
    var squares: [Square] = []
    var pieceOrigin: CGPoint!
    var playerColor: String!
    
    var whiteKing: King!
    var blackKing: King!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(_ frame: CGRect, _ playerColor: String) {
        self.init(frame: frame)
        self.playerColor = playerColor
    }
    
    override func draw(_ rect: CGRect) {
        if playerColor == "white" { drawBoard() }
        else { drawReverseBoard() }
        drawPieces()
    }
    
    func drawBoard() {
        var isWhite = true
        for i in 0..<8 {
            for j in 0..<8 {
                
                let square = Square(row: j, col: i, path: UIBezierPath(rect: CGRect(x: CGFloat(i) * tileSize, y: CGFloat(j) * tileSize , width: tileSize,height: tileSize)))
                
                squares.append(square)
                
                if isWhite {
                    let color = UIColor.init(red: 210/255, green: 180/255, blue: 140/255, alpha: 1)
                    square.isLightSquare = true
                    color.setFill()
                } else {
                    let color = UIColor.init(red: 122/255, green: 76/255, blue: 46/255, alpha: 1)
                    square.isLightSquare = false
                    color.setFill()
                }
                
                isWhite = !isWhite
                square.path.fill()
            }
            isWhite = !isWhite
        }
    }
    
    func drawReverseBoard() {
        var isWhite = true
        for i in 0..<8 {
            for j in 0..<8 {
                let x = setCoordinate(i: i)
                let y = setCoordinate(i: j)
                let square = Square(row: j, col: i, path: UIBezierPath(rect: CGRect(x: CGFloat(x) * tileSize, y: CGFloat(y) * tileSize , width: tileSize,height: tileSize)))
                
                squares.append(square)
                
                if isWhite {
                    let color = UIColor.init(red: 210/255, green: 180/255, blue: 140/255, alpha: 1)
                    square.isLightSquare = true
                    color.setFill()
                } else {
                    let color = UIColor.init(red: 122/255, green: 76/255, blue: 46/255, alpha: 1)
                    square.isLightSquare = false
                    color.setFill()
                }
                
                isWhite = !isWhite
                square.path.fill()
            }
            isWhite = !isWhite
        }
    }
    
    func setCoordinate(i: Int) -> Int{
        var result: Int!
        switch i {
        case 0: result = 7
        case 1: result = 6
        case 2: result = 5
        case 3: result = 4
        case 4: result = 3
        case 5: result = 2
        case 6: result = 1
        case 7: result = 0
        default: break
        }
        return result
    }
    
    func drawPieces() {
        var p = pieceInitializer()
        p.initializeBoard()
        pieces = p.pieces
        
        for piece in pieces {
            if let king = piece as? King {
                if king.isWhite() { whiteKing = king }
                else { blackKing = king }
            }
            let pieceImage = UIImage(named: piece.imageName)
            let imv = PieceView(image: pieceImage!, piece: piece)
            
            setPropertiesForPieceView(imv)
            placePieceInSquare(imv, piece)

            pieceViews.append(imv)
            self.addSubview(imv)
        }
    }
    
    func setPropertiesForPieceView(_ imv: PieceView) {
        imv.isUserInteractionEnabled = true
        imv.frame = CGRect(x: 0, y: 0, width: tileSize - 2.5, height: tileSize - 2.5)
        
        let g = (self.parentViewController as! GameViewController).game!
        let p = UIPanGestureRecognizer(target: g, action: #selector(g.dragging))
        imv.addGestureRecognizer(p)
    }
    
    func placePieceInSquare(_ imv: PieceView, _ piece: Piece) {
        for i in 0..<squares.count {
            if squares[i].row == piece.row && squares[i].col == piece.col {
                imv.center = squares[i].center
                imv.piece.center = squares[i].center
                squares[i].pieceView = imv
            }
        }
    }

    func animateIllegalMove(p: UIPanGestureRecognizer, from: PieceView) {
        
        let vel = p.velocity(in: from.superview)
        let c = from.center
        let distx = abs(c.x - pieceOrigin.x)
        let disty = abs(c.y - pieceOrigin.y)
        
        let anim = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: CGVector(dx: vel.x / distx, dy: vel.y / disty)))
        anim.addAnimations {
            from.center = self.pieceOrigin
        }
        anim.startAnimation()
    }
    
    func animateMove(p: UIPanGestureRecognizer, from:  PieceView, to:  Square) -> Move {
        animate(p, from, to)
        
        let move = Move(imageName: from.piece.imageName, from: (from.piece.row, from.piece.col), to: (to.row, to.col), isCapture: !to.isEmpty())
        
        if !to.isEmpty() {
            UIView.animate(withDuration: 0.5, animations: {
                to.pieceView!.alpha = 0
            }, completion: nil)
            
            to.pieceView!.removeFromSuperview()
            pieceViews.removeAll(where: {$0 === to.pieceView})
        }

        removeFromSquare(pieceView: from)
        changeLocation(from, to)
        
        return move
    }
    
    func animateCastling(p: UIPanGestureRecognizer, from:  PieceView, to:  Square) -> Move {
        animate(p, from, to)
        
        let move = Move(imageName: from.piece.imageName, from: (from.piece.row, from.piece.col), to: (to.row, to.col), isCapture: false)
        
        removeFromSquare(pieceView: from)
        changeLocation(from, to)
        
        let rook = findRookToMove(row: to.row, col: to.col)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.squares[rook.from].pieceView!.center = self.squares[rook.to].center
        }, completion: nil)
        
        let r = squares[rook.from].pieceView!
        removeFromSquare(pieceView: squares[rook.from].pieceView!)
        squares[rook.to].pieceView = r
        squares[rook.to].pieceView!.piece.row = squares[rook.to].row
        squares[rook.to].pieceView!.piece.col = squares[rook.to].col
        
        return move
    }
    
    func animateEnpassant(p: UIPanGestureRecognizer, from:  PieceView, to:  Square, lastMove: Move) -> Move{
        animate(p, from, to)
        
        let move = Move(imageName: from.piece.imageName, from: (from.piece.row, from.piece.col), to: (to.row, to.col), isCapture: true)
        
        let toPieceView = findPieceView(row: lastMove.to.row, col: lastMove.to.col)!
        
        UIView.animate(withDuration: 0.5, animations: {
            toPieceView.alpha = 0
        }, completion: nil)
            
        toPieceView.removeFromSuperview()
        pieceViews.removeAll(where: {$0 === toPieceView})

        removeFromSquare(pieceView: from)
        removeFromSquare(pieceView: toPieceView)
        
        changeLocation(from, to)
        
        return move
    }
    
    func changeLocation(_ from : PieceView,_ to: Square) {
        to.pieceView = from
        to.pieceView!.piece.center = to.center
        to.pieceView!.piece.row = to.row
        to.pieceView!.piece.col = to.col
    }
    
    func animate(_ p: UIPanGestureRecognizer ,_ from: PieceView, _ to: Square) {
        let vel = p.velocity(in: from.superview)
        
        let anim = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: CGVector(dx: vel.x / from.center.x, dy: vel.y / from.center.y)))
        
        anim.addAnimations {
            from.center = to.center
        }
        anim.startAnimation()
    }
    
    func findRookToMove(row: Int, col: Int) -> (from: Int, to:Int) {
        var result = (from: 0, to: 0)
        switch (row, col) {
        case (0,6):
            result.from = 56
            result.to = 40
        case (0,2):
            result.from = 0
            result.to = 24
        case (7,2):
            result.from = 7
            result.to = 31
        case (7,6):
            result.from = 63
            result.to = 47
        default: break
        }
        return result
    }
    
    func removeFromSquare(pieceView: PieceView) {
        for square in squares {
            if !square.isEmpty() {
                if square.pieceView! === pieceView {
                    square.pieceView = nil
                    return
                }
            }
        }
    }
    
    func findPieceView(row: Int, col: Int) -> PieceView? {
        for pv in pieceViews {
            if pv.piece.row == row && pv.piece.col == col {
                return pv
            }
        }
        return nil
    }
    
    func animateCheckMate(forColor: String) {
        if forColor == "white" {
            let imv = UIImageView(image: UIImage(named: "wm"))
            imv.bounds = CGRect(x: 0, y: 0, width: 200, height: 120)
            UIView.animate(withDuration: 0.5, animations: {
                self.addSubview(imv)
                self.bringSubviewToFront(imv)
                imv.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            })
        } else {
            let imv = UIImageView(image: UIImage(named: "bm"))
            imv.bounds = CGRect(x: 0, y: 0, width: 200, height: 120)
            UIView.animate(withDuration: 0.5, animations: {
                self.addSubview(imv)
                self.bringSubviewToFront(imv)
                imv.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            })
        }
    }
    
    func animatePromotion(_ move: String,_ from: (row: Int, col: Int) ,_ at: Square) {
        
        let promotionView = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 70 ))
        promotionView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        promotionView.backgroundColor = .white
        
        let isWhite = at.pieceView!.piece.isWhite()
        for i in 1..<5 {
            var imageName = ""
            var piece: Piece!
            switch i {
            case 1: imageName = isWhite ? "WQ" : "BQ"
                piece = Queen(row: at.row, col: at.col, imageName: imageName)
            case 2: imageName = isWhite ? "WR" : "BR"
                piece = Rook(row: at.row, col: at.col, imageName: imageName)
            case 3: imageName = isWhite ? "WN" : "BN"
                piece = Knight(row: at.row, col: at.col, imageName: imageName)
            case 4: imageName = isWhite ? "WB" : "BB"
                piece = Bishop(row: at.row, col: at.col, imageName: imageName)
            default: break
            }
            let image = UIImage(named: imageName)
            let imv = PieceView(image: image, piece: piece)
            
            imv.bounds = CGRect(x: 0, y: 0, width: 70, height: 70)
            let f = i == 1 ? i * (70/2) : i * 70 - (70/2)
            imv.center = CGPoint(x: f, y: 70/2)
            let p = PromotionGestureRecognizer(self, #selector(didSelectPromotionPiece(pg:)),from, move, at)
            
            imv.isUserInteractionEnabled = true
            imv.addGestureRecognizer(p)
            
            promotionView.addSubview(imv)
        }
        promotionView.tag = 11
        self.addSubview(promotionView)
        self.bringSubviewToFront(promotionView)
    }
    
    @objc func didSelectPromotionPiece(pg: PromotionGestureRecognizer) {
        let v = pg.view as! PieceView
        
        for square in squares {
            if square.row == v.piece.row && square.col == v.piece.col {
                pieceViews.removeAll(where: { $0 === square.pieceView! })
                pieceViews.append(v)
                v.bounds = square.pieceView!.bounds
                v.center = square.center
                square.pieceView?.removeFromSuperview()
                square.pieceView = v
                let g = (self.parentViewController as! GameViewController).game!
                let p = UIPanGestureRecognizer(target: g, action: #selector(g.dragging))
                
                g.sendMoveWithPromotion(v.piece.imageName, pg.move, pg.from, pg.square)
                g.isWhiteTurn = !g.isWhiteTurn

                v.addGestureRecognizer(p)
                self.addSubview(square.pieceView!)
                self.viewWithTag(11)?.removeFromSuperview()
                return
            }
        }
    }
    
    func changePromotionView(_ imageName : String, _ at: Square) {
        var piece: Piece!
        switch imageName.suffix(1) {
        case "N":piece = Knight(row: at.row, col: at.col, imageName: imageName)
        case "B":piece = Bishop(row: at.row, col: at.col, imageName: imageName)
        case "R":piece = Rook(row: at.row, col: at.col, imageName: imageName)
        case "Q":piece = Queen(row: at.row, col: at.col, imageName: imageName)
        default: break
        }
        
        pieceViews.removeAll(where: { $0 === at.pieceView! })
        let image = UIImage(named: imageName)
        let imv = PieceView(image: image, piece: piece)
        pieceViews.append(imv)
        imv.bounds = at.pieceView!.bounds
        imv.center = at.center
        at.pieceView?.removeFromSuperview()
        at.pieceView = imv
        let g = (self.parentViewController as! GameViewController).game!
        let p = UIPanGestureRecognizer(target: g, action: #selector(g.dragging))
        imv.addGestureRecognizer(p)
        self.addSubview(at.pieceView!)
        self.bringSubviewToFront(imv)
    }
}

class PromotionGestureRecognizer: UITapGestureRecognizer {
    var from : (row: Int, col: Int)!
    var move : String!
    var square: Square!
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init(_ target: Any?,_ action: Selector?, _ from : (row: Int, col: Int), _ move : String, _ square: Square) {
        self.init(target: target, action: action)
        self.from = from
        self.move = move
        self.square = square
    }
}
