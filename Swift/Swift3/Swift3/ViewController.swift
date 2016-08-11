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

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.blueColor()), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(ViewController.shareAction) )

        let scrollView = createScroll(btnCount: { () -> Int in
            return 12
            }, button: { (index) -> UIButton in
                let btn = UIButton.init(frame: CGRect(x: 50*index, y: 0, width: 40, height: 40))
                btn.backgroundColor = UIColor.red
                return btn
        })

        view.addSubview(scrollView)
    }

    // MARK:-闭包的使用
    func createScroll(btnCount:() -> Int, button:(index: Int) -> UIButton ) -> UIScrollView{
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 65, width: 320, height: 44))
        scrollView.contentSize = CGSize(width: 50*btnCount(), height: 44)
        scrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        for n in 0..<btnCount() {
            let btn = button(index: n)
            scrollView.addSubview(btn)
        }
        return scrollView
    }

    // MARK:-数据懒加载
    lazy var dataArray = {() -> [String] in
        return ["The Basics",
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
    }()

    // MARK:分享
    func shareAction() {
        let req = SendMessageToWXReq()
        req.text = "Hello"
        req.bText = true
        req.scene = 0;
        WXApi.send(req);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{

    //MARK: - UITableView
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
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
