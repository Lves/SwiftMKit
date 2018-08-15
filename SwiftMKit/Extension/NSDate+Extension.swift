//
//  NSDate+Extension.swift
//  Merak
//
//  Created by HeLi on 16/10/11.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    public var localDate : Date {
        get {
            let localTimeZone : TimeZone = NSTimeZone.local
            let offset : TimeInterval = TimeInterval(localTimeZone.secondsFromGMT(for: Date()))
            let date : Date = Date().addingTimeInterval(offset)
            return date
        }
    }
    
    public var currentYear : Int{
        get{
            let dateFormatter:DateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.string(from: self);
            var dates:[String] = dateString.components(separatedBy: "/")
            return dates[0].toInt() ?? 0
        }
    }
    
    public var currentMonth : Int{
        get{
            let dateFormatter:DateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.string(from: self);
            var dates:[String] = dateString.components(separatedBy: "/")
            return dates[1].toInt() ?? 0
        }
    }
    
    public var currentDay : Int{
        get{
            let dateFormatter:DateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy/MM/dd";
            let dateString:String = dateFormatter.string(from: self);
            var dates:[String] = dateString.components(separatedBy: "/")
            return dates[2].toInt() ?? 0
        }
    }
    
    public var currentHour : Int{
        get{
            let dateFormatter:DateFormatter = DateFormatter();
            dateFormatter.dateFormat = "HH/MM/SS";
            let dateString:String = dateFormatter.string(from: self);
            var dates:[String] = dateString.components(separatedBy: "/")
            return dates[0].toInt() ?? 0
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
