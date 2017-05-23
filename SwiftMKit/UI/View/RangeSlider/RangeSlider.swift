//
//  RangeSlider.swift
//  CustomControl
//
//  Created by chenyh on 16/7/4.
//  Copyright © 2016年 chenyh. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSlider: UIControl {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    //最小值
    var minimumValue : Double = 0.0 {
        didSet{
            updateLayerFrames()
        }
    }
    //最大值
    var maximumValue: Double = 1.0 {
        didSet{
            updateLayerFrames()
        }
    }

    //用户提供的 lower和upper值
    var lowerValue : Double = 0.2 {
        didSet{
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            updateLayerFrames()
        }
    }

    var upperValue : Double = 0.8 {
        didSet{
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            updateLayerFrames()
        }
    }

    /*
     这里有 3 个 layer - trackLayer, lowerThumbLayer, 和 upperThumbLayer - 用来熏染滑块控件的不同组件。thumbWidth 用来布局使用。
     */
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    
    //用来跟踪记录用户的触摸位置
    var previousLocation = CGPoint()
    
    //主轨迹的颜色
    var trackTintColor :UIColor = UIColor(white:0.9,alpha: 1.0) {
        didSet{
          trackLayer.setNeedsDisplay()
        }
    }
    
    //小值轨迹的颜色
    var lowerTrackHighlightTintColor : UIColor = UIColor.clearColor() {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    //大值轨迹的颜色
    var upperTrackHighlightTintColor : UIColor = UIColor.clearColor() {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    //中值轨迹的颜色
    var trackHighlightTintColor : UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    //按钮的颜色
    var thumbTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    //俩按钮边框的颜色
    var thumbBorderColor: UIColor = UIColor.grayColor() {
        didSet {
            lowerThumbLayer.strokeColor = thumbBorderColor
            upperThumbLayer.strokeColor = thumbBorderColor
        }
    }
    
    //小值按钮边框的颜色
    var lowerThumbBorderColor: UIColor = UIColor.grayColor() {
        didSet {
            lowerThumbLayer.strokeColor = lowerThumbBorderColor
        }
    }
    
    //大值按钮边框的颜色
    var upperThumbBorderColor: UIColor = UIColor.grayColor() {
        didSet {
            upperThumbLayer.strokeColor = upperThumbBorderColor
        }
    }
    
    //按钮边框的宽度
    var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            lowerThumbLayer.lineWidth = thumbBorderWidth
            upperThumbLayer.lineWidth = thumbBorderWidth
        }
    }
    
    //按钮和轨迹圆角程度
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }
            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    //按钮宽度
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    /// frame
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    /// layout sub layers
    ///
    /// - Parameter of: layer
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        updateLayerFrames()
    }
    
    //MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLayers()
    }
    
    /// init layers
    func initializeLayers() {
        layer.backgroundColor = UIColor.clearColor().CGColor
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(upperThumbLayer)
    }
    
    //MARK:初始化方法简单的创建了 3 个 layer，并将它们以 children 的身份添加到控件的 root layer 中，然后通过 updateLayerFrames 对这些 layer 的位置进行更新定位! :]
    func updateLayerFrames() -> Void {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x:lowerThumbCenter - thumbWidth/2.0,y:0.0,width:thumbWidth,height:thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x:upperThumbCenter - thumbWidth/2.0,y:0.0,width:thumbWidth,height:thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    //MARK:positionForValue 方法利用一个简单的比例，对控件的最小和最大值的范围做了一个缩放，将值映射到屏幕中确定的一个位置。
    func positionForValue(value: Double) -> Double {
        if (maximumValue == minimumValue) {
            return 0
        }
        return Double(bounds.width - thumbWidth) * (value - minimumValue)/(maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    /*
     那么你该如何来跟踪控件的各种触摸和 release 时间呢？
     
     UIControl 提供了一些方法来跟踪触摸。UIControl 的子类可以 override 这些方法，以实现自己的交互逻辑。
     
     在自定义控件中，我们将 override 3 个 UIControl 关键的方法：beginTrackingWithTouch, continueTrackingWithTouch 和 endTrackingWithTouch。
     
     */
    
    /*当首次触摸控件时,会调用上面的而方法
      代码中,首先将触摸事件的坐标转换到控件的坐标空间,
     然后检查每个thumb,是否触摸位置在其上面.方法中返回的值将决定
     UIControl是否继续跟踪触摸事件
     如果任意一个thumb被highlighthed了,就继续跟踪触摸事件.
     现在,有了初始的触摸事件,我们需要处理用户在屏幕上移动的事件了。
     */
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        previousLocation = touch.locationInView(self)
        
        if lowerValue == maximumValue {
            lowerThumbLayer.highlighted = true
        } else if upperValue == minimumValue {
            upperThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        } else if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    func boundValue(value:Double,toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    /*
     下面我们根据注释，来分析一下 continueTrackingWithTouch 方法都做了些什么：
     
     首先计算出位置增量，这个值决定着用户手指移动的数值。然后根据控件的最大值和最小值，对这个增量做转换。
     根据用户滑动滑块的距离，修正一下 upper 或 lower 值。
     设置 CATransaction 中的 disabledActions。这样可以确保每个 layer 的frame 立即得到更新，并且不会有动画效果。最后，调用 updateLayerFrames 方法将 thumb 移动到正确的位置。
     */
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width-bounds.height)
        previousLocation = location
        
        // 2. Update the values
        
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            
        }else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }
        
        // 3.Update the UI
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        updateLayerFrames()
//        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch!, withEvent event: UIEvent!) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
