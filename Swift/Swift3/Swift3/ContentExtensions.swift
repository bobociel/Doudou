//
//  ContentExtensions.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

struct Point {
    var x: Double = 0
    var y: Double = 0
}

struct Size {
    var height: Double = 0
    var width: Double = 0
}

public struct Rect {
    var origin: Point = Point()
    var size: Size = Size()
}

extension Rect{
    //扩展计算属性
    var x_100: Double { return 100 * self.origin.x }
    var y_100: Double { return 100 * self.origin.y }

    //扩展构造器
    init(center: Point, size: Size){
        let originX = center.x + size.width / 2.0
        let originY = center.y + size.height / 2.0
        self.init(origin: Point(x: originX, y: originY), size: size)
    }

    //扩展方法1
    static func RectMake(x: Double, _ y: Double, _ height: Double, _ width: Double) -> Rect{
        return Rect(origin: Point(x: x,y: y), size: Size(height: height,width: width))
    }

    //扩展方法2
    func printHello(nums: Int, task: (n: Int) -> () ) {
        var count = 0
        while count < nums {
            count += 1
            task(n: count)
        }
    }
}

public func RectMake(x: Double, _ y: Double, _ height: Double, _ width: Double) -> Rect {
    return Rect(origin: Point(x: x,y: y), size: Size(height: height,width: width))
}

class ContentExtensions: NSObject {
    override init() {
        super.init()
        /******************* 1，(扩展语法)Extension Syntax *******************/
        //extension SomeType{
        //    //要扩展的内容
        //}

        //一个extension不仅可以扩展一个类型，和可以让该类型实现多个协议
        //extension SomeType: SomeProtocol{
        //    //要扩展的内容
        //}

        /******************* 2，(计算属性)Computed Properties *******************/
        //注意：extension可以扩展计算属性，但是不可以扩展存储属性
        let rect1 = Rect(origin: Point(x: 100,y: 100), size: Size(height: 200,width: 200))
        print(rect1.x_100);

        /******************* 3，(构造器)Initializers *******************/
        //1, 扩展可以向已有类型添加新的构造器。这可以让你扩展其它类型，将你自己的定制类型作为构造器参数，或者提供该类型的原始实现中没有包含的额外初始化选项。
        //2, 扩展能向类中添加新的便利构造器，但是它们不能向类中添加新的指定构造器或析构函数。指定构造器和析构函数必须总是由原始的类实现来提供。

        let rect2 = Rect(center: Point(x: 100,y: 100), size: Size(height: 100,width: 100))
        print(rect2)

        /******************* 4，(方法)Methods *******************/
        var rect3 = Rect.RectMake(100, 100, 100, 100)
        rect3.origin.y = 200
        print(rect3);

        Rect().printHello(10) { (n) in
            print("Hello:\(n)")
        }

        /******************* 5，(下标)Subscripts *******************/


        /******************* 6，(嵌套类型)Nested Types *******************/

    }
}
