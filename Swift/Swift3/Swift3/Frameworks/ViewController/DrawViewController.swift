//
//  DrawViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/8/2.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    var brushs: [BaseBrush]!
    @IBOutlet weak var board: Board!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.brushs = [PencilBrush(),PencilBrush(),PencilBrush(),PencilBrush(),PencilBrush(),EraserBrush()]

        self.board.brush = PencilBrush()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        assert(sender.tag < self.brushs!.count, "Out Of Index")
        self.board.brush = self.brushs![sender.selectedSegmentIndex];
        if(sender.selectedSegmentIndex == 5){
            self.board.strokeWidth = 4
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
