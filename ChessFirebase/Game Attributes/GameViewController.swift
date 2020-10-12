//
//  ViewController.swift
//  Chess
//
//  Created by hyperactive on 18/08/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import FirebaseFirestore

class GameViewController: UIViewController {

    var game: Game!
    var gameId: String!
    var playerColor: String!
    var myUserName: String!
    var opponentUserName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        self.view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        
        let board = Board(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), playerColor)
            
        game = Game.init(board,gameId,playerColor)

        game.board.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        self.view.addSubview(game.board)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        game.start() 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.sharedInstance.leave(gameId)
    }
}
