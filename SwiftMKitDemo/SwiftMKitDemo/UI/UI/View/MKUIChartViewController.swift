//
//  MKUIChartViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Charts



class MKUIChartViewController: BaseViewController {
    let screenSize = UIScreen.mainScreen().bounds.size
    let kBlackColor  = NSUIColor(red: 46/255.0, green: 52/255.0, blue: 72/255.0, alpha: 1.0)
    var lineChart:LineChartView!
    var lineChart2:LineChartView!
    var barChartView:BarChartView!
    var lineChart1Data:ChartData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //1.0 折线图
        self.buildLineChartUI()
        //2.0 折线图2
        self.buildLineChart2UI()
        
        //3.0 柱状图
        self.buildBarChartUI()
        //4.0 ScrollView
        let scrollView = UIScrollView(frame: CGRectMake(0, 64, screenSize.width, screenSize.height-64))
        scrollView.contentSize = CGSizeMake(screenSize.width, 500*3.0)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(self.lineChart)
        scrollView.addSubview(self.lineChart2)
        scrollView.addSubview(self.barChartView)
        
        
    }
    //MARK: 折线图
    func buildLineChartUI() {
        //获得数据
        self.buildLineData1()
        
        lineChart = LineChartView(frame: CGRectMake(0, 0,screenSize.width , 400))
        lineChart.backgroundColor = kBlackColor
        lineChart.alpha = 0.8
        lineChart.pinchZoomEnabled = false
        lineChart.descriptionText = ""

        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .Bottom;          //x轴线位置
        xAxis.labelFont = UIFont.systemFontOfSize(10);
        xAxis.drawGridLinesEnabled = false       // 是否显示x轴网格线
        xAxis.spaceBetweenLabels = 1
        xAxis.axisLineWidth = 0                  //线宽度
        
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        lineChart.leftAxis.valueFormatter = percentFormatter  //y轴显示格式化
        lineChart.leftAxis.axisLineWidth = 0          //左侧线宽度
        lineChart.rightAxis.enabled = false           //是否显示右侧轴线
        lineChart.dragEnabled = true                  //是否可以滑动
        lineChart.drawGridBackgroundEnabled = false   //背景色
        lineChart.doubleTapToZoomEnabled = false      //双击缩放
        lineChart.legend.form = .Circle               //图例样式
        lineChart.legend.position = .AboveChartCenter //图例位置
        
        let marker =  MKChartMarker(font: UIFont.systemFontOfSize(12),data: self.lineChart1Data!)
        marker.image = UIImage(named: "BubblePopRight")
        marker.leftImage = UIImage(named: "BubblePopLeft")
        lineChart.marker = marker

        
        self.lineChart.delegate = self
        //设置数据
        self.lineChart.data = self.lineChart1Data
        
        self.lineChart.animate(xAxisDuration: 3.0)
        
    }
    
    func buildLineData1(){
        var xValues = [String]()
        for index in 0...10 {
            xValues.append("\(2005+index)")
        }
        
        //Line 0
        var yValues0 = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa =  (Double) (arc4random()%50)
            yValues0.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set0 = LineChartDataSet(yVals: yValues0, label: "DataSet 0")
        set0.fillColor = UIColor.blackColor()
        set0.drawFilledEnabled = true
        set0.drawCirclesEnabled = false
        set0.lineWidth = 0
        set0.setColor(UIColor.blackColor())
        set0.drawValuesEnabled = false  //是否显示数字
        set0.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
        
        //Line2
        var anotherYValues = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(pow(Float(yIndex), 2.0)) - (Double) (arc4random()%10)
            anotherYValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }

        let set2 = LineChartDataSet(yVals: anotherYValues, label: "DataSet 2")
        set2.fillColor = UIColor.orangeColor()
        set2.drawFilledEnabled = true
        set2.setColor(UIColor.orangeColor())
        set2.drawCirclesEnabled = false
        set2.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
        
        //格式化数据
        let percentFormatter = NSNumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        
        let lineData =  LineChartData(xVals: xValues, dataSets: [set0,set2])
        lineData.setValueFormatter(percentFormatter);
        
        self.lineChart1Data = lineData
    }
    
    //MARK: 折线图2
    
    func buildLineChart2UI() {
        lineChart2 = LineChartView(frame: CGRectMake(0, 420,screenSize.width , 400))
        lineChart2.backgroundColor = kBlackColor
        lineChart2.alpha = 0.8
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        lineChart2.leftAxis.valueFormatter = percentFormatter  //y轴显示格式化
        
        
        let xAxis = lineChart2.xAxis
        xAxis.labelPosition = .Bottom;          //x轴线位置
        xAxis.labelFont = UIFont.systemFontOfSize(10);
        xAxis.drawGridLinesEnabled = false       // 是否显示x轴网格线
        xAxis.spaceBetweenLabels = 1
        xAxis.axisLineWidth = 0                  //线宽度
        xAxis.drawGridLinesEnabled = false       //是否显示有网格线
        
        lineChart2.leftAxis.axisLineWidth = 0          //左侧线宽度
        lineChart2.rightAxis.enabled = false           //是否显示右侧轴线
        lineChart2.dragEnabled = true                  //是否可以滑动
        lineChart2.drawGridBackgroundEnabled = false   //背景色
        lineChart2.doubleTapToZoomEnabled = false      //双击缩放
        lineChart2.legend.enabled = true  //是否显示说明
        lineChart2.descriptionText = ""
        lineChart2.legend.position = .AboveChartCenter  //图例位置
        

        let marker =  MKChartMarker( font: UIFont.systemFontOfSize(12),data: nil)
        marker.image = UIImage(named: "BubblePopRight")
        marker.leftImage = UIImage(named: "BubblePopLeft")
        lineChart2.marker = marker
        
        
        self.lineChart2.delegate = self
        self.setLine2Data()
        
        
    }
    
    func setLine2Data(){
        
        //设置x轴
        var xValues = [String]()
        for index in 0...10 {
            xValues.append("\(2005 + index)")
        }
        
        
        //格式化数据
        let percentFormatter = NSNumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        
        
        
        //Line1
        var yValues1 = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(Float(yIndex) * 100) - (Double) (arc4random()%20)
            yValues1.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        //底部填充线
        var yValues1Lower = [ChartDataEntry]()
        for yIndex in  0...10 {
            
            let flotVa = Double(Float(yIndex) * 10) - (Double) (arc4random()%20)
            yValues1Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set1 = LineChartDataSet(yVals: yValues1, label: "DataSet 1")
        set1.drawFilledEnabled = true
        
        set1.fillColor = UIColor.orangeColor()
        set1.setColor(UIColor.orangeColor())
        set1.drawCirclesEnabled = false
        set1.lineWidth = 0
        set1.drawValuesEnabled = false  //是否显示数字
        set1.highlightEnabled = false   //是否可以高亮
        set1.drawRangeFilledEnabled = true    //是否区域填充
        set1.fillLowerYValues = yValues1Lower ///设置底部fill线
        set1.drawCubicEnabled = true  //是否显示曲线形式
        set1.valueFormatter = percentFormatter
        
        
        //Line 2
        var yValues2 = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(Float(yIndex) * 75) - (Double) (arc4random()%50)
            yValues2.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        //底部填充线
        var yValues2Lower = [ChartDataEntry]()
        for yIndex in  0...10 {
            
            let flotVa = Double(Float(yIndex) * 25) - (Double) (arc4random()%50)
            yValues2Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set2 = LineChartDataSet(yVals: yValues2, label: "DataSet 2")
        set2.fillColor = UIColor.purpleColor()
        set2.setColor(UIColor.purpleColor())
        set2.drawFilledEnabled = true
        set2.drawCirclesEnabled = false
        set2.lineWidth = 0
        set2.drawValuesEnabled = false  //是否显示数字
        set2.highlightEnabled = false   //是否可以高亮
        set2.drawCubicEnabled = true  //是否显示曲线形式
        set2.drawRangeFilledEnabled = true //部分填充
        ///设置底部fill线
        set2.fillLowerYValues = yValues2Lower
        set2.valueFormatter = percentFormatter
       

        //Line3 
        
        var yValuesMiddle = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(Float(yIndex) * 50)
            yValuesMiddle.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        let setMiddle = LineChartDataSet(yVals: yValuesMiddle, label: "DataSet Middle")
        setMiddle.drawFilledEnabled = false
        setMiddle.drawCirclesEnabled = true
        setMiddle.setColor(UIColor.orangeColor())
        setMiddle.lineWidth = 1
        setMiddle.circleRadius = 3
        setMiddle.drawHorizontalHighlightIndicatorEnabled = false  //是否显示水平高亮线
        setMiddle.drawCubicEnabled = true  //是否显示曲线形式
        setMiddle.valueFormatter = percentFormatter
        

        
        let lineData =  LineChartData(xVals: xValues, dataSets: [set1,set2,setMiddle])
        lineData.setValueFormatter(percentFormatter);

        self.lineChart2!.data = lineData
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: 柱状图
    func buildBarChartUI()  {
        barChartView = BarChartView(frame: CGRectMake(0, 900,screenSize.width , 400))
        self.barChartView.delegate = self
        self.barChartView.doubleTapToZoomEnabled = false      //双击缩放
        self.barChartView.xAxis.drawGridLinesEnabled = false
        self.barChartView.leftAxis.drawGridLinesEnabled = false
        self.barChartView.rightAxis.enabled = false
        self.barChartView.xAxis.enabled = false
        self.barChartView.leftAxis.axisLineWidth = 0
        self.barChartView.descriptionText = ""
        
        let percentFormatter = NSNumberFormatter()
        percentFormatter.positiveSuffix = "%"
        percentFormatter.negativeSuffix = "%"
        self.barChartView.leftAxis.valueFormatter = percentFormatter
        self.barChartView.leftAxis.labelPosition = .InsideChart
        
        self.setChartData()
    }
    
    
    func setChartData(){
        
        var xVals = [String]()
        for xIndex in 1...10 {
            let xValue = "\(xIndex)"
            xVals.append(xValue)
        }
        
        
        var yVals1 = [BarChartDataEntry]()
        
        for yIndex in 1...10 {
            let val = (Double) (arc4random()%100);
            let dataEntity = BarChartDataEntry(value: val, xIndex: yIndex)
            yVals1.append(dataEntity)
        }
        
        let set1 = BarChartDataSet(yVals: yVals1, label: "Compnay A")
        set1.setColors([UIColor.redColor(),
            UIColor.blueColor(),
            UIColor.orangeColor(),
            UIColor.blackColor(),
            UIColor.grayColor(),
            UIColor.darkGrayColor(),
            UIColor.purpleColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.brownColor()], alpha: 1.0)
        let barChartData = BarChartData(xVals: xVals, dataSets: [set1])
        self.barChartView.data = barChartData
        
        self.barChartView.animate(yAxisDuration: 3.0)
        
    }
}


extension MKUIChartViewController:ChartViewDelegate  {
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("Seleted");
    }
    func chartValueNothingSelected(chartView: ChartViewBase) {
         print("NothingSeleted");
    }
}



