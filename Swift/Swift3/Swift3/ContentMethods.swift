//
//  ContentMethods.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentMethods: NSObject {
    override init() {
        super.init()
        /******************* 1，实例方法(Instance Methods) *******************/
        /*
         Instance methods are functions that belong to instances of a particular class, structure, or enumeration. They support the functionality of those instances, either by providing ways to access and modify instance properties, or by providing functionality related to the instance’s purpose. Instance methods have exactly the same syntax as functions, as described in Functions.
         */

        //(1),实例方法
        class Person: NSObject{
            var name = "world"
            override init() {
                super.init()
            }

            func sayHello(_ name: String) -> String {
                let hello = "Hello,\(name)"
                return hello
            }
        }

        let personOne = Person.init()
        print( personOne.sayHello("笑笑") )

        //(2),self属性(The self property)
        //(3),在实例方法中修改值类型(Modifying Value Types from Within Instance Methods)
        //(4),在可变方法中对self赋值(Assigning to self Within a Mutating Method)
        struct Point{
            var x = 0,y = 0
            func comparyX(_ x:Int) -> Bool{
                return self.x > x
            }
            mutating func increase(_ x: Int,y: Int){
                self.x += x
                self.y += y
            }
            mutating func makeSelf(_ x: Int,y: Int){
                self = Point(x: x,y: y)
            }
        }

        let point = Point(x: 10,y: 10)
        point.comparyX(5)

        var point2 = Point(x: 5,y: 5)
        point2.increase(10, y: 10)
        print(point2.x,point2.y)

        var point3 = Point()
        print(point3)
        point3.makeSelf(20, y: 20)
        print(point3)

        /******************* 2，类型方法(Type Methods) *******************/
        /*
         1,实例方法是被某个类型的实例调用的方法。你也可以定义在类型本身上调用的方法，这种方法就叫做类型方法（Type Methods）。在方法的func关键字之前加上关键字static，来指定类型方法。类还可以用关键字class来允许子类重写父类的方法实现。
         2,@discardableResult 描述时，即使不接收返回值也不会警告
         */


        class Student{
            class func printStudent(){
                print("Student class")
            }
        }
        Student.printStudent()


        struct HelloPerson{
            static var isMale = true
            static func isMale(_ isMale: Bool) -> Bool{
                self.isMale = isMale
                return isMale
            }

//            @discardableResult 
            func sayHello(_ name: String,isMale: Bool) -> String {
                if  HelloPerson.isMale(isMale){
                    return "Hello,Mr \(name)"
                }else{
                    return "Hello,Ms \(name)"
                }
            }
        }
        print( HelloPerson().sayHello("亚瑟", isMale: true) )
    }
}
