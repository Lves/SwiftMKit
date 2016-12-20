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


public extension UIDevice {
    
    fileprivate struct Constant {
        static let UUIDString: String = "UUIDString"
        static let IDFAString: String = "IDFAString"
        static let DeviceName: String = "DeviceName"
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
            if let name = DocumentCache.shared().object(forKey: Constant.DeviceName) as? String {
                DDLogInfo("DeviceName: \(name)")
                return name
            }
            let name = UIDevice.current.name
            DocumentCache.shared().setObject(name as NSCoding, forKey: Constant.DeviceName)
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
    
}


// MARK: -
public extension UIDevice {
    
    /// Returns the `DeviceType` of the device in use
    var deviceType: DeviceType {
        return DeviceType.current
    }
}

/// Enum representing the different types of iOS devices available
public enum DeviceType: String, EnumProtocol {
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
    case iPhone7
    case iPhone7Plus
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
    case iPadMini4
    
    case iPadAir
    case iPadAir2
    
    case iPadPro9Inch
    case iPadPro12Inch
    
    case simulator
    case notAvailable
    
    /// Returns the current device type
    public static var current: DeviceType {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 , value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return DeviceType(identifier: identifier)
    }
    
    /** Creates a device type
     - parameters:
     - identifier: The identifier of the device
     - returns: The device type based on the provided identifier
     */
    internal init(identifier: String) {
        switch identifier {
        case "i386", "x86_64": self = .simulator
        case "iPhone1,1": self = .iPhone2G
        case "iPhone1,2": self = .iPhone3G
        case "iPhone2,1": self = .iPhone3GS
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": self = .iPhone4
        case "iPhone4,1": self = .iPhone4S
        case "iPhone5,1", "iPhone5,2": self = .iPhone5
        case "iPhone5,3", "iPhone5,4": self = .iPhone5C
        case "iPhone6,1", "iPhone6,2": self = .iPhone5S
        case "iPhone7,1": self = .iPhone6Plus
        case "iPhone7,2": self = .iPhone6
        case "iPhone8,2": self = .iPhone6SPlus
        case "iPhone8,1": self = .iPhone6S
        case "iPhone8,4": self = .iPhoneSE
            
        case "iPod1,1": self = .iPodTouch1G
        case "iPod2,1": self = .iPodTouch2G
        case "iPod3,1": self = .iPodTouch3G
        case "iPod4,1": self = .iPodTouch4G
        case "iPod5,1": self = .iPodTouch5G
            
        case "iPad1,1", "iPad1,2": self = .iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": self = .iPad2
        case "iPad2,5", "iPad2,6", "iPad2,7": self = .iPadMini
        case "iPad3,1", "iPad3,2", "iPad3,3": self = .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": self = .iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3": self = .iPadAir
        case "iPad4,4", "iPad4,5", "iPad4,6": self = .iPadMiniRetina
        case "iPad4,7", "iPad4,8": self = .iPadMini3
        case "iPad5,1", "iPad5,2": self = .iPadMini4
        case "iPad5,3", "iPad5,4": self = .iPadAir2
        case "iPad6,3", "iPad6,4": self = .iPadPro9Inch
        case "iPad6,7", "iPad6,8": self = .iPadPro12Inch
            
        default:
            self = .notAvailable
        }
    }
    
    /// Returns the display name of the device type
    var displayName: String {
        
        switch self {
        case .iPhone2G: return "iPhone 2G"
        case .iPhone3G: return "iPhone 3G"
        case .iPhone3GS: return "iPhone 3GS"
        case .iPhone4: return "iPhone 4"
        case .iPhone4S: return "iPhone 4S"
        case .iPhone5: return "iPhone 5"
        case .iPhone5C: return "iPhone 5C"
        case .iPhone5S: return "iPhone 5S"
        case .iPhone6Plus: return "iPhone 6 Plus"
        case .iPhone6: return "iPhone 6"
        case .iPhone6S: return "iPhone 6S"
        case .iPhone6SPlus: return "iPhone 6S Plus"
        case .iPhone7: return "iPhone 7"
        case .iPhone7Plus: return "iPhone 7 Plus"
        case .iPhoneSE: return "iPhone SE"
        case .iPodTouch1G: return "iPod Touch 1G"
        case .iPodTouch2G: return "iPod Touch 2G"
        case .iPodTouch3G: return "iPod Touch 3G"
        case .iPodTouch4G: return "iPod Touch 4G"
        case .iPodTouch5G: return "iPod Touch 5G"
        case .iPad: return "iPad"
        case .iPad2: return "iPad 2"
        case .iPad3: return "iPad 3"
        case .iPad4: return "iPad 4"
        case .iPadMini: return "iPad Mini"
        case .iPadMiniRetina: return "iPad Mini Retina"
        case .iPadMini3: return "iPad Mini 3"
        case .iPadMini4: return "iPad Mini 4"
        case .iPadAir: return "iPad Air"
        case .iPadAir2: return "iPad Air 2"
        case .iPadPro9Inch: return "iPad Pro 9 Inch"
        case .iPadPro12Inch: return "iPad Pro 12 Inch"
        case .simulator: return "Simulator"
        case .notAvailable: return "Not Available"
        }
    }
}


// MARK:
/// Protocol gives basic functionality to Enums
public protocol EnumProtocol: Hashable {
    /// Returns Full Count of Enum
    static var count: Int { get }
    /// Returns All Enum Values
    static var all: [Self] { get }
}

// MARK: -
public extension EnumProtocol where Self:Hashable {
    
    /// Returns Full Count of Enum
    static var count: Int {
        
        let byteCount = MemoryLayout<Self>.size
        if byteCount == 0 {return 1}
        if byteCount > 2 {fatalError("Unable to process enumeration")}
        let singleByte = byteCount == 1
        let minValue = singleByte ? 2 : 257
        let maxValue = singleByte ? 2 << 8 : 2 << 16
        for hashIndex in minValue..<maxValue {
            switch singleByte {
            case true:
                if unsafeBitCast(UInt8(hashIndex), to: self).hashValue == 0 {
                    return hashIndex
                }
            case false:
                if unsafeBitCast(UInt16(hashIndex), to: self).hashValue == 0 {
                    return hashIndex
                }
            }
        }
        return maxValue
    }
    
    /// Returns All Enum Values
    static var all: [Self] {
        
        var enumerationMembers = [Self]()
        let singleByte = MemoryLayout<Self>.size == 1
        for index in 0..<Self.count {
            switch singleByte {
            case true:
                let member = unsafeBitCast(UInt8(index), to: self)
                enumerationMembers.append(member)
            case false:
                let member = unsafeBitCast(UInt16(index), to: self)
                enumerationMembers.append(member)
            }
        }
        return enumerationMembers
    }
}
