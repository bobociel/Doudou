//
//  ViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/6.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .Plain, target: self, action: #selector(ViewController.shareAction))

        dataArray = ["The Basics",
                     "Operation",
                     "String And Characters",
                     "Collection Types",
                     "ControlFlow",
                     "Functions",
                     "Closures",
                     "Enumerations",
                     "Class And Strutures",
                     "Properties",
                     "Methods",
                     "Subscripts",
                     "Inheritance",
                     "Initialization",
                     "Deinitialization",
                     "ARC",
                     "Optional Chaining",
                     "Error Handling",
                     "Type Casting",
                     "Nested Types",
                     "Extensions",
                     "Protocols",
                     "Generics",
                     "Access Control",
                     "Advanced Operators"]
    }

    func shareAction() {
        let req = SendMessageToWXReq()
        req.text = "Hello"
        req.bText = true
        req.scene = 0;
        WXApi.sendReq(req);
    }

    //MARK: - UITableVIew
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell")
        cell?.textLabel?.text = dataArray[indexPath.row]
        return cell!;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.performSegueWithIdentifier("goContent", sender: indexPath.row )
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ContentViewController
        vc.contentType = ContentType(rawValue: sender as! Int )!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

