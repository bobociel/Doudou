//
//  PerfectMain.swift
//  PerfectDemo
//
//  Created by wangxiaobo on 16/8/13.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import Foundation
import PerfectLib
import MySQL

// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
public func PerfectServerModuleInit() {

    // Install the built-in routing handler.
    // Using this system is optional and you could install your own system if desired.
    Routing.Handler.registerGlobally()

    Routing.Routes["GET", "/index.html" ] = { (_:WebResponse) in return IndexHandler() }

    // Check the console to see the logical structure of what was installed.
    print("\(Routing.Routes.description)")
}

class IndexHandler: RequestHandler {

    func handleRequest(request: WebRequest, response: WebResponse) {
        let name = request.param("name", defaultValue: "")
        let psw = request.param("password", defaultValue: "")

        let openDB = MySQL().connect("192.168.1.124", user: "wxb", password: "123456", db: "xiaobo", port: 3306, socket: "", flag: 0)
        assert(openDB, "open database failed")
        let userExist = MySQL().query("SELECT * FROM user WHERE name = \(name) ")
        assert(userExist, "user is not exist")

        response.appendBodyString("Index handler: You accessed path \(request.requestURI())")
        response.requestCompletedCallback()
    }
}
