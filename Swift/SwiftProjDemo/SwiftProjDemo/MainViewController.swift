//
//  MainViewController.swift
//  SwiftProjDemo
//
//  Created by wangxiaobo on 16/8/17.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let vc = DiscoverViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.orangeColor()

        self.createVC("DiscoverViewController", title: "发现", image: "tabbar_discover")
        self.createVC("ChatViewController", title: "消息", image: "tabbar_chat")
        self.createVC("PCViewController", title: "个人", image: "tabbar_center")
    }

    func createVC(vcName: String,title: String, image: String) {
        guard let clsName = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] else{
            print("命名空间不存在")
            return
        }

        let vcClass: AnyClass? = NSClassFromString((clsName as! String) + "." + vcName)

        guard let clsType = vcClass as? UIViewController.Type else{
            print("不存在的类")
            return
        }

        let NVC = BaseNavigationController(rootViewController: clsType.init())
        NVC.tabBarItem.title = title
        NVC.tabBarItem.image = UIImage(named: image)

        self.addChildViewController(NVC)
    }

}
