//
//  CuteView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 06/01/2017.
//  Copyright © 2017 cdts. All rights reserved.
//

import UIKit

class CuteView: UIView {

    var containerView: UIView
    //气泡上显示数字的label
    var bubbleLabel: UILabel
    //气泡的直径
    var bubbleWidth: CGFloat = 40
    //气泡粘性系数，越大可以拉得越长
    var viscosity: CGFloat = 10
    //气泡颜色
    var bubbleColor: UIColor = UIColor.blackColor() {
        didSet {
            self.frontView.backgroundColor = self.bubbleColor
            backView.backgroundColor = self.bubbleColor;
        }
    }
    //需要隐藏气泡时候可以使用这个属性：self.frontView.hidden = YES;
    var frontView: UIView
    
    var cutePath: UIBezierPath = UIBezierPath()
    var fillColorForCute: UIColor = UIColor.clearColor()
    var animator: UIDynamicAnimator?
    var snap: UISnapBehavior?
    
    var backView: UIView
    var r1: CGFloat
    var r2: CGFloat
    var x1: CGFloat
    var y1: CGFloat
    var x2: CGFloat
    var y2: CGFloat
    var centerDistance: CGFloat = 0
    var cosDigree: CGFloat = 0
    var sinDigree: CGFloat = 0
    
    var pointA: CGPoint //A
    var pointB: CGPoint //B
    var pointD: CGPoint //D
    var pointC: CGPoint //C
    var pointO: CGPoint //O
    var pointP: CGPoint //P
    
    var oldBackViewFrame: CGRect
    var initialPoint: CGPoint
    var oldBackViewCenter: CGPoint
    var shapeLayer: CAShapeLayer
    
    init(point: CGPoint, containerView: UIView) {
        self.initialPoint = point
        self.containerView = containerView
       
        self.shapeLayer = CAShapeLayer()
        self.frontView = UIView(frame: CGRect(x: initialPoint.x, y: initialPoint.y, w: bubbleWidth, h: bubbleWidth))
        
        r2 = self.frontView.bounds.size.width / 2
        self.frontView.layer.cornerRadius = r2
        self.frontView.backgroundColor = self.bubbleColor
        
        backView = UIView(frame: self.frontView.frame)
        r1 = backView.bounds.size.width / 2
        backView.layer.cornerRadius = r1
        backView.backgroundColor = self.bubbleColor;
        
        self.bubbleLabel = UILabel()
        self.bubbleLabel.frame = CGRect(x: 0, y: 0, w: self.frontView.bounds.size.width, h: self.frontView.bounds.size.height);
        self.bubbleLabel.textColor = UIColor.whiteColor()
        self.bubbleLabel.textAlignment = .Center
        
        self.frontView.insertSubview(bubbleLabel, atIndex: 0)
        
        self.containerView.addSubview(backView)
        self.containerView.addSubview(frontView)
        
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = self.frontView.center.x
        y2 = self.frontView.center.y
        
        pointA = CGPointMake(x1-r1, y1)   // A
        pointB = CGPointMake(x1+r1, y1)  // B
        pointD = CGPointMake(x2-r2, y2)  // D
        pointC = CGPointMake(x2+r2, y2)  // C
        pointO = CGPointMake(x1-r1, y1)   // O
        pointP = CGPointMake(x2+r2, y2)  // P
        
        oldBackViewFrame = backView.frame;
        oldBackViewCenter = backView.center;
        
        backView.hidden = true;//为了看到 frontView 的气泡晃动效果，需要暂时隐藏 backView
        
        
        super.init(frame: CGRect(x: point.x, y: point.y, w: bubbleWidth, h: bubbleWidth))
        self.backgroundColor = UIColor.clearColor()
        self.containerView.insertSubview(self, atIndex: 0)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(CuteView.handleDragGesture(_:)))
        self.frontView.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawRect() {
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = self.frontView.center.x
        y2 = self.frontView.center.y
        
        let xx = (x2-x1)*(x2-x1)
        let yy = (y2-y1)*(y2-y1)
        centerDistance = CGFloat(sqrtf(Float(xx + yy)))
        if (centerDistance == 0) {
            cosDigree = 1;
            sinDigree = 0;
        }else{
            cosDigree = (y2-y1)/centerDistance
            sinDigree = (x2-x1)/centerDistance
        }
        
        r1 = oldBackViewFrame.size.width / 2 - centerDistance/self.viscosity
        
        pointA = CGPointMake(x1-r1*cosDigree, y1+r1*sinDigree)  // A
        pointB = CGPointMake(x1+r1*cosDigree, y1-r1*sinDigree)  // B
        pointD = CGPointMake(x2-r2*cosDigree, y2+r2*sinDigree)  // D
        pointC = CGPointMake(x2+r2*cosDigree, y2-r2*sinDigree)  // C
        pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree)
        pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree)
        
        backView.center = oldBackViewCenter;
        backView.bounds = CGRectMake(0, 0, r1*2, r1*2);
        backView.layer.cornerRadius = r1;
        
        cutePath = UIBezierPath()
        cutePath.moveToPoint(pointA)
        cutePath.addQuadCurveToPoint(pointD, controlPoint: pointO)
        cutePath.addLineToPoint(pointC)
        cutePath.addQuadCurveToPoint(pointB, controlPoint: pointP)
        cutePath.moveToPoint(pointA)
        
        if (backView.hidden == false) {
            shapeLayer.path = cutePath.CGPath
            shapeLayer.fillColor = fillColorForCute.CGColor
            self.containerView.layer.insertSublayer(shapeLayer, below: frontView.layer)
        }
    }
    
    ////---- 类似GameCenter的气泡晃动动画 ------
    func addAniamtionLikeGameCenterBubble() {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        pathAnimation.repeatCount = Float.infinity
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pathAnimation.duration = 5.0
        
        let curvedPath = CGPathCreateMutable()
        let circleContainer = CGRectInset(self.frontView.frame, self.frontView.bounds.size.width / 2 - 3, self.frontView.bounds.size.width / 2 - 3)
        CGPathAddEllipseInRect(curvedPath, nil, circleContainer)
        
        pathAnimation.path = curvedPath;
        self.frontView.layer.addAnimation(pathAnimation, forKey: "myCircleAnimation")
        
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1
        scaleX.values = [1.0, 1.1, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.autoreverses = true
        
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.frontView.layer.addAnimation(scaleX, forKey: "scaleXAnimation")
        
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.1, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.autoreverses = true
        scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.frontView.layer.addAnimation(scaleY, forKey: "scaleYAnimation")
    }
    func removeAniamtionLikeGameCenterBubble() {
        frontView.layer.removeAllAnimations()
    }
    
    func handleDragGesture(recognizer: UIPanGestureRecognizer) {
        let dragPoint = recognizer.locationInView(self.containerView)
        
        if (recognizer.state == .Began) {
            backView.hidden = false
            fillColorForCute = self.bubbleColor
            removeAniamtionLikeGameCenterBubble()
        }else if (recognizer.state == .Changed){
            self.frontView.center = dragPoint;
            if (r1 <= 6) {
                fillColorForCute = UIColor.clearColor()
                backView.hidden = true;
                shapeLayer.removeFromSuperlayer()
            }
            drawRect()
        } else if (recognizer.state == .Ended || recognizer.state == .Cancelled || recognizer.state == .Failed){
            
            self.frontView.center = dragPoint;
            backView.hidden = true
            fillColorForCute = UIColor.clearColor()
            shapeLayer.removeFromSuperlayer()
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.backView.frame = self.frontView.frame
                self.oldBackViewCenter = self.frontView.center
                self.oldBackViewFrame = self.frontView.frame
                self.r1 = self.backView.bounds.size.width / 2
                }, completion: { (finished) in
            })
        }

    }
}
