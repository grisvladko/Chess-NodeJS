//
//  DataBase.swift
//  ChessFirebase
//
//  Created by hyperactive on 01/10/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DataBase {
    
    static let db = Firestore.firestore()
    
    static func updateDataBase(_ collection : String, _ document : String, _ data : [String : Any]) {
        
        db.collection(collection).document(document).updateData(data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func setDataBase(_ collection : String, _ document : String, _ data : [String : Any]) {
        db.collection(collection).document(document).setData(data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func deleteDocument(_ collection: String, _ document: String ) {
        db.collection(collection).document(document).delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func setGameForDataBase(_ collection : String, _ document: String,
        _ collection2 : String, _ document2 : String, _ data : [String : Any ]) {
        db.collection(collection).document(document).collection(collection2).document(document2).setData(data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func updateGameForDataBase(_ collection : String, _ document: String, _ collection2 : String, _ document2 : String, _ data : [String : Any ]) {
        db.collection(collection).document(document).collection(collection2).document(document2).updateData(data) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
