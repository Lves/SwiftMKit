//
//  LinkTextView.swift
//  CoreTextDemo
//
//  Created by lixingle on 2018/2/6.
//  Copyright © 2018年 com.lvesli. All rights reserved.
//

import UIKit
import CoreText
import CoreFoundation

protocol LinkTextViewDelegate:class {
    func linkTextView(textView:LinkTextView?, didSelected model:LinkTextModel?)
}
class LinkTextView: UIView {
    var content:String?
    var font:UIFont = UIFont.systemFont(ofSize: 14)
    var textColor:UIColor?
    var lineSpacing:CGFloat = 0
    var alignment:NSTextAlignment = .left
    var linkArray:[LinkTextModel]?
    weak var delegate:LinkTextViewDelegate?
    
    private var ctFrame:CTFrame?
    private lazy var attributedString:NSMutableAttributedString? = {
        let attributedString = self.content?.getAttributedString(withFont: self.font, lineSpacing: self.lineSpacing, alignment:self.alignment,textColor:self.textColor ?? UIColor.black)
         attributedString?.addAttribute(.backgroundColor, value: UIColor.clear, range: NSRange(location: 0, length: attributedString?.length ?? 0))
        attributedString?.addAttribute(.underlineStyle, value: 0, range: NSRange(location: 0, length: attributedString?.length ?? 0))
        if let linkList = self.linkArray{
            for linkModel in linkList{
                if let textColor = linkModel.textColor{
                    attributedString?.addAttribute(.foregroundColor, value: textColor, range: linkModel.range)
                }
                if let font = linkModel.font{
                    attributedString?.addAttribute(.font, value: font, range: linkModel.range)
                }
               
                if linkModel.showUnderline {
                    attributedString?.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: linkModel.range)
                }
            }
        }
        return attributedString
    }()
    //最好在设置完linkArray后取高度
    var heigthForContent:CGFloat {
        get{
            return String.getAttributedStringHeight(matchWidth: bounds.width, attributedString: self.attributedString)
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        //1.0 上下文
        guard let context = UIGraphicsGetCurrentContext(),let attributedString = self.attributedString else {
            return
        }
        //2.0 坐标系上下翻转
        context.textMatrix = .identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1, y: -1)
        //3.0 路径
        let pathRef = CGMutablePath()
        pathRef.addRect(bounds)
        //4.0 frame
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedString.length), pathRef, nil)
        //5.0 绘制
        if let ctFrame = self.ctFrame{
            CTFrameDraw(ctFrame, context)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = ((touches as NSSet).anyObject() as? UITouch)?.location(in: self){
            let index = getTapIndex(point: point)
            if index != -1 ,let linkArray = self.linkArray{
                for linkData in linkArray {
                    if index >= linkData.range.location && index <= linkData.range.location + linkData.range.length {
                        updateBackgroundColor(linkData:linkData)
                    }
                }
            }
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = ((touches as NSSet).anyObject() as? UITouch)?.location(in: self){
            let index = getTapIndex(point: point)
            if index != -1 ,let linkArray = self.linkArray{
                for linkData in linkArray {
                    if index >= linkData.range.location && index <= linkData.range.location + linkData.range.length {//点击超链接
                        self.delegate?.linkTextView(textView: self, didSelected: linkData)
                    }
                }
            }
        }
        if let linkArray = self.linkArray{
            for linkData in linkArray {
                removeBackgroundColor(linkData:linkData)
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let linkArray = self.linkArray{
            for linkData in linkArray {
                removeBackgroundColor(linkData:linkData)
            }
        }
    }
    func getTapIndex(point:CGPoint) -> CFIndex {
        var index = -1
        guard let ctFrame = self.ctFrame else{
            return index
        }
        let lines = CTFrameGetLines(ctFrame) as Array
        let count = lines.count
        guard count > 0 else {
            return index
        }
        
        // 获得每一行的origin坐标
        var origins = [CGPoint].init(repeating: CGPoint.zero, count: count)
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &origins)
        // 翻转坐标系
        var transform = CGAffineTransform(translationX: 0, y: bounds.height)
        transform = transform.scaledBy(x: 1, y: -1)

        for (i, line) in lines.enumerated() {
            let linePoint = origins[i]
            // 获得每一行的CGRect信息
            let lineRect = getLineBounds(line: line as! CTLine, point: linePoint)
            let rect = lineRect.applying(transform)
            if rect.contains(point) {
                // 将点击的坐标转换成相对于当前行的坐标
                let relativePoint = CGPoint(x: point.x - rect.minX, y: point.y - rect.minY)
                // 获得当前点击坐标对应的字符串偏移
                index = CTLineGetStringIndexForPosition(line as! CTLine, relativePoint);
                
            }
        }
        return index
    }
    func getLineBounds(line:CTLine, point:CGPoint) -> CGRect{
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width: CGFloat = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        let height: CGFloat = ascent + descent
        return CGRect(x: point.x, y: point.y - descent, width: width, height: height)
    }
    func updateBackgroundColor(linkData:LinkTextModel)  {
        if let hBgColor = linkData.highlightedBgColor {
            attributedString?.addAttribute(.backgroundColor, value: hBgColor, range: linkData.range)
            setNeedsDisplay()
        }
    }
    func removeBackgroundColor(linkData:LinkTextModel) {
        attributedString?.removeAttribute(.backgroundColor, range: linkData.range)
        setNeedsDisplay()
    }
    

}
