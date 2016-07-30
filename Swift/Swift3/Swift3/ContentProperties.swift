//
//  ContentProperties.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentProperties: NSObject {
    override init() {
        super.init()
        /******************* 1，存储属性(Stored Properties) *******************/
        /*1,计算属性可以用于类、结构体和枚举，存储属性只能用于类和结构体
         2,存储属性和计算属性通常与特定类型的实例关联。但是，属性也可以直接作用于类型本身，这种属性称为类型属性。
         3,另外，还可以定义属性观察器来监控属性值的变化，以此来触发一个自定义的操作。属性观察器可以添加到自己定义的存储属性上，也可以添加到从父类继承的属性上。
         */

        /*
         由于结构体（struct）属于值类型。当值类型的实例被声明为常量的时候，它的所有属性也就成了常量。
         属于引用类型的类（class）则不一样。把一个引用类型的实例赋给一个常量后，仍然可以修改该实例的变量属性。
         */
        struct FixNumberRange{
            var firstValue: Int
            let length: Int
        }

        var valueRange = FixNumberRange(firstValue: 0, length: 6)
        print(valueRange)
        valueRange.firstValue = 10
        print(valueRange)

        class ClassE{
            var name: String
            init(name: String){
                self.name = name
            }
        }

        let classE = ClassE(name: "ClassE")
        print(classE.name)

        //(1),常量结构体存储属性
        let valueRange2 = FixNumberRange(firstValue: 12, length: 2)
        print(valueRange2)
//        valueRange2.firstValue = 15
        //(2),延迟存储属性
        class Dog: NSObject{
            override init() {
                NSThread.sleepForTimeInterval(1)
                super.init()
            }
        }
        class Person{
           lazy var dog = Dog()
        }

        let a = Person()
        print( a.dog )

        //(3),存储属性和实例变量
        // 在OC中存在属性和对应属性的实例变量，Swift只存在属性没有对应属性的实例变量

        /******************* 2，计算属性(Computed Properties) *******************/
        /*除存储属性外，类、结构体和枚举可以定义计算属性。计算属性不直接存储值，而是提供一个 getter 和一个可选的 setter，来间接获取和设置其他属性或变量的值。*/
        //(1),set,get构造器
        class ClassA{
            var _name = ""
            var name: String{
                get{
                    return _name
                }
                set{
                    _name = newValue
                }
            }
        }

        let classA = ClassA()
        classA.name = "classA"
        print(classA.name)

        //(2),只读属性
        class ClassB{
            var name: String{
                return "classB"
            }
        }
        print( ClassB().name )
        /******************* 3，属性观察者(Properties Observers) *******************/
        class ClassC{
            var name: String = "default"{
                willSet{
                    self.name = newValue
                    print(newValue)
                }
                didSet{
                    self.name = oldValue
                    print(oldValue)
                }
            }
        }
        let classC = ClassC()
        classC.name = "classC"
        print( classC.name )
        /******************* 4，全局属性和本地属性(Global Properties and Local Properties) *******************/
        //以上所写的关于计算与观察属性值的特性同样适用于全局和局部变量。全局变量是在任何函数、方法、闭包、类型上下文外部定义的变量，而局部变量是在函数、方法、闭包中定义的变量。

        /******************* 5，类型属性(Type Properties) *******************/
        class ClassD{
            static var name = "ClassD"
        }
        print( ClassD.name )
    }
}

