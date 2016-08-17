//
//  HttpManager.swift
//  SwiftSpider
//
//  Created by wangxiaobo on 16/8/16.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

#if DEBUG
public let APIBASE = "http://dev.lovewith.me"
#else
public let APIBASE = "http://www.lovewith.me"
#endif
public func CombineURL(url: String) -> String{ return APIBASE + url }

public let DISCOVER_LIST_URL: String = CombineURL("/app/v030/discover/")
public let SUPPLIER_LIST_URL: String = CombineURL("/app/v030/supplier/")
public let SUPPLIER_DETAIL_URL: String = CombineURL("/app/v030/supplier/")
public let HOTEL_LIST_URL: String = CombineURL("/app/v030/hotel/")
public let POST_LIST_URL: String = CombineURL("/app/v030/post/")
public let POST_DETAIL_URL: String = CombineURL("/app/v030/post/")

public typealias JSONResultBlock = (JSON, String) -> Void
public typealias ArrayResultBlock = (array: [AnyObject], errMsg: String) -> Void

public class HttpManager: NSObject{
    public class func shareInstance() -> HttpManager{
        return HttpManager()
    }

    /* GET DISCOVER LIST */
    public class func getDiscoverList(page:UInt, complection: ArrayResultBlock){
        get(DISCOVER_LIST_URL, parameters: ["page":page]) { (json, errMsg) in
            var dataArray: Array<Discover> = []
            for aJson in json["data"]["discover"].arrayValue {
                let discover = Discover.modeWithJSON(aJson)
                dataArray.append(discover)
            }
            complection(array: dataArray, errMsg: errMsg )
        }
    }

    /* GET SUPPLIER LIST */
    public class func getSupplierList(page:UInt, complection: ArrayResultBlock){
        get(DISCOVER_LIST_URL, parameters: ["page":page]) { (json, errMsg) in
            var dataArray: Array<Discover> = []
            for aJson in json["data"]["discover"].arrayValue {
                let discover = Discover.modeWithJSON(aJson)
                dataArray.append(discover)
            }
            complection(array: dataArray, errMsg: errMsg )
        }
    }
}

/// Basic Request
extension HttpManager
{
    /* Basic Request GET */
    public class func get(url: String, parameters:Dictionary<String,AnyObject>, complection: JSONResultBlock){
        Alamofire.request(.GET, url, parameters:parameters).responseData { response in
            let json = JSON(data: response.data!)
            print(#function,#line,response.request, response.result)
            print(json)
            complection(json, response.result.isFailure ? response.response.debugDescription : "" )
        }
    }

    /* Basic Request POST */
    public class func post(url: String, parameters:Dictionary<String,AnyObject>, complection: JSONResultBlock){
        Alamofire.request(.POST, url, parameters:parameters).responseData { response in
            let json = JSON(data: response.data!)
            complection(json, response.result.isFailure ? response.response.debugDescription : "" )
        }
    }

    /* Basic Request PUT */
    public class func put(url: String, parameters:Dictionary<String,AnyObject>, complection: JSONResultBlock){
        Alamofire.request(.PUT, url, parameters:parameters).responseData { response in
            let json = JSON(data: response.data!)
            complection(json, response.result.isFailure ? response.response.debugDescription : "" )
        }
    }

    /* Basic Request DELETE */
    public class func delete(url: String, parameters:Dictionary<String,AnyObject>, complection: JSONResultBlock){
        Alamofire.request(.DELETE, url, parameters:parameters).responseData { response in
            let json = JSON(data: response.data!)
            complection(json, response.result.isFailure ? response.response.debugDescription : "" )
        }
    }
}
