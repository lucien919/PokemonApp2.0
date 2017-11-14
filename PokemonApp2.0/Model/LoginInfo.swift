//
//  LoginInfo.swift
//  PokemonApp2.0
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseAuth

class Constants{
    static let kUserNameKey = "com.company.app.UserKey"
    static let kPassKey = "com.company.app.PassKey"
}

class LoginInfo{
    static let shared = LoginInfo()
    var user:User?
    var isLoggedIn:Bool{
        get{
            return user != nil
        }
    }
    let sharedAuth = Auth.auth()
    
    init() {
        sharedAuth.addStateDidChangeListener{
            (auth, user) in
            guard let user = user else{return}
            guard let email = user.email else{return}
            self.user = User(email: email, uid: user.uid)
        }
    }
}

struct User{
    typealias UserEmail = String
    typealias UserUID = String
    let email:UserEmail
    let uid:UserUID
}
