//
//  ContentStringAndCharacters.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentStringAndCharacters: NSObject {
    override init() {
        super.init()
        /******************* 1，字符串字面量(string literal) *******************/
        let someString = "let some literal string"
        print(someString)
        /******************* 2，空字符串(empty string) *******************/
        let emptyString = ""
        var emptyStr = String()
        emptyStr = "empty string"
        print(emptyString,emptyStr)
        /******************* 3，可变字符串(strig mutablility) *******************/
        var mutablilityString = "Hello " + emptyStr
        print(mutablilityString)

        /******************* 4，字符串是值类型(Strings Are Value Types) *******************/
        /*
         Swift’s String type is a value type. If you create a new String value, that String value is copied when it is passed to a function or method, or when it is assigned to a constant or variable. In each case, a new copy of the existing String value is created, and the new copy is passed or assigned, not the original version. Value types are described in Structures and Enumerations Are Value Types.
        */
        func changeString(_ str: String){
            print(str)
        }

        mutablilityString += "!"
        changeString(mutablilityString)

        /******************* 5，字符(working with character) *******************/
        let character: Character = "🐶"
        let characters: [Character] = ["d","o","g",character]
        var characterString = String(characters)
        for ch in characters{
            print("characters:",ch)
        }
        for ch in characterString.characters{
            print("characterString",ch)
        }

        /******************* 6，字符拼接(Concatenating Strings and Characters) *******************/
        characterString.append(character)
        print(characterString)

        /******************* 7，插入字符串(String Interpolation) *******************/
        characterString = "\(characterString)+🐱=\(3+3)"
        print(characterString)

        /******************* 8，Unicode(Unicode) *******************/


        /******************* 9，字符计数(Characters Count) *******************/
        print(characterString.characters.count)

        /******************* 10，字符串的访问和修改(Accessing and Modifying a String) *******************/

        //(1),字符串索引
        let startIndex = characterString.startIndex
        let endIndex = characterString.endIndex
        let afterStartIndex = characterString.index(after: startIndex)
        let beforeEndIndex = characterString.index(before: endIndex)
        let offsetIndex = characterString.index(startIndex, offsetBy: 2)

        print("startIndex:\(startIndex),endIndex:\(endIndex),afterStartIndex:\(afterStartIndex),beforeEndIndex:\(beforeEndIndex),offsetIndex:\(offsetIndex)" )

        //(2),插入和移除字符
        characterString.insert("!", at: characterString.endIndex)
        characterString.insert("1", at: characterString.startIndex )


        /******************* 11，字符串比较(Comparing String ) *******************/
        let comparedString: String = "dog🐶🐶+🐱=6"
        if comparedString == characterString{
            print(" comparedString is equal characterString:\(comparedString)")
        }
        characterString = "\(characterString)!"
        if comparedString != characterString{
            print(" comparedString isn't equal characterString:\(characterString)")
        }

        if comparedString.hasPrefix("dog"){
            print(" comparedString begin with \"dog\" ")
        }

        if characterString.hasSuffix("!"){
            print(" characterString end with \"!\" ")
        }

        /******************* 12，Unicode字符串( Unicode Representations of Strings ) *******************/
        //TODO

    }
}
