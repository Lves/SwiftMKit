//
//  LocationManager.swift
//  Merak
//
//  Created by Mao on 5/20/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import CoreLocation
import PINCache
import CocoaLumberjack
import ReactiveCocoa


public class LocationManager : NSObject, CLLocationManagerDelegate {
    
    static let NotificationLocationUpdatedName = "NotificationLocationUpdated"
    
    private struct Constant {
        static let Longitude = "LocationLongitude"
        static let Latitude = "LocationLatitude"
    }
    
    lazy public var manager = CLLocationManager()
    public static var shared = LocationManager()
    private var autoStop: Bool = false
    
    public class func start(autoStop autoStop: Bool = false, accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, always: Bool = false) -> Bool {
        if always {
            shared.manager.requestAlwaysAuthorization()
        } else {
            shared.manager.requestWhenInUseAuthorization()
        }
        shared.autoStop = autoStop
        if CLLocationManager.locationServicesEnabled() {
            shared.manager.delegate = shared
            shared.manager.desiredAccuracy = accuracy
            shared.manager.startUpdatingLocation()
            DDLogInfo("[LocationManager] Started");
            return true
        }
        else{
            DDLogError("[LocationManager] Disabled");
            return false
        }
    }
    public class func stop() {
        shared.manager.stopUpdatingLocation()
        DDLogInfo("[LocationManager] Stopped");
    }
    
    @objc public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let long = location.coordinate.longitude
            let lat = location.coordinate.latitude
            DDLogInfo("[LocationManager]:（\(long), \(lat))")
            self.longitude = long
            self.latitude = lat
            NSNotificationCenter.defaultCenter().postNotificationName(LocationManager.NotificationLocationUpdatedName, object: nil)
        }
        if autoStop {
            LocationManager.stop()
        }
    }
    
    var cache = PINDiskCache.sharedCache()
    public var longitude: Double? {
        get {
            return cache.objectForKey(Constant.Longitude) as? Double
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: Constant.Longitude)
            }else {
                cache.removeObjectForKey(Constant.Longitude)
            }
        }
    }
    public var latitude: Double? {
        get {
            return cache.objectForKey(Constant.Latitude) as? Double
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: Constant.Latitude)
            }else {
                cache.removeObjectForKey(Constant.Latitude)
            }
        }
    }
}