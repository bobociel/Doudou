//
//  ViewController.swift
//  SwiftProjDemo
//
//  Created by wangxiaobo on 16/8/17.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//
import UIKit

class DiscoverViewController: BaseViewController {
    var tableView: UITableView?
    var dataArray: Array<Discover> = []

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), style: UITableViewStyle.Grouped)
        tableView?.contentInset.top = -STATUSBAR_HEIGHT
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView!.backgroundColor = UIColor.clearColor()
        tableView!.registerNib(UINib.init(nibName:"DiscoverCell", bundle: nil), forCellReuseIdentifier: "DiscoverCell")
        self.view.addSubview(tableView!)

        HttpManager.getDiscoverList(1) { (array, errMsg) in
            self.dataArray = array as! [Discover]
            self.tableView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DiscoverViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoverCell") as! DiscoverCell
        cell.cellForModel( dataArray[indexPath.row] as Discover )
        return cell;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 350 * HEIGHT_AUTO + 10;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

