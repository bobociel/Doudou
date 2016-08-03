//
//  AppDelegate.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/6.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Thread.sleep(forTimeInterval: 1)
        WXApi.registerApp(WeChatAppID)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self);
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpen(url, delegate: self);
    }

    //MARK:-WeiChatDelegate
    func onResp(_ resp: BaseResp!){
        if resp.isKind(of: SendMessageToWXReq.self){
            if resp.errCode == WXSuccess.rawValue{
                print("share success")
            }else{
                print("share failure:\(resp.errCode),\(resp.errStr)")
            }
        }
    }

}

