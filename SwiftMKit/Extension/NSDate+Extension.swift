//
//  NSDate+Extension.swift
//  Merak
//
//  Created by HeLi on 16/10/11.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import Foundation
import UIKit

extension NSDate {
    
    public var currentYear : Int{
        get{
            let dateFormatter:NSDateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.stringFromDate(self);
            var dates:[String] = dateString.componentsSeparatedByString("/")
            return dates[0].toInt() ?? 0
        }
    }
    
    public var currentMonth : Int{
        get{
            let dateFormatter:NSDateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.stringFromDate(self);
            var dates:[String] = dateString.componentsSeparatedByString("/")
            return dates[1].toInt() ?? 0
        }
    }
    
    public var currentDay : Int{
        get{
            let dateFormatter:NSDateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.stringFromDate(self);
            var dates:[String] = dateString.componentsSeparatedByString("/")
            return dates[2].toInt() ?? 0
        }
    }
    
    //每调用一次月份向下跳一月，跨年则为下一年1月
    func getNextYearAndMonth () -> (year:Int,month:Int){
        var next_year:Int = currentYear
        var next_month:Int = currentMonth + 1
        if next_month > 12 {
            next_month=1
            next_year+=1
        }
        //Swift可以同时返回多个值，返回值类型为元组
        return (next_year,next_month)
    }
    
    //每调用一次月份向上跳一月，跨年则为上一年12月
    func getPrevYearAndMonth () -> (year:Int,month:Int){
        var prev_year:Int = currentYear
        var prev_month:Int = currentMonth - 1
        if prev_month == 0 {
            prev_month = 12
            prev_year-=1
        }
        return (prev_year,prev_month)
    }
}