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
    var bubbleColor: UIColor = UIColor.black {
        didSet {
            self.frontView.backgroundColor = self.bubbleColor
            backView.backgroundColor = self.bubbleColor;
        }
    }
    //需要隐藏气泡时候可以使用这个属性：self.frontView.hidden = YES;
    var frontView: UIView
    
    var cutePath: UIBezierPath = UIBezierPath()
    var fillColorForCute: UIColor = UIColor.clear
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
        self.bubbleLabel.textColor = UIColor.white
        self.bubbleLabel.textAlignment = .center
        
        self.frontView.insertSubview(bubbleLabel, at: 0)
        
        self.containerView.addSubview(backView)
        self.containerView.addSubview(frontView)
        
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = self.frontView.center.x
        y2 = self.frontView.center.y
        
        pointA = CGPoint(x: x1-r1, y: y1)   // A
        pointB = CGPoint(x: x1+r1, y: y1)  // B
        pointD = CGPoint(x: x2-r2, y: y2)  // D
        pointC = CGPoint(x: x2+r2, y: y2)  // C
        pointO = CGPoint(x: x1-r1, y: y1)   // O
        pointP = CGPoint(x: x2+r2, y: y2)  // P
        
        oldBackViewFrame = backView.frame;
        oldBackViewCenter = backView.center;
        
        backView.isHidden = true;//为了看到 frontView 的气泡晃动效果，需要暂时隐藏 backView
        
        
        super.init(frame: CGRect(x: point.x, y: point.y, w: bubbleWidth, h: bubbleWidth))
        self.backgroundColor = UIColor.clear
        self.containerView.insertSubview(self, at: 0)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture(_:)))
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
        
        pointA = CGPoint(x: x1-r1*cosDigree, y: y1+r1*sinDigree)  // A
        pointB = CGPoint(x: x1+r1*cosDigree, y: y1-r1*sinDigree)  // B
        pointD = CGPoint(x: x2-r2*cosDigree, y: y2+r2*sinDigree)  // D
        pointC = CGPoint(x: x2+r2*cosDigree, y: y2-r2*sinDigree)  // C
        pointO = CGPoint(x: pointA.x + (centerDistance / 2)*sinDigree, y: pointA.y + (centerDistance / 2)*cosDigree)
        pointP = CGPoint(x: pointB.x + (centerDistance / 2)*sinDigree, y: pointB.y + (centerDistance / 2)*cosDigree)
        
        backView.center = oldBackViewCenter;
        backView.bounds = CGRect(x: 0, y: 0, w: r1*2, h: r1*2);
        backView.layer.cornerRadius = r1;
        
        cutePath = UIBezierPath()
        cutePath.move(to: pointA)
        cutePath.addQuadCurve(to: pointD, controlPoint: pointO)
        cutePath.addLine(to: pointC)
        cutePath.addQuadCurve(to: pointB, controlPoint: pointP)
        cutePath.move(to: pointA)
        
        if (backView.isHidden == false) {
            shapeLayer.path = cutePath.cgPath
            shapeLayer.fillColor = fillColorForCute.cgColor
            self.containerView.layer.insertSublayer(shapeLayer, below: frontView.layer)
        }
    }
    
    ////---- 类似GameCenter的气泡晃动动画 ------
    func addAniamtionLikeGameCenterBubble() {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.repeatCount = Float.infinity
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        pathAnimation.duration = 5.0
        
        let curvedPath = CGMutablePath()
        let circleContainer = self.frontView.frame.insetBy(dx: self.frontView.bounds.size.width / 2 - 3, dy: self.frontView.bounds.size.width / 2 - 3)
        curvedPath.addEllipse(in: circleContainer)
        
        pathAnimation.path = curvedPath;
        self.frontView.layer.add(pathAnimation, forKey: "myCircleAnimation")
        
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1
        scaleX.values = [1.0, 1.1, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.autoreverses = true
        
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.frontView.layer.add(scaleX, forKey: "scaleXAnimation")
        
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.1, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.autoreverses = true
        scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.frontView.layer.add(scaleY, forKey: "scaleYAnimation")
    }
    func removeAniamtionLikeGameCenterBubble() {
        frontView.layer.removeAllAnimations()
    }
    
    func handleDragGesture(_ recognizer: UIPanGestureRecognizer) {
        let dragPoint = recognizer.location(in: self.containerView)
        
        if (recognizer.state == .began) {
            backView.isHidden = false
            fillColorForCute = self.bubbleColor
            removeAniamtionLikeGameCenterBubble()
        }else if (recognizer.state == .changed){
            self.frontView.center = dragPoint;
            if (r1 <= 6) {
                fillColorForCute = UIColor.clear
                backView.isHidden = true;
                shapeLayer.removeFromSuperlayer()
            }
            drawRect()
        } else if (recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed){
            
            self.frontView.center = dragPoint;
            backView.isHidden = true
            fillColorForCute = UIColor.clear
            shapeLayer.removeFromSuperlayer()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.backView.frame = self.frontView.frame
                self.oldBackViewCenter = self.frontView.center
                self.oldBackViewFrame = self.frontView.frame
                self.r1 = self.backView.bounds.size.width / 2
                }, completion: { (finished) in
            })
        }

    }
}
