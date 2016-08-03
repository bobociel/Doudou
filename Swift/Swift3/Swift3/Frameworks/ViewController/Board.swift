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
    func drawInContext(_ context: CGContext)
}

class BaseBrush: NSObject, PaintBrush {
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    var strokeWidth: CGFloat!

    func supportContinousDrawing() -> Bool {
        return false
    }

    func drawInContext(_ content: CGContext) {
        assert(false,"need to implement the method in subclass")
    }
}

class PencilBrush: BaseBrush {
    override func supportContinousDrawing() -> Bool {
        return true
    }

    override func drawInContext(_ context: CGContext) {
        if let lastPoint = self.lastPoint{
            context.moveTo(x: lastPoint.x, y: lastPoint.y)
            context.addLineTo(x: endPoint.x, y: endPoint.y)
        }else{
            context.moveTo(x: startPoint.x, y: startPoint.y)
            context.addLineTo(x: endPoint.x, y: endPoint.y)
        }
    }
}

class EraserBrush: PencilBrush{
    override func supportContinousDrawing() -> Bool {
        return true
    }

    override func drawInContext(_ context: CGContext) {
        context.setBlendMode(.clear)
        super.drawInContext(context)
    }
}

enum DrawingState {
    case began, moved, ended
}

class Board: UIImageView {
    private var drawState: DrawingState!
    private var realImage: UIImage?
    var brush: BaseBrush?
    var strokeWidth: CGFloat
    var strokeColor: UIColor
    override init(frame: CGRect) {
        self.strokeWidth = 1
        self.strokeColor = UIColor.white
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        self.strokeWidth = 1
        self.strokeColor = UIColor.white
        super.init(coder: aDecoder)!
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.brush != nil{
            self.brush?.lastPoint = nil
            self.brush?.startPoint = touches.first?.location(in: self)
            self.brush?.endPoint = self.brush?.startPoint
            self.drawState = .began
            self.drawImage()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = touches.first?.location(in: self)
            self.drawState = .moved
            self.drawImage()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = touches.first?.location(in: self)
            self.drawState = .ended
            self.drawImage()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.brush != nil{
            self.brush?.endPoint = nil
        }
    }

    func drawImage(){
        if self.brush != nil{
            UIGraphicsBeginImageContext(self.bounds.size)

            let content = UIGraphicsGetCurrentContext()
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            content?.setLineCap(.round)
            content?.setLineWidth(self.strokeWidth)
            content?.setStrokeColor(self.strokeColor.cgColor)

            if let realImage = self.realImage{
                realImage.draw(in: self.bounds)
            }

            brush?.strokeWidth = self.strokeWidth
            brush?.drawInContext(content!)
            content?.strokePath()

            let  previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawState == .ended  || (brush?.supportContinousDrawing())!{
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
