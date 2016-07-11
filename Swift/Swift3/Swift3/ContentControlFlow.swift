//
//  ContentControlFlow.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentControlFlow: NSObject {
    override init() {
        super.init()
        /******************* 1，for In循环(For-in loop) *******************/
        //for in :
        /******************* 2，while循环(While loop) *******************/
        //(1),while

        //(2),repeat while

        /******************* 3，条件语句(Conditional Statements) *******************/

        //(1)，if语句(if Statements)

        //(2)，switch语句(switch Statements) 
        //①--默认
        switch "b" {
        case "a":
            print("this is a")
        case "b":
            print("this is b")
        case "c":
            print("this is c")
        default:
            print("this is default")
        }
        //②--不存在隐式贯穿(No Implicit Fallthrough)
        switch "b" {
        case "a":
            print("this is a")
        case "b": break
        case "c":
            print("this is c")
        default:
            print("this is default")
        }

        //③--间隔匹配(Interval Matching)
        switch 33 {
        case 0...60:
            print("不及格")
        case 60...80:
            print("及格")
        case 80...100:
            print("优秀")
        default:
            print("及格")
        }
        //④--元组(Tuples)
        switch (0.5,0.5) {
        case (0.0,0.0):
            print("this is origin")
        case (_,0.0):
            print("this is on x")
        case(0.0,_):
            print("this is on y")
        case(-2...2,-2...2):
            print("this is in the box")
        default:
            print("this is out the box")
        }
        //⑤--值绑定(Value binding)
        switch (0,2) {
        case (let x, 0):
            print("this is on x:\(x)")
        case (0, let y):
            print("this is on y:\(y)")
        case let(x, y):
            print("this is on (\(x),\(y))")
        }
        //⑥--where
        switch (2,2) {
        case let(x, y) where x > y:
            print("this is on x > y")
        case let(x,y) where x < y:
            print("this is on x < y")
        case let(x,y) where x == y:
            print("this is on x == y")
        default:
            print("this is not point")
        }
        //⑦--复合案例
        switch "b" {
        case "a","b":
            print("this is a or b")
        case "c":
            print("this is c")
        default:
            print("this is default")
        }
        /******************* 4，控制转移语句(Control Transfer Statements) *******************/
        //(1),cintinue - (在loop语句,switch语句 跳出本次循环)
        for n in 1...5{
            if(n==1){
                continue
            }
            print("\(n)")
        }
        //(2),break - (在loop语句,switch语句 跳出当前循环)
        for n in 1...5{
            if(n==3){
                break
            }
            print("\(n)")
        }

        //(3),Fallthrough
        switch "b" {
        case "a","b":
            print("this is a or b")
            fallthrough
        default:
            print("and also is character")
        }

        //(4),标签语句(Labeled Statements，中断具体代码块)
        let numberArray = [0,1,2,3,4,5,6,7,8,9,10]
        goloop: for n in numberArray {
            switch n{
            case 0...5:
                print("not good")
            case 5:
                continue goloop
            case 6...10:
                break goloop
            default:
                print("good")
            }
        }

        /******************* 5，返回语句(Early Exit) *******************/
        //return (在loop语句,跳出所有循环)
        func greet(person: [String: String]) {
            guard let name = person["name"] else {
                return
            }

            print("Hello \(name)!")

            guard let location = person["location"] else {
                print("I hope the weather is nice near you.")
                return
            }

            print("I hope the weather is nice in \(location).")
        }

        greet(person: ["name": "John"])
        greet(person: ["name": "Jane", "location": "Cupertino"])

        /******************* 5，检查API可用性(Checking API Availability) *******************/
        if #available(iOS 9, OSX 10.10, *) {
            // Use iOS 9 APIs on iOS, and use OS X v10.10 APIs on OS X
        } else {
            // Fall back to earlier iOS and OS X APIs
        }

    }
}
