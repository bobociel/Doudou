//
//  ContentProtocols.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

protocol SomeProtocol{
    static var nickname: String { get set }
    var fullName: String { get set }
    static func getNickName(name: String) -> String
    func getFullName(fullname: String) -> String
}

class ContentProtocols: NSObject {
    override init() {
        super.init()
        /******************* 1，(协议的语法)Protocol Syntax *******************/
        //协议(Protocol)用于定义完成某项任务或功能所必须的方法和属性

//        protocol SomeProtocol{
//        }

//        struct SomeStruct: SomeProtocol{
//        }

        class SuperClass{
            static var _nickname: String = ""
            var _name: String = ""
        }

        class SomeClass: SuperClass, SomeProtocol{
            private static var nickname: String{ get{ return "nickname:\(_nickname)"} set{ _nickname = newValue} }
            private var fullName: String{ get{return _name} set{_name = newValue} }

            private static func getNickName(name: String) -> String {
                return "nickname:\(name)"
            }

            private func getFullName(fullname: String) -> String {
                return "fullName:\(fullname)"
            }
        }

        /******************* 2，(对属性的规定)Property Requirements *******************/
        //1,协议可以规定其遵循者提供特定名称与类型的实例属性(instance property)或类属性(type property)，而不管其是存储型属性(stored property)还是计算型属性(calculate property)。此外也可以指定属性是只读的还是可读写的。

        //2,如果协议要求属性是可读写的，那么这个属性不能是常量存储型属性或只读计算型属性；如果协议要求属性是只读的(gettable)，那么计算型属性或存储型属性都能满足协议对属性的规定，在你的代码中，即使为只读属性实现了写方法(settable)也依然有效。

        //3,协议中的属性经常被加以var前缀声明其为变量属性，在声明后加上{ set get }来表示属性是可读写的，只读的属性则写作{ get }

        //4,通常在协议的定义中使用class前缀表示该属性为类成员；在枚举和结构体实现协议时中，需要使用static关键字作为前缀。


        /******************* 3，(对方法的规定)Method Requirements *******************/
        //1,协议可以要求其遵循者实现某些指定的实例方法或类方法。这些方法作为协议的一部分，像普通的方法一样清晰的放在协议的定义中，而不需要大括号和方法体。
        //2,协议中类方法的定义与类属性的定义相似，在协议定义的方法前置class关键字来表示。当在枚举或结构体实现类方法时，需要使用static关键字来代替。
        //3,注意：协议中的方法支持变长参数(variadic parameter)，不支持参数默认值(default value)。

        /******************* 4，(对突变方法的规定)Mutating Method Requirements *******************/


        /******************* 5，(对构造器的规定)Initializer Requirements *******************/

        /******************* 6，(协议类型)Protocols as Types *******************/

        /******************* 7，(代理)Delegation *******************/

        /******************* 8，Adding Protocol Conformance with an Extension *******************/

        /******************* 9， Collections of Protocol Types *******************/


        /******************* 10，Protocol Inheritance *******************/

        /******************* 11， Class-Only Protocols *******************/

        /******************* 12， Protocol Composition *******************/

        /******************* 13， Checking for Protocol Conformance *******************/

        /******************* 14， Optional Protocol Requirements *******************/

        /******************* 15， Protocol Extensions *******************/
        
    }
}
