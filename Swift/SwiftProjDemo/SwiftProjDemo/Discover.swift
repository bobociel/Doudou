//
//  DiscoverModel.swift
//  SwiftSpider
//
//  Created by wangxiaobo on 16/8/16.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

public enum DiscoverType: UInt {
    case None      = 0
    case Supplier  = 1 //商家
    case Inspire   = 2 //灵感
    case Topic     = 3 //话题
    case Post      = 4 //作品
    case Subject   = 5 //优选
}

public class DiscoverContent: Model, ModelConvert {
    var supplier_id: String = ""
    var title: String = ""
    var content: String = ""
    var tag: String = ""
    var path: String = ""
    var count: UInt = 0

    public class func modelWithJSON(json: JSON) -> DiscoverContent{
        let content = DiscoverContent()
        content.supplier_id = json["supplier_id"].stringValue
        content.title = json["title"].stringValue
        content.content = json["content"].stringValue
        content.tag = json["tag"].stringValue
        content.path = json["path"].stringValue
        content.count = json["count"].uIntValue
        return content
    }
}

public class Discover: NSObject {
    var discoverType: DiscoverType = DiscoverType.None
    var city_id: UInt = 0
    var ID: String = ""
    var content: DiscoverContent!

    public class func modeWithJSON(json: JSON) -> Discover{
        let d = Discover()
        d.discoverType = DiscoverType(rawValue: json["discover_type"].uIntValue) ?? .None
        d.city_id = json["city_id"].uIntValue
        d.ID = json["id"].stringValue
        d.content = DiscoverContent.modelWithJSON(json["content"])
        return d
    }
}

//"success": true,
//"data": {
//    "banner": [
//    {
//    "path": 图片链接,
//    "title": "",    //很可能不用,
//    "jump_way": "",   // 跳转方式
//    "jump_to": "", //跳转到, 可能是作品id, 商家id, 优选id等等
//    }
//    ],
//    "discover": [
//    {
//    "discover_type": 2,
//    "city_id": 0,
//    "on_top": true,
//    "id": 74,
//    "content": {
//    "supplier_id": 0,
//    "title": "",
//    "content": "复古婚礼风潮，翻新你的BIG DAY\t",
//    "tag": "复古婚礼",
//    "path": "http://mt-other.qiniudn.com/2015/11/03/ca65a32ac910090a42e7daa952a6e138.png",
//    "counts": "4403"
//    }
//    }
//]
