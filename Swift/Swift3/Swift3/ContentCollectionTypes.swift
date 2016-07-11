//
//  ContentCollectionTypes.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentCollectionTypes: NSObject {
    override init() {
        super.init()
        //Swift provides three primary collection types, known as arrays, sets, and dictionaries, for storing collections of values. Arrays are ordered collections of values. Sets are unordered collections of unique values. Dictionaries are unordered collections of key-value associations.

        /******************* 1，集合的可变性(mutablity collection) *******************/
        //If you create an array, a set, or a dictionary, and assign it to a variable, the collection that is created will be mutable. This means that you can change (or mutate) the collection after it is created by adding, removing, or changing items in the collection. If you assign an array, a set, or a dictionary to a constant, that collection is immutable, and its size and contents cannot be changed.

        /******************* 2，数组(Array) *******************/
        //(1),创建空数组
        let emptyArray = [String]()
        print("emptyArray's count is \(emptyArray.count)")

        //(2),创建默认数组
        //TODO
//        var defaultArray = Array(repeating: 3, count: 3)
//        print(defaultArray)

        //(3),混合两个数组为一个数
        //TODO
//        let defaultArray2 = Array(repeating: 2, count: 3)
//        print(defaultArray + defaultArray2)

        //(4),使用数组字面量创建数组
        var firArray: [String] = ["One","Two","Three"]
        let sedArray = ["Four","Five","Six"]
        print(firArray + sedArray)

        //(5),数组的访问和修改
        if emptyArray.isEmpty {
            print("emptyArray.count: \(emptyArray.count)")
        }

        if firArray.contains("One"){
            print("firArray contain \"One\" ")
        }

        firArray.append("-")
        firArray.insert("@", atIndex:4)
        //TODO
        //firArray.remove(at: 0)
        firArray.removeLast();

        firArray = firArray + sedArray
        print(firArray[0...(firArray.count-1)])

        //(6),数组的迭代
        for a in firArray{
            print(a)
        }

        //TODO
//        for (i,n) in firArray.enumerated{
//            print("\(i):\(n)")
//        }

        /******************* 3，集合(Set) *******************/
        //(1),Set Type 和Hash Value
        print("1".hashValue)
        //(2),Set Type语法
        //使用Set创建集合
        //(3),初始化空Set Type
        let emptySet = Set<Character>()
        //(4),使用数组字面量创建Set
        var aSet: Set<String> = ["One", "Two", "Three"]
        print(aSet)
        //(5),访问和修改Set
        if emptySet.isEmpty{
            print("emptySer is empty")
        }

        if aSet.contains("One"){
            print("aSet contains \"One\" ")
        }

        aSet.insert("Five")
        aSet.remove("One")
        print(aSet)

        //(6),Set的迭代
        for s in aSet{
            print(s)
        }

        //TODO
//        for s in aSet.sorted(){
//            print(s)
//        }
        //(7),Set的集合运算
        let oddDigits: Set = [1, 3, 5, 7, 9]
        let evenDigits: Set = [0, 2, 4, 6, 8]
        let singleDigitPrimeNumbers: Set = [2, 3, 5, 7]

        //TODO
//        oddDigits.union(evenDigits).sorted()
//        // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//        oddDigits.intersection(evenDigits).sorted()
//        // []
//        oddDigits.subtracting(singleDigitPrimeNumbers).sorted()
//        // [1, 9]
//        oddDigits.symmetricDifference(singleDigitPrimeNumbers).sorted()
        // [1, 2, 9]


        //(8),Set之间的关系
        let houseAnimals: Set = ["🐶", "🐱"]
        let farmAnimals: Set = ["🐮", "🐔", "🐑", "🐶", "🐱"]
        let cityAnimals: Set = ["🐦", "🐭"]

        //TODO
//        houseAnimals.isSubset(of: farmAnimals)
//        // true
//        farmAnimals.isSuperset(of: houseAnimals)
//        // true
//        farmAnimals.isDisjoint(with: cityAnimals)
        // true

        /******************* 4，字典(Dictionary) *******************/
        //(1),创建空字典
        let emptyDic = [Int: String]()

        //(2),字典字面量
        var aDict:[String:Int] = ["One":1,"Two":2,"Three":3]
        var bDict = ["Four":4,"Five":5,"Six":6]
        print(aDict,bDict)
        //(3),访问和修改
        aDict["One"] = 2
//        aDict.updateVlaue(4, forKey:"Three")
//        aDict.removeValue(forKey:"Two")
        print(aDict)

        //(4),迭代
        for (key, value) in aDict{
            print("key:\(key),value:\(value) ")
        }

//        print(aDict.keys(),aDict.values())
    }
}
