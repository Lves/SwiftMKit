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

open class LocationManager : NSObject, CLLocationManagerDelegate {
    
    static let NotificationLocationUpdatedName = "NotificationLocationUpdated"
    
    fileprivate struct Constant {
        static let Longitude = "LocationLongitude"
        static let Latitude = "LocationLatitude"
        static let CurCityName = "LocationCurCityName"
    }
    
    lazy open var manager = CLLocationManager()
    open static var shared = LocationManager()
    fileprivate var locatieCompletion: ((CLLocation?, NSError?) -> ())?
    fileprivate var autoStop: Bool = false
    
    open class func start(autoStop: Bool = false, accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, always: Bool = false) -> Bool {
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
            DDLogInfo("Started");
            return true
        }
        else{
            DDLogError("Disabled");
            return false
        }
    }
    open class func stop() {
        shared.manager.stopUpdatingLocation()
        DDLogInfo("Stopped");
    }
    open func getlocation(_ complete: @escaping (CLLocation?, NSError?) -> ()) {
        locatieCompletion = { location, error in
            complete(location, error)
            LocationManager.stop()
        }
        let _ = LocationManager.start()
    }
    
    @objc open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let long = location.coordinate.longitude
            let lat = location.coordinate.latitude
            DDLogInfo("当前坐标: (\(lat), \(long))")
            self.longitude = long
            self.latitude = lat
            self.locatieCompletion?(location, nil)
            self.locatieCompletion = nil
            
            //获取城市信息
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { array , error in
                if (array?.count ?? 0) > 0 {
                    let placemark = array?.first
                    self.curCityName = placemark?.locality
                    if (placemark?.locality == nil) {
                        self.curCityName = placemark?.administrativeArea
                    }
                }
            })
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: LocationManager.NotificationLocationUpdatedName), object: nil)
        }
        if autoStop {
            LocationManager.stop()
        }
    }
    @objc open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locatieCompletion?(nil, error as NSError?)
        self.locatieCompletion = nil
    }
    
    var cache = PINDiskCache.shared()
    open var longitude: Double? {
        get {
            return cache.object(forKey: Constant.Longitude) as? Double
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: Constant.Longitude)
            }else {
                cache.removeObject(forKey: Constant.Longitude)
            }
        }
    }
    open var latitude: Double? {
        get {
            return cache.object(forKey: Constant.Latitude) as? Double
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: Constant.Latitude)
            }else {
                cache.removeObject(forKey: Constant.Latitude)
            }
        }
    }
    
    open var curCityName:String? {
        get{
            return cache.object(forKey: Constant.CurCityName) as? String
        }
        set {
            DDLogInfo("当前城市: \(curCityName ?? "")")
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: Constant.CurCityName)
            }else {
                cache.removeObject(forKey: Constant.CurCityName)
            }
        }
    }
}
