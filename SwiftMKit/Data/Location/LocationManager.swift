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

public class LocationManager : NSObject, CLLocationManagerDelegate {
    
    private struct Constant {
        static let Longitude = "LocationLongitude"
        static let Latitude = "LocationLatitude"
    }
    
    lazy public var manager = CLLocationManager()
    public static var shared = LocationManager()
    
    public class func start(accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, always: Bool = false) {
        if always {
            shared.manager.requestAlwaysAuthorization()
        } else {
            shared.manager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            shared.manager.delegate = shared
            shared.manager.desiredAccuracy = accuracy
            shared.manager.startUpdatingLocation()
        }
        else{
            print("Location service disabled");
        }
    }
    
    @objc public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let long = location.coordinate.longitude
            let lat = location.coordinate.latitude
            DDLogInfo("[LocationManager]: long-\(long) lat-\(lat)")
            self.longitude = long
            self.latitude = lat
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