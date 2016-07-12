//
//  ContentFunction.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentFunction: NSObject {
    override init() {
        super.init()
        /*Every function in Swift has a type, consisting of the function’s parameter types and return type. You can use this type like any other type in Swift, which makes it easy to pass functions as parameters to other functions, and to return functions from functions. Functions can also be written within other functions to encapsulate useful functionality within a nested function scope.
         */

        /******************* 1，函数的定义和调用(Defining and Calling Function) *******************/
        func greetPerson(person: String) -> String{
            return "Greet to \(person)"
        }
        //TODO
        print(greetPerson( "小明"), separator: "-", terminator: "!" )
        print(greetPerson( "小花"))

        /******************* 2，函数的参数和返回值(Function Parameters and Return Value) *******************/
        //(1),无参数函数(Function Without Parameter)
        func sayHello() -> String{
            return "Hello,David"
        }
        print(sayHello())
        //(2),多个参数函数(Function With Multiple Parameters)
        func sayHelloGender(person: String, male: Bool){
            if(male){
                print("Hello, Mr \(person)")
            }else{
                print("Hello, Ms \(person)")
            }
        }
        sayHelloGender("John", male: true)
        sayHelloGender("Lucy", male: false)
        //(3),无返回值函数(Function Without Return Value)
        //返回值可被忽略
        func sayHelloInt(person: String) -> Int{
            let hello = "Hello,\(person)"
            print(hello)
            return hello.characters.count
        }

        func sayHelloNo(person: String){
            sayHello()
            print("Hi,\(person)")
        }

        //(4),多个返回值函数(Function With Multiple Return Values)
        func sayHelloPersons(persons: [String] ) -> (persons: Array<String>, count: Int){
            return (persons, persons.count)
        }

        print(sayHelloPersons(["sandy","lala","bo","dingding","bicy"]))
        //(5),可选元组返回类型(Optional Tuple Return Types)
        func sayHelloPersonsNil(persons:[String] ) -> (persons: Array<String>, count: Int)?{
            if(persons.isEmpty){
                return nil
            }
            return (persons, persons.count)
        }
        print(sayHelloPersonsNil([]))

        /******************* 3，函数参数标签和函数参数(Function Argument Labels and Paratemer Name) *******************/
        //(1),指定参数标签(Specifying Argument Labels)
        func sayHelloArgLabel(from person: String, to persons:String){
            print("from \(person) to \(persons)")
        }
        sayHelloArgLabel(from: "熊猫", to: "长颈鹿")

        //(2),省略参数标签(Omitting Argument Labels)
        func sayHelloOmitArgLabel(person: String, to persons: String){
            print("from \(person) to \(persons)")
        }
        sayHelloOmitArgLabel("狮子", to: "树懒")

        //(3),默认参数值(Default Parameter Value)
        func sayHelloDefaultValue(from person:String = "虞姬", to persons:String){
            print("from \(person) to \(persons)")
        }
        sayHelloDefaultValue(to: "项羽")

        //(4),可变参数值(Multiple Parameter Value)
        func sayHelloMultipleValue(to persons: String...){
            for person in persons{
                print("Hello,\(person)")
            }
        }
        sayHelloMultipleValue(to: "孙悟空","后羿","妲己")

        //(5),In-Out参数值(In-Out Parameter Value)
        /*Function parameters are constants by default. Trying to change the value of a function parameter from within the body of that function results in a compile-time error. This means that you can’t change the value of a parameter by mistake. If you want a function to modify a parameter’s value, and you want those changes to persist after the function call has ended, define that parameter as an in-out parameter instead.*/

        //TODO
        func swapPerson(inout aPerson: String, inout bPerson: String){
            let tempA = aPerson
            aPerson = bPerson
            bPerson = tempA
        }
        var aPerson = "🐱"
        var bPerson = "🐶"
        swapPerson(&aPerson, bPerson: &bPerson)
        print("aPerson:\(aPerson),bPerson:\(bPerson)")

        /******************* 4，函数类型(Function Types) *******************/
        //(1),使用函数类型

        //(2),函数作为参数

        //(3),函数作为返回值

        /******************* 5，函数的嵌套(Netsed Function) *******************/

    }
}
