//
//  Board.swift
//  Swift3
//
//  Created by wangxiaobo on 16/8/2.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit
import CoreGraphics

protocol PaintBrush {
    func supportContinousDrawing() -> Bool
    func drawInContext(context: CGContextRef)
}

class BaseBrush: NSObject, PaintBrush {
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    var strokeWidth: CGFloat!

    func supportContinousDrawing() -> Bool {
        return false
    }

    func drawInContext(content: CGContextRef) {
        assert(false,"need to implement the method in subclass")
    }
}

class PencilBrush: BaseBrush {
    override func supportContinousDrawing() -> Bool {
        return true
    }

    override func drawInContext(context: CGContextRef) {
        if let lastPoint = self.lastPoint{
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        }else{
            CGContextMoveToPoint(context, startPoint.x, startPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        }
    }
}

class EraserBrush: PencilBrush{
    override func supportContinousDrawing() -> Bool {
        return true
    }

    override func drawInContext(context: CGContextRef) {
        CGContextSetBlendMode(context, .Clear)
        super.drawInContext(context)
    }
}

enum DrawingState {
    case Began, Moved, Ended
}

class Board: UIImageView {
    private var drawState: DrawingState!
    private var realImage: UIImage?
    var brush: BaseBrush?
    var strokeWidth: CGFloat
    var strokeColor: UIColor
    override init(frame: CGRect) {
        self.strokeWidth = 1
        self.strokeColor = UIColor.whiteColor()
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        self.strokeWidth = 1
        self.strokeColor = UIColor.whiteColor()
        super.init(coder: aDecoder)!
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.brush != nil{
            self.brush?.lastPoint = nil
            self.brush?.startPoint = touches.first?.locationInView(self)
            self.brush?.endPoint = self.brush?.startPoint
            self.drawState = .Began
            self.drawImage()
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = touches.first?.locationInView(self)
            self.drawState = .Moved
            self.drawImage()
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = touches.first?.locationInView(self)
            self.drawState = .Ended
            self.drawImage()
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = nil
        }
    }

    func drawImage(){
        if self.brush != nil{
            UIGraphicsBeginImageContext(self.bounds.size)

            let content = UIGraphicsGetCurrentContext()
            UIColor.clearColor().setFill()
            UIRectFill(self.bounds)
            CGContextSetLineCap(content, .Round)
            CGContextSetLineWidth(content, self.strokeWidth)
            CGContextSetStrokeColorWithColor(content, self.strokeColor.CGColor)

            if let realImage = self.realImage{
                realImage.drawInRect(self.bounds)
            }

            brush?.strokeWidth = self.strokeWidth
            brush?.drawInContext(content!)
            CGContextStrokePath(content)

            let  previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawState == .Ended  || (brush?.supportContinousDrawing())!{
                self.realImage = previewImage
            }
            UIGraphicsEndImageContext()

            self.image = previewImage
            brush?.lastPoint = brush?.endPoint
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
