//
//  ContentClassesAndStructures.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentClassesAndStructures: NSObject {
    override init() {
        super.init()
        /******************* 1，类和结构体比较(Comparing Structures and Classes) *******************/
        //1,基本定义
        class SomeClass{
            var name: String
            var age: Int
            init(){
                name = "SomeClass"
                age = 0
            }
        }
        struct SomeStruct{
            var height: Double = 0
            var width: Double = 0
        }
        //2,初始化实例
        let aClass = SomeClass();
        let aStruct = SomeStruct();
        //3，属性访问
        print( aClass.name )
        print( aStruct.height )
        //4,结构体类型的成员逐一构造器
        let bStruct = SomeStruct(height: 100, width: 100)
        print(bStruct.height);

        /******************* 2，结构体和枚举都是值类型(Structures and Enumerations are Value Type) *******************/
        
        /******************* 3，类是引用类型(Classes Are Reference Types) *******************/

        /******************* 4，(类和结构体的选择)Choosing Between Classes and Structures *******************/

        /******************* 5，(字符串，数组，字典的assign, copy)Assignment and Copy Behavior for Strings, Arrays, and Dictionaries *******************/
        
    }
}
