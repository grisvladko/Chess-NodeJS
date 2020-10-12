//
//  SocketIOManager.swift
//  ChessFirebase
//
//  Created by hyperactive on 07/10/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    let manager: SocketManager
    let socket: SocketIOClient
    
    override init() {
        self.manager = SocketManager(socketURL: URL(string: "http://10.0.0.7:3000")!)
        self.socket = manager.defaultSocket
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func join(_ room: String, _ username: String ,_ completion: @escaping (_ userList: [[String : Any]]) -> Void) {
        
        socket.emit("join", username, room)
        
        socket.on("userList") { (dataArray, ack) in
            completion(dataArray[0] as! [[String : Any]])
        }
        
        listenToUserUpdates()
    }

    func leave(_ room: String) {
        socket.emit("leave", room)
    }
    
    func listen(_ room: String) {
        socket.emit("listen", room)
    }
    
    func invitation(_ initiator: String, _ reciever: String,_ gameId: String, _ completion: @escaping (_ isAccepted: Bool, _ room: String) -> Void) {
        socket.emit("invitation", initiator, reciever, gameId)
        
        socket.on("inviteAccepted") { (data, ack) in
            let room = data[0] as! String
            completion(true, room)
        }
        socket.on("inviteDenclined") { (data, ack) in
            completion(false, "")
        }
    }
    
    func response(_ res: Bool,_ initiator : String ,_ gameId: String?, _ completion: @escaping () -> Void) {
        socket.emit("response", res, initiator, gameId ?? "")
        completion()
    }
    
    func move(_ move: [String : Any], _ id: String) {
        socket.emit("move", move, id)
    }
    
    func listenToMoves() {
        socket.on("animateMove") { (data, ack) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "animateMove"), object: data[0] as! [String : Any])
        }
    }
    
    func listenToUserUpdates() {
        socket.on("userConnected") { (dataArray,ack) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userConnected"), object: dataArray[0] as! [[String : Any]])
        }
        
        socket.on("userDisconnected") { (dataArray, ack) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userDisconnected"), object: dataArray[0] as! [[String : Any]])
        }
        
        socket.on("userInvited") { (dataArray, ack) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userInvited"), object: dataArray[0] as! [String : Any])
        }
    }
}
