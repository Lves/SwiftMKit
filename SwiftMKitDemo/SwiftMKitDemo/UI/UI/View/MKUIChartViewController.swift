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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///1.0 折线图
        self.buildLineChartUI()
        //2.0 折线图2
        self.buildLineChart2UI()
        
        //2.0 柱状图
        self.buildBarChartUI()
        //3. ScrollView
        let scrollView = UIScrollView(frame: CGRectMake(0, 64, screenSize.width, screenSize.height-64-55))
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height*3.0)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(self.lineChart)
        scrollView.addSubview(self.lineChart2)
        scrollView.addSubview(self.barChartView)
        
        
    }
    //MARK: 折线图
    func buildLineChartUI() {
        lineChart = LineChartView(frame: CGRectMake(0, 0,screenSize.width , 500))
        lineChart.backgroundColor = kBlackColor
        lineChart.alpha = 0.8
        lineChart.pinchZoomEnabled = false
        
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .Bottom;          //x轴线位置
        xAxis.labelFont = UIFont.systemFontOfSize(10);
        xAxis.drawGridLinesEnabled = false       // 是否显示x轴网格线
        xAxis.spaceBetweenLabels = 1
        xAxis.axisLineWidth = 0                  //线宽度
        xAxis.drawGridLinesEnabled = false       //是否显示有网格线
        
        lineChart.leftAxis.axisLineWidth = 0          //左侧线宽度
        lineChart.rightAxis.enabled = false           //是否显示右侧轴线
        lineChart.dragEnabled = true                  //是否可以滑动
        lineChart.drawGridBackgroundEnabled = false   //背景色
        
        self.lineChart.delegate = self
        self.setLineData()
        
    }
    
    func setLineData(){
        var xValues = [String]()
        for index in 0...10 {
            let flotVa = Float(index*1)
            xValues.append("\(flotVa)")
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
        
        
        //Line2
        var anotherYValues = [ChartDataEntry]()
        for yIndex in  0...10 {
            
            let flotVa = Double(pow(Float(yIndex), 2.0))
            anotherYValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }

        let set2 = LineChartDataSet(yVals: anotherYValues, label: "DataSet 2")
        set2.drawFilledEnabled = false
        set2.setColor(UIColor.orangeColor())
        set2.drawCirclesEnabled = false
        
        
        let data = LineChartData(xVals: xValues, dataSets: [set0,set2])
        
        self.lineChart!.data = data
    }
    
    //MARK: 折线图2
    
    func buildLineChart2UI() {
        lineChart2 = LineChartView(frame: CGRectMake(0, 510,screenSize.width , 500))
        lineChart2.backgroundColor = kBlackColor
        lineChart2.alpha = 0.8
        
        
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
        lineChart2.legend.enabled = true  //是否显示说明
        self.lineChart2.delegate = self
        self.setLine2Data()
        
        
    }
    
    func setLine2Data(){
        
        //设置x轴
        var xValues = [String]()
        for index in 0...10 {
            let flotVa = Float(index*1)
            xValues.append("\(flotVa)")
        }
        
        
        //Line1
        var yValues1 = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(Float(yIndex) * 100)
            yValues1.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        //底部填充线
        var yValues1Lower = [ChartDataEntry]()
        for yIndex in  0...10 {
            
            let flotVa = Double(Float(yIndex) * 10)
            yValues1Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set1 = LineChartDataSet(yVals: yValues1, label: "DataSet 1")
        set1.drawFilledEnabled = true
        set1.drawRangeFilledEnabled = true
        ///设置底部fill线
        set1.fillLowerYValues = yValues1Lower
        set1.fillColor = UIColor.orangeColor()
        set1.setColor(UIColor.orangeColor())
        set1.drawCirclesEnabled = false
        set1.lineWidth = 0
        set1.drawValuesEnabled = false  //是否显示数字
        
        
        //Line 2
        var yValues2 = [ChartDataEntry]()
        for yIndex in  0...10 {
            let flotVa = Double(Float(yIndex) * 75)
            yValues2.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        //底部填充线
        var yValues2Lower = [ChartDataEntry]()
        for yIndex in  0...10 {
            
            let flotVa = Double(Float(yIndex) * 25)
            yValues2Lower.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set2 = LineChartDataSet(yVals: yValues2, label: "DataSet 2")
        set2.fillColor = UIColor.purpleColor()
        set2.drawFilledEnabled = true
        set2.drawCirclesEnabled = false
        set2.drawRangeFilledEnabled = true
        ///设置底部fill线
        set2.fillLowerYValues = yValues2Lower
        set2.lineWidth = 0
        set2.drawValuesEnabled = false  //是否显示数字
       

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
        

       

        
        
        let data = LineChartData(xVals: xValues, dataSets: [set1,set2,setMiddle])
        
        self.lineChart2!.data = data
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: 柱状图
    func buildBarChartUI()  {
        barChartView = BarChartView(frame: CGRectMake(0, 1020,screenSize.width , 500))
        self.barChartView.delegate = self
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
        let barChartData = BarChartData(xVals: xVals, dataSets: [set1])
        self.barChartView.data = barChartData
        
        
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

