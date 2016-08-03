//
//  ContentInheritance.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentInheritance: NSObject {
    override init() {
        super.init()
        /******************* 1，定义基类(Defining a Base Class) *******************/
        /*Swift classes do not inherit from a universal base class. Classes you define without specifying a superclass automatically become base classes for you to build upon.*/
        class Animal{
            var name : String{
                return "name:\(self.name)"
            }
            func run(_ name: String = "Animal") -> String {
                return "\(self.name),run"
            }

            final func call(_ name: String) -> String {
                return "\(self.name),call"
            }
        }
        print( Animal().run() )

        /******************* 2，子类(Subclassing) *******************/
        class Cat: Animal{
            
        }

        print(Cat().run())

        /******************* 3，覆盖(Overriding) *******************/
        class Mouse: Animal{
            override var name: String{
                return "supername:\(super.name)+selfname:\(self.name)"
            }
        }
        print( Mouse().name )

        class Dog: Animal{
            var age = 12
            override private func run(_ name: String = "Dog") -> String {
                return "\(name), run fast"
            }
        }
        print(Dog().run())

        /******************* 4，防止覆盖(Preventing Overrides) *******************/
        /*
         You can prevent a method, property, or subscript from being overridden by marking it as final. Do this by writing the final modifier before the method, property, or subscript’s introducer keyword (such as final var, final func, final class func, and final subscript).

         Any attempt to override a final method, property, or subscript in a subclass is reported as a compile-time error. Methods, properties, or subscripts that you add to a class in an extension can also be marked as final within the extension’s definition.

         You can mark an entire class as final by writing the final modifier before the class keyword in its class definition (final class). Any attempt to subclass a final class is reported as a compile-time error.
         */
    }
}
