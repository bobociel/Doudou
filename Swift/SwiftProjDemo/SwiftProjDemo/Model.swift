//
//  ModelConvert.swift
//  SwiftProjDemo
//
//  Created by wangxiaobo on 16/8/18.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ModelConvert {
    static func modelWithJSON(json: JSON) -> AnyObject;
}

public class Model: NSObject {
    
}

