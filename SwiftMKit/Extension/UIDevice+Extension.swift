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
import AdSupport
import AudioToolbox

public enum DeviceType {
    case NotAvailable
    
    case IPhone2G
    case IPhone3G
    case IPhone3GS
    case IPhone4
    case IPhone4S
    case IPhone5
    case IPhone5C
    case IPhone5S
    case IPhone6Plus
    case IPhone6
    case IPhone6S
    case IPhone6SPlus
    case IPhoneSE
    
    case IPodTouch1G
    case IPodTouch2G
    case IPodTouch3G
    case IPodTouch4G
    case IPodTouch5G
    
    case IPad
    case IPad2
    case IPad3
    case IPad4
    case IPadMini
    case IPadMiniRetina
    case IPadMini3
    
    case IPadAir
    case IPadAir2
    
    case IPadPro
    
    case Simulator
}

public extension UIDevice {
    
    private struct Constant {
        static let UUIDString = "UUIDString"
        static let IDFAString = "IDFAString"
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
            let id = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? ""
            if id.length > 0 {
                DocumentCache.sharedCache().setObject(id, forKey: Constant.UUIDString)
            }
            DDLogInfo("UUID: \(id)")
            return id
        }
    }
    var idfa: String {
        get {
            if let id = DocumentCache.sharedCache().objectForKey(Constant.IDFAString) as? String {
                DDLogInfo("IDFA: \(id)")
                return id
            }
            let id = ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
            DocumentCache.sharedCache().setObject(id, forKey: Constant.IDFAString)
            DDLogInfo("IDFA: \(id)")
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
    
    public func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    var deviceType: DeviceType {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        
        return parseDeviceType(identifier)
    }
    
    private func parseDeviceType(identifier: String) -> DeviceType {
        
        if identifier == "i386" || identifier == "x86_64" {
            return .Simulator
        }
        
        switch identifier {
        case "iPhone1,1": return .IPhone2G
        case "iPhone1,2": return .IPhone3G
        case "iPhone2,1": return .IPhone3GS
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return .IPhone4
        case "iPhone4,1": return .IPhone4S
        case "iPhone5,1", "iPhone5,2": return .IPhone5
        case "iPhone5,3", "iPhone5,4": return .IPhone5C
        case "iPhone6,1", "iPhone6,2": return .IPhone5S
        case "iPhone7,1": return .IPhone6Plus
        case "iPhone7,2": return .IPhone6
        case "iPhone8,2": return .IPhone6SPlus
        case "iPhone8,1": return .IPhone6S
        case "iPhone8,4": return .IPhoneSE
            
        case "iPod1,1": return .IPodTouch1G
        case "iPod2,1": return .IPodTouch2G
        case "iPod3,1": return .IPodTouch3G
        case "iPod4,1": return .IPodTouch4G
        case "iPod5,1": return .IPodTouch5G
            
        case "iPad1,1", "iPad1,2": return .IPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return .IPad2
        case "iPad2,5", "iPad2,6", "iPad2,7": return .IPadMini
        case "iPad3,1", "iPad3,2", "iPad3,3": return .IPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": return .IPad4
        case "iPad4,1", "iPad4,2", "iPad4,3": return .IPadAir
        case "iPad4,4", "iPad4,5", "iPad4,6": return .IPadMiniRetina
        case "iPad4,7", "iPad4,8": return .IPadMini3
        case "iPad5,3", "iPad5,4": return .IPadAir2
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8": return .IPadPro
            
        default: return .NotAvailable
        }
    }
}