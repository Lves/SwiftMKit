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
    var lineChart:LineChartView!
    var barChartView:BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///1.0 折线图
        lineChart = LineChartView(frame: CGRectMake(0, 0,screenSize.width , 500))
        self.lineChart.delegate = self
        self.setLineData()
        
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .Bottom;          //x轴线位置
        xAxis.labelFont = UIFont.systemFontOfSize(10);
        xAxis.drawGridLinesEnabled = false       // 是否显示x轴网格线
        xAxis.spaceBetweenLabels = 1
        //是否显示右侧轴线
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.dragEnabled = true //是否可以滑动
        lineChart.drawGridBackgroundEnabled = false //背景色
        
        
        
        //2.0 柱状图
        barChartView = BarChartView(frame: CGRectMake(0, 500,screenSize.width , 500))
        self.barChartView.delegate = self
        self.setChartData()
        
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 64, screenSize.width, screenSize.height-64-55))
        scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height*2.0)
        self.view.addSubview(scrollView)

        scrollView.addSubview(self.lineChart)
        scrollView.addSubview(self.barChartView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLineData(){
        var xValues = [String]()
        for index in 1...10 {
            let flotVa = Float(index*1)
            xValues.append("\(flotVa)")
        }
        
        var yValues = [ChartDataEntry]()
        for yIndex in  1...10 {
            let flotVa = (Double)(yIndex*10)
            yValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        var anotherYValues = [ChartDataEntry]()
        for yIndex in  1...10 {
            
            let flotVa = Double(pow(Float(yIndex), 2.0))
            anotherYValues.append(ChartDataEntry(value: flotVa, xIndex: yIndex))
        }
        
        let set1 = LineChartDataSet(yVals: yValues, label: "DataSet 1")
        set1.setColor(UIColor.blueColor())
        set1.setCircleColor(UIColor.blueColor())
        set1.drawFilledEnabled = true
        
        
        let set2 = LineChartDataSet(yVals: anotherYValues, label: "DataSet 2")
        set2.drawFilledEnabled = true
        set2.fillColor = UIColor.redColor()
        
        
        let data = LineChartData(xVals: xValues, dataSets: [set1,set2])
        
        self.lineChart!.data = data
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



