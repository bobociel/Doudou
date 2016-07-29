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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        NSThread.sleepForTimeInterval(1)

        WXApi.registerApp(WeChatAppID)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self);
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self);
    }

    //MARK:-WeiChatDelegate
    func onResp(resp: BaseResp!){
        if resp.isKindOfClass(SendMessageToWXReq){
            if resp.errCode == WXSuccess.rawValue{
                print("share success")
            }else{
                print("share failure:\(resp.errCode),\(resp.errStr)")
            }
        }
    }

}

