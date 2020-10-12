//
//  LobbyTableViewController.swift
//  ChessFirebase
//
//  Created by hyperactive on 23/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

/*
 DESCRIPTION
 this is the lobby where the active players : that currently available for a game
 are displayed. whenever a player exits this vc, for whatever reason, he stops
 beign available for the play, thus the changes on state of user.
 
 ||||| REMMEMBER: THE ARRAY YOU GET IS FROM THE SERVER.JS HERE |||||
 
 */

import UIKit

class LobbyTableViewController: UITableViewController {
    
    var isAcceptedYet = false
    var username: String!
    var id: String?
    var users: [[String : Any]] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isAcceptedYet = false
        userJoined()
        setListeners()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.sharedInstance.leave("lobby")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! LobbyTableViewCell
        
        if self.id == nil && (users[indexPath.row]["username"] as! String) == self.username {
            self.id = (users[indexPath.row]["id"] as! String)
        }
        
        cell.userName.text = (users[indexPath.row]["username"] as! String)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        challangeUserAt(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func userJoined() {
        DispatchQueue.main.async {
            SocketIOManager.sharedInstance.join("lobby", self.username) {
                (data) in
                self.users = data
                self.tableView.reloadData()
            }
        }
    }
    
    func challangeUserAt(_ row: Int) {
        let reciever = users[row]["id"] as! String
        if reciever == self.id { return }
        let gameId = self.id! + "-" + reciever
        
        SocketIOManager.sharedInstance.invitation(self.id!, reciever, gameId) { (res, room) in
            if res && !self.isAcceptedYet {
                self.isAcceptedYet = true
                SocketIOManager.sharedInstance.listen(room)
                self.transitionToGame(room, "white")
            }
        }
    }

    func showInviteAlert(_ initiator: String,_ gameId: String) {
        
        let invite = UIAlertController(title: "New Game Invitation", message: "Accept and proceed to game screen or Decline", preferredStyle: UIAlertController.Style.alert)
        
        invite.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action: UIAlertAction!) in
            SocketIOManager.sharedInstance.response(true, initiator, gameId) {
                self.transitionToGame(gameId, "black")
            }
        }))

        invite.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { (action) in
            SocketIOManager.sharedInstance.response(false, initiator, nil) {}
        }))
        
        self.showDetailViewController(invite, sender: nil)
    }
    
    func transitionToGame(_ gameId : String, _ color: String ) {
        guard let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.gameViewController) as? GameViewController else { return }
        vc.gameId = gameId
        vc.playerColor = color
        self.navigationController?.show(vc, sender: nil)
    }
    
    func setListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(listenToUserDisconnected), name: NSNotification.Name(rawValue: "userDisconnected"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToInvites), name: NSNotification.Name(rawValue: "userInvited"), object: nil)
    }
    
    @objc func listenToUserDisconnected(notification: Notification) {
        let data = notification.object as! [[String : Any]]
        self.users = data
        self.tableView.reloadData()
    }
    
    @objc func listenToInvites(notification: Notification) {
        let data = notification.object as! [String : Any]
        let reciever = data["reciever"] as! String
        if reciever != self.id { return }

        let initiator = data["initiator"] as! String
        let gameId = data["gameId"] as! String
        
        showInviteAlert(initiator, gameId)
    }
}

class LobbyTableViewCell: UITableViewCell {
    //add information about the user
    @IBOutlet weak var userName: UILabel!
}
