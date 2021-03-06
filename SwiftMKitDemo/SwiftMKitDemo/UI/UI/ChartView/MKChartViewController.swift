////
////  MKUIChartViewController.swift
////  SwiftMKitDemo
////
////  Created by lixingle on 5/10/16.
////  Copyright © 2016 cdts. All rights reserved.
////
//
//import UIKit
//import Charts
//import PulsingHalo
//
//
///*
//一.显示高亮点
// 1.设置图形是否开启高亮圆点功能： 
//    lineChart.showAllHighlightCircles = true              //是否显示高亮Circle
// 2.设置数据源DataSet的圆点样式：
//    set2.setCircleColor(UIColor.orangeColor())            //圆点圆环颜色
//    set2.circleHoleColor = UIColor.orangeColor()          //圆点圆心颜色
// 
//二、部分填充区域
// 2.设置数据源DataSet属性，yValues1Lower:[ChartDataEntry]() 是底部线的数组
//    set1.drawRangeFilledEnabled = true    //是否区域填充
//    set1.fillLowerYValues = yValues1Lower ///设置底部fill线
// 
//三、 自定义ChartMarker
// 1. 两条线的弹框使用 MKMultipleChartMarker，其中有一个参数是数据源Data
//    let marker =  MKMultipleChartMarker(font: UIFont.systemFontOfSize(12),data: self.lineChart1Data!)
// 2. 单条线的弹框使用 MKChartMarker
// 
//四、 柱状图两种数值变化Animation
// 1. 设置数据源DataSet属性，animationVals是动画后的数组
//    set1.animationVals = yResultValues
// 2.点击按钮开始动画
//     self.barChartView.customAnimating = true
//     self.barChartView.isCustomAnimateBack = !self.barChartView.isCustomAnimateBack
//     self.barChartView.animate(yAxisDuration: 3.0)
//五、设置高亮点形状
//    set0.form = .Square //数据点形状
// 
//六、默认高亮点
// 0. 前提是 lineChart.showAllHighlightCircles = true   //是否显示高亮Circle
// 1.controller中添加一个存储属性 defaultHighlight:ChartHighlight? 存储默认高亮点
// 2.添加数据源时，设置默认高亮点
//     defaultHighlight = ChartHighlight(xIndex: (self.lineChart1Data?.xValCount)! - 1, dataSetIndex: 1)
//     self.lineChart.indicesDefaultToHighlight = [defaultHighlight!]
// 3. 在代理中保存最新的默认高亮点
//     func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
//        defaultHighlight = highlight
//     }
//     func chartValueNothingSelected(chartView: ChartViewBase) {
//         if defaultHighlight == nil {
//             let height = ChartHighlight(xIndex: (chartView.data?.xValCount)!-1, dataSetIndex: 1)
//             chartView.indicesDefaultToHighlight = [height]
//         }else {
//             chartView.indicesDefaultToHighlight = [defaultHighlight!]
//         }
//     }
//*/
//
//
//class MKChartViewController: BaseViewController,ChartViewDelegate {
//    let screenSize = UIScreen.main.bounds.size
//    let kBlackColor  = NSUIColor(red: 46/255.0, green: 52/255.0, blue: 72/255.0, alpha: 1.0)
//    var lineChart:LineChartView!
//    var lineChart2:LineChartView!
//    var barChartView:BarChartView!
//    var lineProfit:MerakProfitLineChart!
//    var lineChart1Data:ChartData?
//    
//    
//    var defaultHighlight:ChartHighlight?
//    var halo:PulsingHaloLayer?
//    
//    
//    override func setupUI() {
//        super.setupUI()
//        //1.0 折线图
//        self.buildLineChartUI()
//        //2.0 折线图2
//        self.buildLineChart2UI()
//        
//        let button = UIButton(frame: CGRect(x: 100, y: 900, width: 100, height: 44))
//        button.setTitle("Animate", for: UIControlState())
//        
//        button.setTitleColor(UIColor.blue, for: UIControlState())
//        
//        
//
//        
//        button.rac_signalForControlEvents(.TouchDown).toSignalProducer().startWithNext { [unowned self] _ in
////            self.barChartView.customAnimating = true
////            self.barChartView.isCustomAnimateBack = false
//            self.barChartView.animate(yAxisDuration: 10.0)
//            
//            self.halo = PulsingHaloLayer()
//            self.halo!.position = button.center
//            self.halo!.radius = 80.0
//            self.halo!.haloLayerNumber = 4
//            self.halo!.backgroundColor = UIColor.blueColor().CGColor
//            button.superview?.layer.insertSublayer(self.halo!, above: button.layer)
//        
//            self.halo!.start()
//            
//        }
//        
//        button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
////            self.barChartView.customAnimating = true
////            self.barChartView.isCustomAnimateBack = true
//            self.barChartView.animate(yAxisDuration: 10.0)
//            self.halo!.removeFromSuperlayer()
//        }
//
//        
//        //3.0 柱状图
//        self.buildBarChartUI()
//        
//        self.buildProfitLine()
//        
//        //4.0 ScrollView
//        let scrollView = UIScrollView()
//        scrollView.contentSize = CGSize(width: screenSize.width, height: 1200)
//        self.view.addSubview(scrollView)
//        scrollView.snp_makeConstraints { (make) in
//            make.edges.equalTo(self.view)
//        }
//        
//        scrollView.addSubview(self.lineChart)
//        scrollView.addSubview(self.lineChart2)
//        scrollView.addSubview(button)
//        scrollView.addSubview(self.barChartView)
//        
//        scrollView.addSubview(self.lineProfit)
//        
//       
//        
//        
//    }
//    //MARK: 折线图
//    func buildLineChartUI() {
//        //获得数据
//        self.buildLineData1()
//        
//        
//        lineChart = LineChartView(frame: CGRect(x: 0, y: 0,width: screenSize.width , height: 400))
//        lineChart.backgroundColor = kBlackColor
//        lineChart.alpha = 0.8
//        lineChart.pinchZoomEnabled = false
//        lineChart.descriptionText = ""
////        lineChart.showAllHighlightCircles = true   //是否显示高亮Circle
//
//        
//        let xAxis = lineChart.xAxis
//        xAxis.labelPosition = .Bottom;                  //x轴线位置
//        xAxis.labelFont = UIFont.systemFontOfSize(10);
//        xAxis.drawGridLinesEnabled = false              //是否显示x轴网格线
//        xAxis.labelTextColor = UIColor.whiteColor()     //label颜色
//        xAxis.axisLineWidth = 0                         //线宽度
//        xAxis.setLabelsToSkip(11)                       //xlabel步长
//        
//        
//        
//        let percentFormatter = NumberFormatter()
//        percentFormatter.positiveSuffix = "%"
//        percentFormatter.negativeSuffix = "%"
//        lineChart.leftAxis.valueFormatter = percentFormatter//y轴显示格式化
//        lineChart.leftAxis.axisLineWidth = 0                //左侧线宽度
//        lineChart.leftAxis.labelTextColor = UIColor.whiteColor()  //label颜色
//        
//        lineChart.rightAxis.enabled = false                 //是否显示右侧轴线
//        lineChart.dragEnabled = true                        //是否可以滑动
//        lineChart.drawGridBackgroundEnabled = false         //背景色
//        lineChart.doubleTapToZoomEnabled = false            //双击缩放
//        lineChart.legend.form = .Circle                     //图例样式
//        lineChart.legend.position = .AboveChartCenter       //图例位置
//        lineChart.legend.textColor = UIColor.whiteColor()   //图例label颜色
//        
//        let marker =  MKMultipleChartMarker(font: UIFont.systemFont(ofSize: 12),data: self.lineChart1Data!)
//        marker.image = UIImage(named: "BubblePopRight")
//        marker.leftImage = UIImage(named: "BubblePopLeft")
////        lineChart.marker = marker
//        ///默认选中
//        defaultHighlight = ChartHighlight(xIndex: (self.lineChart1Data?.xValCount)! - 1, dataSetIndex: 1)
////        self.lineChart.indicesDefaultToHighlight = [defaultHighlight!]
//        
//        self.lineChart.delegate = self
//        //设置数据
//        self.lineChart.data = self.lineChart1Data
//
//
//        
//    }
//    
//    func buildLineData1(){
//        var xValues = [String]()
//        for index in 0...108 {
//            if index%12 == 0 {
//                 xValues.append("\(2007+index/12)")
//            }else{
//                xValues.append("\(2007+index/12)/\(index%12)")
//            }
//            
//        }
//        
//        //Line 0
//        var yValues0 = [ChartDataEntry]()
//        for yIndex in  0...108 {
//            let flotVa =  -(Double(arc4random()%20))
//            yValues0.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        let set0 = LineChartDataSet(yVals: yValues0, label: "沪深300")
//        set0.fillColor = UIColor.purpleColor()
//        set0.drawFilledEnabled = true
//        set0.drawCirclesEnabled = false                       //是否显示圆点
////        set0.highlightImage = NSUIImage(named: "firstInvest_otherprofit_dot")!
//        set0.setCircleColor(ChartColorTemplates.colorFromString("#afff0000"))            //圆环颜色
//        set0.circleHoleColor = UIColor.purpleColor()          //圆点圆心颜色
////        set0.form = .Square                                   //数据点形状
//        set0.circleRadius = 10.0                               //圆半径
//        set0.lineWidth = 0
//        set0.setColor(UIColor.purpleColor())
//        set0.drawValuesEnabled = false  //是否显示数字
//        set0.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
//        set0.fillFormatter = ChartLvesFillFormatter()   //李兴乐
//        set0.highlightEnabled = false
//        //Line2
//        var anotherYValues = [ChartDataEntry]()
//        for yIndex in  0...108 {
//            let flotVa = Double(arc4random()%20) + 20.0
//            anotherYValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//
//        let set2 = LineChartDataSet(yVals: anotherYValues, label: "资产组合")
//        
//        set2.drawFilledEnabled = true
//        set2.setColor(UIColor.orangeColor())
//        set2.drawCirclesEnabled = false
////        set2.highlightImage = NSUIImage(named: "firstInvest_otherprofit_dot")!
//        set2.setCircleColor(ChartColorTemplates.colorFromString("#afff0000"))            //圆点圆环颜色
//        set2.circleHoleColor = UIColor.orangeColor()          //圆点圆心颜色
//        set2.circleRadius = 10.0                               //圆半径
//        set2.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
//        set2.fillColor = UIColor.orangeColor()
//        set2.fillFormatter = ChartLvesFillFormatter()   //李兴乐
//        
////        let gradientColors = [
////                              ChartColorTemplates.colorFromString("#00000000").CGColor,UIColor.orangeColor().CGColor]
////        let gradient = CGGradientCreateWithColors(nil, gradientColors, nil)
////        set2.fill = ChartFill(linearGradient: gradient!, angle: 100.0)
//        set2.fillAlpha = 0.7
//        
//
//        
//        
//        //格式化数据
//        let percentFormatter = NumberFormatter()
//        percentFormatter.positiveSuffix = "%"
//        percentFormatter.negativeSuffix = "%"
//        
//        let lineData =  LineChartData(xVals: xValues, dataSets: [set2,set0])
//        lineData.setValueFormatter(percentFormatter);
//        
//        self.lineChart1Data = lineData
//    }
//    //MARK: 代理
//    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
//        if chartView == lineChart {
//            let dataset = chartView.data?.dataSets[1]
//            dataset?.highlightEnabled = true
//            
//            defaultHighlight = highlight //更新最后高亮
//        }
//        
//    }
//    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//        
//        if chartView == lineChart {
//            let dataset = chartView.data?.dataSets[1]
//            dataset?.highlightEnabled = false
//            
//            //设置默认高亮
////            if defaultHighlight == nil {
////                let height = ChartHighlight(xIndex: (chartView.data?.xValCount)!-1, dataSetIndex: 1)
////                chartView.indicesDefaultToHighlight = [height]
////            }else {
////                chartView.indicesDefaultToHighlight = [defaultHighlight!]
////            }
//        }
//    }
//
//    
//    //MARK: 折线图2
//    
//    func buildLineChart2UI() {
//        lineChart2 = LineChartView(frame: CGRect(x: 0, y: 420,width: screenSize.width , height: 200))
//        lineChart2.backgroundColor = kBlackColor
//        lineChart2.alpha = 0.8
////        lineChart2.showAllHighlightCircles = true   //是否显示高亮Circle
//        
//        let percentFormatter = NumberFormatter()
//        percentFormatter.positiveSuffix = "%"
//        percentFormatter.negativeSuffix = "%"
//        lineChart2.leftAxis.valueFormatter = percentFormatter  //y轴显示格式化
//        
//        
//        let xAxis = lineChart2.xAxis
//        xAxis.labelPosition = .Bottom;          //x轴线位置
//        xAxis.labelFont = UIFont.systemFontOfSize(10);
//        xAxis.drawGridLinesEnabled = false       // 是否显示x轴网格线
//        xAxis.spaceBetweenLabels = 1
//        xAxis.axisLineWidth = 0                  //线宽度
//        xAxis.drawGridLinesEnabled = false       //是否显示有网格线
//        
//        lineChart2.leftAxis.axisLineWidth = 0          //左侧线宽度
//        lineChart2.leftAxis.drawGridLinesEnabled = false
//        
//       
//        
//        lineChart2.rightAxis.enabled = false           //是否显示右侧轴线
//        lineChart2.dragEnabled = true                  //是否可以滑动
//        lineChart2.drawGridBackgroundEnabled = false   //背景色
//        lineChart2.doubleTapToZoomEnabled = false      //双击缩放
//        lineChart2.legend.enabled = true               //是否显示说明
//        lineChart2.descriptionText = ""
//        lineChart2.legend.position = .AboveChartCenter  //图例位置
//        
//
//        let marker =  MKChartMarker( font: UIFont.systemFont(ofSize: 12))
//        marker.image = UIImage(named: "BubblePopRight")
//        marker.leftImage = UIImage(named: "BubblePopLeft")
////        lineChart2.marker = marker
//        
//        
//        self.lineChart2.delegate = self
//        self.setLine2Data()
//        
//        
//    }
//    
//    func setLine2Data(){
//        
//        //设置x轴
//        var xValues = [String]()
//        for index in 0...10 {
//            xValues.append("\(2005 + index)")
//        }
//        
//        
//        //格式化数据
//        let percentFormatter = NumberFormatter()
//        percentFormatter.positiveSuffix = "%"
//        percentFormatter.negativeSuffix = "%"
//        
//        
//        /*
//        //Line1
//        var yValues1 = [ChartDataEntry]()
//        for yIndex in  0...10 {
//            let flotVa = Double(Float(yIndex) * 30)  + (Double) (arc4random()%50)
//            yValues1.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        //底部填充线
//        var yValues1Lower = [ChartDataEntry]()
//        for yIndex in  0...10 {
//            
//            let flotVa = Double(Float(yIndex) * 10) - (Double) (arc4random()%20)
//            yValues1Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        let set1 = LineChartDataSet(yVals: yValues1, label: "DataSet 1")
//        set1.drawFilledEnabled = true
//        
//        set1.fillColor = UIColor.orangeColor()
//        set1.setColor(UIColor.orangeColor())
//        
//        set1.drawCirclesEnabled = false
//        set1.setCircleColor(ChartColorTemplates.colorFromString("#afff0000"))            //圆点圆环颜色
//        set1.circleHoleColor = UIColor.orangeColor()          //圆点圆心颜色
//        set1.circleRadius = 10.0                               //圆半径
//        set1.highlightEnabled = true   //是否可以高亮
//        
//        
//        set1.lineWidth = 0
//        set1.drawValuesEnabled = false  //是否显示数字
//        
//        set1.drawRangeFilledEnabled = true    //是否区域填充
//        set1.fillLowerYValues = yValues1Lower ///设置底部fill线
//        
//        set1.drawCubicEnabled = true          //是否显示曲线形式
//        set1.valueFormatter = percentFormatter
//        
//        */
//        //Line 2
//        var yValues2 = [ChartDataEntry]()
//        for yIndex in  0...10 {
//            let flotVa = Double(Float(yIndex) * 35) + (Double) (arc4random()%20)
//            yValues2.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        //底部填充线
//        var yValues2Lower = [ChartDataEntry]()
//        for yIndex in  0...10 {
//            
//            let flotVa = Double(Float(yIndex) * 5) - (Double) (arc4random()%10)
//            yValues2Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        
//        let set2 = LineChartDataSet(yVals: yValues2, label: "DataSet 2")
//        set2.fillColor = UIColor.purpleColor()
//        set2.fillAlpha = 1.0
//        set2.setColor(UIColor.clearColor())
//        set2.drawFilledEnabled = true
//        
//        set2.drawCirclesEnabled = false
//        set2.setCircleColor(ChartColorTemplates.colorFromString("#afff0000"))            //圆点圆环颜色
//        set2.circleHoleColor = UIColor.orangeColor()          //圆点圆心颜色
//        set2.circleRadius = 10.0                               //圆半径
////        set2.highlightImage = NSUIImage(named: "firstInvest_xjProfit_dot")!
////        set2.lowerHighlightImage = NSUIImage(named: "firstInvest_xiongProfit_dot")!
//        
//        set2.highlightEnabled = true   //是否可以高亮
////        set2.drawRangeFilledEnabled = true
////        set2.fillLowerYValues = yValues2Lower
//        
//        set2.lineWidth = 0.2
//        set2.drawValuesEnabled = false  //是否显示数字
//        set2.drawCubicEnabled = true  //是否显示曲线形式
//        set2.valueFormatter = percentFormatter
//        set2.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
//       
//
//        //Line3 
//        
//        var yValuesMiddle = [ChartDataEntry]()
//        for yIndex in  0...10 {
//            let flotVa = Double(Float(yIndex) * 20)
//            yValuesMiddle.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        let setMiddle = LineChartDataSet(yVals: yValuesMiddle, label: "DataSet Middle")
//        setMiddle.drawFilledEnabled = false
//        setMiddle.drawCirclesEnabled = false
//        setMiddle.setColor(UIColor.orangeColor())
//        setMiddle.lineWidth = 1
//        
////        setMiddle.highlightImage = NSUIImage(named: "firstInvest_otherprofit_dot")!
//        setMiddle.setCircleColor(ChartColorTemplates.colorFromString("#affff000"))            //圆点圆环颜色
//        setMiddle.circleHoleColor = UIColor.orangeColor()          //圆点圆心颜色
//        setMiddle.circleRadius = 10.0                               //圆半径
//
//        
//        setMiddle.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
//        setMiddle.drawCubicEnabled = true  //是否显示曲线形式
//        setMiddle.valueFormatter = percentFormatter
//        setMiddle.drawValuesEnabled = false
//        
//
//        
//        let lineData =  LineChartData(xVals: xValues, dataSets: [set2,setMiddle])
//        lineData.setValueFormatter(percentFormatter);
//
//        self.lineChart2!.data = lineData
//    }
//    
//    
//    //MARK: 柱状图
//    func buildBarChartUI()  {
//        
//       
//        
//        
//        barChartView = BarChartView(frame: CGRect(x: 0, y: 624,width: screenSize.width , height: 200))
//        self.barChartView.delegate = self
//        self.barChartView.doubleTapToZoomEnabled = false      //双击缩放
//        self.barChartView.xAxis.drawGridLinesEnabled = false
//        
//
//        
//        self.barChartView.rightAxis.enabled = false
//        self.barChartView.xAxis.enabled = false
//
//        self.barChartView.descriptionText = ""
//        
//        let percentFormatter = NumberFormatter()
//        percentFormatter.positiveSuffix = "%"
//        percentFormatter.negativeSuffix = "%"
//        self.barChartView.leftAxis.valueFormatter = percentFormatter
//        self.barChartView.leftAxis.labelPosition = .InsideChart
//        self.barChartView.leftAxis.drawGridLinesEnabled = false
//        self.barChartView.leftAxis.axisLineWidth = 0
//        
//        self.setChartData()
//    }
//    
//    
//    func setChartData(){
//        
//        var xVals = [String]()
//        for xIndex in 1...10 {
//            let xValue = "\(xIndex)"
//            xVals.append(xValue)
//        }
//        
//        
//        var yVals1 = [BarChartDataEntry]()
//        
//        for yIndex in 1...10 {
//            let val = (Double) (arc4random()%100);
//
//            let dataEntity = BarChartDataEntry(value: val, xIndex: yIndex)
//            yVals1.append(dataEntity)
//        }
//        
//        //底部填充线
//        var yResultValues = [ChartDataEntry]()
//        for yIndex in  1...10 {
//            let flotVa = (Double) (arc4random()%100);
//            yResultValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
//        }
//        
//        let set1 = BarChartDataSet(yVals: yVals1, label: "Compnay A")
////        set1.animationVals = yResultValues
//        set1.drawValuesEnabled = false
//        set1.setColors([UIColor.redColor(),
//            UIColor.blueColor(),
//            UIColor.orangeColor(),
//            UIColor.blackColor(),
//            UIColor.grayColor(),
//            UIColor.darkGrayColor(),
//            UIColor.purpleColor(),
//            UIColor.yellowColor(),
//            UIColor.greenColor(),
//            UIColor.brownColor()], alpha: 1.0)
//
//        let barChartData = BarChartData(xVals: xVals, dataSets: [set1])
//        self.barChartView.data = barChartData
//        
//        self.barChartView.animate(yAxisDuration: 3.0)
//        
//    }
//    
//    func buildProfitLine()  {
//        lineProfit = MerakProfitLineChart(frame: CGRect(x: 0, y: 854, width: screenSize.width, height: 300))
//        lineProfit.backgroundColor = kBlackColor
//        
//        var xValues = [String]()
//        var yValues = [ChartDataEntry]()
//        
//        
//        for index in 0...2 {
//            
//            xValues.append("\(2007+index/12).\(index%12).12")
//        }
//        for yIndex in  0...2 {
//            yValues.append(ChartDataEntry(value: 0.00, xIndex: yIndex))
//        }
//        lineProfit!.leftAxis.axisMinValue = -100
//        lineProfit!.leftAxis.axisMaxValue = 200
//            //            lineChartProfit.xAxis.setLabelsToSkip(11)
//        
//        //设置默认高亮
//        let highlight = ChartHighlight(xIndex: xValues.count - 1, dataSetIndex: 1)
//        defaultHighlight = highlight
////        lineProfit?.indicesDefaultToHighlight = [highlight]
//        lineProfit?.setLineData(xValues, yValues: yValues, label: "")
//    }
//}
//
//
//
//
//
//
//
//
////MARK: 自定义Marker
//class MKChartMarker: ChartMarker {
//    
//    var font: UIFont?
//    fileprivate var labelns: NSString?
//    fileprivate var _labelSize: CGSize = CGSize()
//    fileprivate var _size: CGSize = CGSize()
//    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
//    fileprivate var _drawAttributes = [String : AnyObject]()
//    
//    
//    
//    var data: ChartData?
//    
//    
//    var leftImage: NSUIImage?
//    
//    init(font: UIFont)
//    {
//        super.init()
//        
//        self.font = font
//        
//        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
//        _paragraphStyle?.alignment = .center
//    }
//    
//    
//    override func draw(context: CGContext, point: CGPoint)
//    {
//        
//        
//        let offset = self.offsetForDrawingAtPos(point)
//        var size = _labelSize
//        
//        size = CGSize(width: size.width+20, height: 40.0)
//        
//        UIGraphicsPushContext(context)
//        var rect = CGRect.zero
//        if point.x > UIScreen.main.bounds.size.width/2.0 {
//            rect = CGRect(x: point.x + offset.x - size.width, y: point.y - size.height/2.0, width: size.width, height: size.height)
//            leftImage!.drawInRect(rect)
//            rect.origin.x -= 2.0
//            
//        }else{
//            rect = CGRect(x: point.x + offset.x, y: point.y - size.height/2.0, width: size.width, height: size.height)
//            image!.drawInRect(rect)
//            rect.origin.x += 2.0
//        }
//        
//        
//        rect.origin.y += (size.height - self.font!.pointSize)/2.0
//        labelns?.draw(in: rect, withAttributes: _drawAttributes)
//        
//        
//        UIGraphicsPopContext()
//        
//    }
//    
//    override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
//    {
//        let label = entry.value.description
//        labelns = label as NSString
//        labelns = labelns?.appending("%") as NSString?
//        
//        
//        _drawAttributes.removeAll()
//        _drawAttributes[NSFontAttributeName] = self.font
//        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
//        _labelSize = labelns?.size(attributes: _drawAttributes) ?? CGSize.zero
//        
//    }
//}
//
//class MKMultipleChartMarker: ChartMarker {
//    var font: UIFont?
//    
//    //圆的半径
//    let circleR:CGFloat = 4.0
//    let textMargin:CGFloat = 5.0
//    
//    //title
//    fileprivate var titleLabelns: NSString?
//    fileprivate var _titleLabelSize: CGSize = CGSize()
//    fileprivate var _titleDrawAttributes = [String : AnyObject]()
//    
//    //top
//    fileprivate var labelns: NSString?
//    fileprivate var _labelSize: CGSize = CGSize()
//    fileprivate var _drawAttributes = [String : AnyObject]()
//    
//    //bottom
//    fileprivate var _subDrawAttributes = [String : AnyObject]()
//    fileprivate var subLabelns: NSString?
//    fileprivate var _subLabelSize: CGSize = CGSize()
//    
//    
//    fileprivate var _size: CGSize = CGSize()
//    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
//    
//    
//    var data: ChartData?
//    
//    
//    var leftImage: NSUIImage?
//    
//    init(font: UIFont , data: ChartData?)
//    {
//        super.init()
//        
//        self.font = font
//        self.data = data
//        
//        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
//        _paragraphStyle?.alignment = .Center
//    }
//    
//    
//    override func draw(context: CGContext, point: CGPoint)
//    {
//        
//        
//        let offset = self.offsetForDrawingAtPos(point)
//        var size = _labelSize.width > _subLabelSize.width ?  _labelSize : _subLabelSize
//        
//        size = CGSize(width: size.width+2*circleR + textMargin + 35, height: 60.0)
//        
//        
//        let offsetX = point.x > UIScreen.main.bounds.size.width/2.0 ? -size.width : 0.0
//        
//        //        CGContextSaveGState(context)
//        UIGraphicsPushContext(context)
//        var rect = CGRect.zero
//        var isLeft = false
//        if point.x > UIScreen.main.bounds.size.width/2.0 {
//            rect = CGRect(x: point.x + offset.x - size.width, y: point.y - size.height/2.0, width: size.width, height: size.height)
//            leftImage!.drawInRect(rect)
//            rect.origin.x -= 2.0
//            
//        }else{
//            rect = CGRect(x: point.x + offset.x, y: point.y - size.height/2.0, width: size.width, height: size.height)
//            image!.drawInRect(rect)
//            rect.origin.x += 2.0
//            isLeft = true
//        }
//        
//        if data != nil{
//            
//            let circleX = point.x + offset.x + offsetX + ( isLeft ? 30 : 15)
//            let titleX  = circleX + circleR + textMargin
//            
//            //1.0 title
//            let titleRect  = CGRect(x: titleX, y: point.y - self.font!.pointSize*2 - 5.0 , width: _titleLabelSize.width, height: _titleLabelSize.height)
//            titleLabelns?.drawInRect(titleRect, withAttributes: _titleDrawAttributes)
//            
//            //2.0 绘制第一个圆
//            
//            context.setFillColor(_drawAttributes[NSForegroundColorAttributeName]!.cgColor)
//            
//            CGContextAddArc(context, circleX, point.y - _labelSize.height + _labelSize.height/2.0, circleR, 0, (CGFloat)(2.0*M_PI), 0)
//            context.drawPath(using: .fill)
//            
//            //2.1 top
//            let topRect = CGRect(x: titleX, y: point.y - _labelSize.height, width: _labelSize.width, height: _labelSize.height)
//            labelns?.drawInRect(topRect, withAttributes: _drawAttributes)
//            
//            
//            //3.0 绘制第二个圆
//            context.setFillColor(_subDrawAttributes[NSForegroundColorAttributeName]!.cgColor)
//            
////            CGContextAddArc(context, circleX, point.y + 5.0 + _labelSize.height/2.0, circleR, 0, (CGFloat)(2.0*M_PI), 0)
//            context.fill(CGRect(x: circleX - circleR , y: point.y + 5.0 + (_subLabelSize.height/2.0 - circleR) , width: circleR*2, height: circleR*2))
//            context.drawPath(using: .fill)
//            
//            //3.1 bottom
//            let bottomRect = CGRect(x: titleX, y: point.y + 5.0  , width: _subLabelSize.width, height: _subLabelSize.height)
//            subLabelns?.drawInRect(bottomRect, withAttributes: _subDrawAttributes)
//            
//            
//        }else{
//            rect.origin.y += (size.height - self.font!.pointSize)/2.0
//            labelns?.draw(in: rect, withAttributes: _drawAttributes)
//        }
//        
//        UIGraphicsPopContext()
//        
//        //        CGContextRestoreGState(context)
//        
//    }
//    
//    override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
//    {
//        
//        _titleDrawAttributes.removeAll()
//        _titleDrawAttributes[NSFontAttributeName] = self.font
//        _titleDrawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
//        
//        
//        
//        _drawAttributes.removeAll()
//        _drawAttributes[NSFontAttributeName] = self.font
//        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
//        
//        
//        _subDrawAttributes.removeAll()
//        _subDrawAttributes[NSFontAttributeName] = self.font
//        _subDrawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
//        
//        
//        
//        
//        
//        
//        
//        let label = entry.value.description
//        labelns = label as NSString
//        labelns = labelns?.appending("%") as NSString?
//        
//        if let sets = data?.dataSets {
//            
//            let xValues = data?.xVals[highlight.xIndex]
//            titleLabelns = xValues! as NSString
//            _titleLabelSize = titleLabelns?.size(attributes: _titleDrawAttributes) ?? CGSize.zero
//            
//            
//            for index in 0..<sets.count {
//                let set = sets[index]
//                
//                let nextEntry = set.entryForIndex(highlight.xIndex)
//                let value = nextEntry!.value.description
//                
//                if 1 == index {
//                    _drawAttributes[NSForegroundColorAttributeName] = set.colorAt(highlight.xIndex)
//                    labelns = "\(set.label! as NSString) \(value as NSString)%"
//                }else if 0 == index  {
//                    _subDrawAttributes[NSForegroundColorAttributeName] = set.colorAt(highlight.xIndex)
//                    subLabelns = "\(set.label! as NSString) \(value as NSString)%"
//                }
//            }
//            
//        }
//        
//        _labelSize = labelns?.size(attributes: _drawAttributes) ?? CGSize.zero
//        _subLabelSize = subLabelns?.size(attributes: _subDrawAttributes) ?? CGSize.zero
//        
//        
//        
//    }
//    
//}
//
////MARK: - 自定义fill format
//open class ChartLvesFillFormatter: NSObject, ChartFillFormatter
//{
//    public override init()
//    {
//    }
//    open func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat
//    {
//        // 李兴乐
//        return CGFloat(dataProvider.chartYMin)
//    }
//}
//
////MARK: 投资组合收益走势图
//class MerakProfitLineChart: LineChartView {
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        configProfitLineChart()
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configProfitLineChart()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    //折线图属性设置
//    func configProfitLineChart() {
//        self.pinchZoomEnabled = false
//        self.descriptionText = ""
//        noDataText = "暂无数据"
////        self.showAllHighlightCircles = true   //是否显示高亮Circle
//        
//        
//        let xAxis = self.xAxis
//        xAxis.labelPosition = .Bottom;                  //x轴线位置
//        xAxis.labelFont = UIFont.systemFontOfSize(10);
//        xAxis.drawGridLinesEnabled = false              //是否显示x轴网格线
//        xAxis.labelTextColor = UIColor(hex6: 0x626776)     //label颜色
//        xAxis.axisLineWidth = 0                         //线宽度
//        xAxis.avoidFirstLastClippingEnabled = true
////        xAxis.setLabelsToSkip(1)
//        
//        
//        //        self.leftAxis.axisMinValue = -100.0            //最低值
//        self.leftAxis.axisLineWidth = 0                //左侧线宽度
//        self.leftAxis.labelTextColor = UIColor(hex6: 0x626776)  //label颜色
//        self.leftAxis.gridColor = UIColor(hex6: 0x262B3B)       //网格线颜色
//        
//        
//        
//        self.rightAxis.enabled = false                 //是否显示右侧轴线
//        self.dragEnabled = true                        //是否可以滑动
//        self.drawGridBackgroundEnabled = false         //背景色
//        self.doubleTapToZoomEnabled = false            //双击缩放
//        self.legend.enabled = false                     //是否显示说明
//        
//    }
//    //数据源
//    //MARK:数据
//    func setLineData(_ xValues:[String],yValues:[ChartDataEntry],label: String?){
//        let set = LineChartDataSet(yVals: yValues, label: label)
//        set.drawFilledEnabled = true
//        set.fillColor = UIColor(hex6: 0xFD734C)
//        
//        set.setColor(UIColor.orangeColor())
//        set.drawValuesEnabled = false
//        
//        set.drawCirclesEnabled = false
//        set.circleRadius = 10.0                                    //圆半径
////        set.highlightImage = NSUIImage(named: "firstInvest_otherprofit_dot")!
//        
//        set.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
//        let lineData =  LineChartData(xVals: xValues, dataSets: [set])
//        //设置数据
//        self.data = lineData
//    }
//}
//
//
//
//
