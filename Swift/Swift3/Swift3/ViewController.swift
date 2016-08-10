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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.blueColor()), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(ViewController.shareAction))

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
        WXApi.send(req);
    }

    //MARK: - UITableVIew
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")
        cell?.textLabel?.text = dataArray[(indexPath as NSIndexPath).row]
        cell?.imageView?.image = UIImage(named: "Logo")
        return cell!;
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        self.performSegue(withIdentifier: "goContent", sender: (indexPath as NSIndexPath).row )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "goDraw"{
            let vc = segue.destination as! ContentViewController
            vc.contentType = ContentType(rawValue: sender as! Int )!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

