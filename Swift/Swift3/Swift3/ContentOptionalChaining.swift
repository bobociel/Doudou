//
//  ContentOptionalChaining.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentOptionalChaining: NSObject {
    override init() {
        super.init()

        /******************* 1，(使用可选链调用而不是强制展开)Optional Chaining as an Alternative to Forced Unwrapping *******************/
        class ClassA{
            var cls: ClassB?
        }

        class ClassB{
            var number = 1
        }
        let classA = ClassA()
        print(classA.cls!.number)  //error
        if let cls = classA.cls?.number{
            print("\(cls):is not nil");
        }else{
            print("is nil")
        }

        /******************* 2，Defining Model Classes for Optional Chaining *******************/

        /******************* 3，Accessing Properties Through Optional Chaining *******************/

        /******************* 4，Calling Methods Through Optional Chaining *******************/

        /******************* 5，Accessing Subscripts Through Optional Chaining *******************/

        /******************* 6，Linking Multiple Levels of Chaining *******************/

        /******************* 7，Chaining on Methods with Optional Return Values *******************/

    }
}
