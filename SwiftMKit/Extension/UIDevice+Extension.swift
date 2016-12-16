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
    case notAvailable
    
    case iPhone2G
    case iPhone3G
    case iPhone3GS
    case iPhone4
    case iPhone4S
    case iPhone5
    case iPhone5C
    case iPhone5S
    case iPhone6Plus
    case iPhone6
    case iPhone6S
    case iPhone6SPlus
    case iPhoneSE
    
    case iPodTouch1G
    case iPodTouch2G
    case iPodTouch3G
    case iPodTouch4G
    case iPodTouch5G
    
    case iPad
    case iPad2
    case iPad3
    case iPad4
    case iPadMini
    case iPadMiniRetina
    case iPadMini3
    
    case iPadAir
    case iPadAir2
    
    case iPadPro
    
    case simulator
}

public extension UIDevice {
    
    fileprivate struct Constant {
        static let UUIDString = "UUIDString"
        static let IDFAString = "IDFAString"
        static let DeviceName = "DeviceName"
    }
    
    //MARK: UUID
    //The value in this property remains the same while the app (or another app from the same vendor) is installed on the iOS device. The value changes when the user deletes all of that vendor’s apps from the device and subsequently reinstalls one or more of them.
    var uuid: String {
        get {
            if let id = DocumentCache.shared().object(forKey: Constant.UUIDString) as? String {
                DDLogInfo("UUID: \(id)")
                return id
            }
            let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
            if id.length > 0 {
                DocumentCache.shared().setObject(id as NSCoding, forKey: Constant.UUIDString)
            }
            DDLogInfo("UUID: \(id)")
            return id
        }
    }
    var idfa: String {
        get {
            if let id = DocumentCache.shared().object(forKey: Constant.IDFAString) as? String {
                DDLogInfo("IDFA: \(id)")
                return id
            }
            let id = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            DocumentCache.shared().setObject(id as NSCoding, forKey: Constant.IDFAString)
            DDLogInfo("IDFA: \(id)")
            return id
        }
    }
    var deviceName: String {
        get {
            if let name = PINMemoryCache.shared().object(forKey: Constant.DeviceName) as? String {
                DDLogInfo("DeviceName: \(name)")
                return name
            }
            let name = UIDevice.current.name
            PINMemoryCache.shared().setObject(name, forKey: Constant.DeviceName)
            DDLogInfo("DeviceName: \(name)")
            return name
        }
    }
    
    //MARK: Formatter MB only
    class func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    
    //MARK: Get String Value
    class var totalDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
    }
    
    class var freeDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
    }
    
    class var usedDiskSpace:String {
        get {
            return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
        }
    }
    
    
    //MARK: Get raw value
    class var totalDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
                return space!
            } catch {
                return 0
            }
        }
    }
    
    class var freeDiskSpaceInBytes:Int64 {
        get {
            do {
                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
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
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return parseDeviceType(identifier)
    }
    
    fileprivate func parseDeviceType(_ identifier: String) -> DeviceType {
        
        if identifier == "i386" || identifier == "x86_64" {
            return .simulator
        }
        
        switch identifier {
        case "iPhone1,1": return .iPhone2G
        case "iPhone1,2": return .iPhone3G
        case "iPhone2,1": return .iPhone3GS
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return .iPhone4
        case "iPhone4,1": return .iPhone4S
        case "iPhone5,1", "iPhone5,2": return .iPhone5
        case "iPhone5,3", "iPhone5,4": return .iPhone5C
        case "iPhone6,1", "iPhone6,2": return .iPhone5S
        case "iPhone7,1": return .iPhone6Plus
        case "iPhone7,2": return .iPhone6
        case "iPhone8,2": return .iPhone6SPlus
        case "iPhone8,1": return .iPhone6S
        case "iPhone8,4": return .iPhoneSE
            
        case "iPod1,1": return .iPodTouch1G
        case "iPod2,1": return .iPodTouch2G
        case "iPod3,1": return .iPodTouch3G
        case "iPod4,1": return .iPodTouch4G
        case "iPod5,1": return .iPodTouch5G
            
        case "iPad1,1", "iPad1,2": return .iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return .iPad2
        case "iPad2,5", "iPad2,6", "iPad2,7": return .iPadMini
        case "iPad3,1", "iPad3,2", "iPad3,3": return .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": return .iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3": return .iPadAir
        case "iPad4,4", "iPad4,5", "iPad4,6": return .iPadMiniRetina
        case "iPad4,7", "iPad4,8": return .iPadMini3
        case "iPad5,3", "iPad5,4": return .iPadAir2
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8": return .iPadPro
            
        default: return .notAvailable
        }
    }
}
