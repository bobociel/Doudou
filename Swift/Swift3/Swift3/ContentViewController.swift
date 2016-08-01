//
//  ContentViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

enum  ContentType: Int {
    case TheBasics = 0
    case Operation
    case StringAndCharacters
    case CollectionTypes
    case ControlFlow
    case Functions
    case Closures = 6
    case Enumerations
    case ClassAndStrutures
    case Properties
    case Methods
    case Subscripts = 11
    case Inheritance
    case Initialization
    case Deinitialization
    case ARC = 15
    case OptionalChaining = 16
    case ErrorHandling
    case TypeCasting
    case NestedTypes
    case Extensions = 20
    case Protocols
    case Generics
    case AccessControl
    case AdvancedOperators
}

public extension UIImage{
    class func imageWithColor(color: UIColor = UIColor.whiteColor()) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let  content = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(content, color.CGColor)
        CGContextFillRect(content, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class ContentViewController: UIViewController {
    var _contentType: ContentType?
    var contentType: ContentType? { get{return _contentType;} set(type){
        _contentType = type
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor()), forBarMetrics: .Default)
        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if _contentType != nil{
            switch _contentType! {
            case .TheBasics:
                let contentTheBasics = ContentTheBasics.init()
                print(contentTheBasics)
            case .Operation:
                let contentOperators = ContentOperators.init()
                print(contentOperators)
            case .StringAndCharacters:
                let contentString = ContentStringAndCharacters.init()
                print(contentString)
            case .CollectionTypes:
                let contentCollectionTypes = ContentCollectionTypes.init()
                print(contentCollectionTypes)
            case .ControlFlow:
                let contentControlFlow = ContentControlFlow.init()
                print(contentControlFlow)
            case .Functions:
                let contentFunctions = ContentFunction.init()
                print(contentFunctions)
            case .Closures:
                let contentClosures = ContentClosures.init()
                print(contentClosures)
            case .Enumerations:
                let contentEnumrations = ContentEnumerations.init()
                print(contentEnumrations)
            case .ClassAndStrutures:
                let contentClassAndStrutures = ContentClassesAndStructures.init()
                print(contentClassAndStrutures)
            case .Properties:
                let contentProperties = ContentProperties.init()
                print(contentProperties)
            case .Methods:
                let contentMethods = ContentMethods.init()
                print(contentMethods)
            case .Subscripts:
                let contentSubscripts = ContentSubscripts.init()
                print(contentSubscripts)
            case .Inheritance:
                let contentInheritance = ContentInheritance.init()
                print(contentInheritance)
            case .Initialization:
                let contentInitialization = ContentInitialization.init()
                print(contentInitialization)
            case .Deinitialization:
                let contentDeinitialization = ContentDeinitialization.init()
                print(contentDeinitialization)
            case .ARC:
                let contentARC = ContentARC.init()
                print(contentARC)
            case .OptionalChaining:
                let contentOptionalChaining = ContentOptionalChaining.init()
                print(contentOptionalChaining)
            case .ErrorHandling:
                let contentErrorHandling = ContentErrorHandling.init()
                print(contentErrorHandling)
            case .TypeCasting:
                let contentTypeCasting = ContentTypeCasting.init()
                print(contentTypeCasting)
            case .NestedTypes:
                let contentNestedTypes = ContentNestedTypes.init()
                print(contentNestedTypes)
            case .Extensions:
                let contentExtensions = ContentExtensions.init()
                print(contentExtensions)
            case .Protocols:
                let contentProtocols = ContentProtocols.init()
                print(contentProtocols)
            case .Generics:
                let contentGenerics = ContentGenerics.init()
                print(contentGenerics)
            case .AccessControl:
                let contentAccessControl = ContentAccessControl.init()
                print(contentAccessControl)
            case . AdvancedOperators:
                let contentAdvancedOperators = ContentAdvancedOperators.init()
                print(contentAdvancedOperators)
            default:
                print("default end")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
