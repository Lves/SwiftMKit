//
//  UIDevice+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/9/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import PINCache
import CocoaLumberjack

public extension UIDevice {
    
    private struct Constant {
        static let UUIDString = "UUIDString"
        static let DeviceName = "DeviceName"
    }
    
    //MARK: UUID
    //The value in this property remains the same while the app (or another app from the same vendor) is installed on the iOS device. The value changes when the user deletes all of that vendor’s apps from the device and subsequently reinstalls one or more of them.
    var uuid: String {
        get {
            if let id = DocumentCache.sharedCache().objectForKey(Constant.UUIDString) as? String {
                DDLogInfo("UUID: \(id)")
                return id
            }
            let id = UIDevice.currentDevice().identifierForVendor!.UUIDString
            DocumentCache.sharedCache().setObject(id, forKey: Constant.UUIDString)
            DDLogInfo("UUID: \(id)")
            return id
        }
    }
    var deviceName: String {
        get {
            if let name = PINMemoryCache.sharedCache().objectForKey(Constant.DeviceName) as? String {
                DDLogInfo("DeviceName: \(name)")
                return name
            }
            let name = UIDevice.currentDevice().name
            PINMemoryCache.sharedCache().setObject(name, forKey: Constant.DeviceName)
            DDLogInfo("DeviceName: \(name)")
            return name
        }
    }
    
    //MARK: Formatter MB only
    class func MBFormatter(bytes: Int64) -> String {
        let formatter = NSByteCountFormatter()
        formatter.allowedUnits = NSByteCountFormatterUnits.UseMB
        formatter.countStyle = NSByteCountFormatterCountStyle.Decimal
        formatter.includesUnit = false
        return formatter.stringFromByteCount(bytes) as String
    }
    
    
    //MARK: Get String Value
    class var totalDiskSpace:String {
        get {
            return NSByteCountFormatter.stringFromByteCount(totalDiskSpaceInBytes, countStyle: NSByteCountFormatterCountStyle.Binary)
        }
    }
    
    class var freeDiskSpace:String {
        get {
            return NSByteCountFormatter.stringFromByteCount(freeDiskSpaceInBytes, countStyle: NSByteCountFormatterCountStyle.Binary)
        }
    }
    
    class var usedDiskSpace:String {
        get {
            return NSByteCountFormatter.stringFromByteCount(usedDiskSpaceInBytes, countStyle: NSByteCountFormatterCountStyle.Binary)
        }
    }
    
    
    //MARK: Get raw value
    class var totalDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(NSHomeDirectory() as String)
                let space = (systemAttributes[NSFileSystemSize] as? NSNumber)?.longLongValue
                return space!
            } catch {
                return 0
            }
        }
    }
    
    class var freeDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(NSHomeDirectory() as String)
                let freeSpace = (systemAttributes[NSFileSystemFreeSize] as? NSNumber)?.longLongValue
                return freeSpace!
            } catch {
                return 0
            }
        }
    }
    
    class var usedDiskSpaceInBytes:Int64 {
        get {
            let usedSpace = totalDiskSpaceInBytes - freeDiskSpaceInBytes
            return usedSpace
        }
    }
}