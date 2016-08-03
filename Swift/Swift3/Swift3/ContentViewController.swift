//
//  ContentViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

enum  ContentType: Int {
    case theBasics = 0
    case operation
    case stringAndCharacters
    case collectionTypes
    case controlFlow
    case functions
    case closures = 6
    case enumerations
    case classAndStrutures
    case properties
    case methods
    case subscripts = 11
    case inheritance
    case initialization
    case deinitialization
    case arc = 15
    case optionalChaining = 16
    case errorHandling
    case typeCasting
    case nestedTypes
    case extensions = 20
    case protocols
    case generics
    case accessControl
    case advancedOperators
}

public extension UIImage{
    class func imageWithColor(_ color: UIColor = UIColor.white) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let  content = UIGraphicsGetCurrentContext()
        content?.setFillColor(color.cgColor)
        content?.fill(rect)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBarHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor()), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
//        self.navigationController?.navigationBar.shadowImage = UIImage.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if _contentType != nil{
            switch _contentType! {
            case .theBasics:
                let contentTheBasics = ContentTheBasics.init()
                print(contentTheBasics)
            case .operation:
                let contentOperators = ContentOperators.init()
                print(contentOperators)
            case .stringAndCharacters:
                let contentString = ContentStringAndCharacters.init()
                print(contentString)
            case .collectionTypes:
                let contentCollectionTypes = ContentCollectionTypes.init()
                print(contentCollectionTypes)
            case .controlFlow:
                let contentControlFlow = ContentControlFlow.init()
                print(contentControlFlow)
            case .functions:
                let contentFunctions = ContentFunction.init()
                print(contentFunctions)
            case .closures:
                let contentClosures = ContentClosures.init()
                print(contentClosures)
            case .enumerations:
                let contentEnumrations = ContentEnumerations.init()
                print(contentEnumrations)
            case .classAndStrutures:
                let contentClassAndStrutures = ContentClassesAndStructures.init()
                print(contentClassAndStrutures)
            case .properties:
                let contentProperties = ContentProperties.init()
                print(contentProperties)
            case .methods:
                let contentMethods = ContentMethods.init()
                print(contentMethods)
            case .subscripts:
                let contentSubscripts = ContentSubscripts.init()
                print(contentSubscripts)
            case .inheritance:
                let contentInheritance = ContentInheritance.init()
                print(contentInheritance)
            case .initialization:
                let contentInitialization = ContentInitialization.init()
                print(contentInitialization)
            case .deinitialization:
                let contentDeinitialization = ContentDeinitialization.init()
                print(contentDeinitialization)
            case .arc:
                let contentARC = ContentARC.init()
                print(contentARC)
            case .optionalChaining:
                let contentOptionalChaining = ContentOptionalChaining.init()
                print(contentOptionalChaining)
            case .errorHandling:
                let contentErrorHandling = ContentErrorHandling.init()
                print(contentErrorHandling)
            case .typeCasting:
                let contentTypeCasting = ContentTypeCasting.init()
                print(contentTypeCasting)
            case .nestedTypes:
                let contentNestedTypes = ContentNestedTypes.init()
                print(contentNestedTypes)
            case .extensions:
                let contentExtensions = ContentExtensions.init()
                print(contentExtensions)
            case .protocols:
                let contentProtocols = ContentProtocols.init()
                print(contentProtocols)
            case .generics:
                let contentGenerics = ContentGenerics.init()
                print(contentGenerics)
            case .accessControl:
                let contentAccessControl = ContentAccessControl.init()
                print(contentAccessControl)
            case . advancedOperators:
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
