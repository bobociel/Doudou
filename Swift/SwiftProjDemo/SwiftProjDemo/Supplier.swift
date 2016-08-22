//
//  Supplier.swift
//  SwiftProjDemo
//
//  Created by wangxiaobo on 16/8/18.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

enum SupplierLevel: UInt {
    case NoBusiness   = 0  //未合作商家
    case Assis        = 1  //小编
    case Business     = 2  //合作商家
    case Authenticate = 3  //认证商家
    case Brands       = 4  //品牌商家
}

class Supplier: NSObject {
    var is_youxuan: Bool = false
    var level: SupplierLevel = SupplierLevel.NoBusiness
    var user_id: String = ""
    var avatar: String = ""
    var company: String = ""

    var like_num: UInt = 0
    var view_num: UInt = 0
    var coupon_num: UInt = 0
    var post_num: UInt = 0

    
}

//{
//    "success": true
//    "data": {
//        "sub_page": 0,
//        "page": 4,
//        "supplier_list": [
//        {
//        "avatar": "http://mt-avatar.qiniudn.com/2015/01/29/9a52673ca1af40b2ab8895ce879775ee.jpg",
//        "post_num": 10,
//        "company": "拾光婚礼定制",
//        "level": 0,
//        "view_num": 4547,
//        "like_num": 95,
//        "coupon_num": 0,
//        "user_id": 19752,
//        "is_youxuan": false
//        }
//        ]
//    }
//}