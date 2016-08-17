//
//  DiscoverCell.swift
//  SwiftProjDemo
//
//  Created by wangxiaobo on 16/8/17.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit
import Kingfisher

class DiscoverCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        subjectLabel.hidden = true
        contentLabel.text = ""
        titleLabel.text = ""
        bgImageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    func cellForModel(model: Discover){
        bgImageView.kf_setImageWithURL(NSURL(string: model.content.path)!)
        contentLabel.text = model.content.content
        titleLabel.text = model.content.title
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
