//
//  KeychainWrapper.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

let SecMatchLimit: String! = kSecMatchLimit as String
let SecReturnData: String! = kSecReturnData as String
let SecValueData: String! = kSecValueData as String
let SecAttrAccessible: String! = kSecAttrAccessible as String
let SecClass: String! = kSecClass as String
let SecAttrService: String! = kSecAttrService as String
let SecAttrGeneric: String! = kSecAttrGeneric as String
let SecAttrAccount: String! = kSecAttrAccount as String

class KeychainWrapper {
    fileprivate struct internalVars {
        static var serviceName: String = ""
    }
    
    // MARK: Public Properties
    
    /*!
     @var serviceName
     @abstract Used for the kSecAttrService property to uniquely identify this keychain accessor.
     @discussion Service Name will default to the app's bundle identifier if it can
     */
    class var serviceName: String {
        get {
            if internalVars.serviceName.isEmpty {
                internalVars.serviceName = Bundle.main.bundleIdentifier ?? "KeychainWrapper"
            }
            return internalVars.serviceName
        }
        set(newServiceName) {
            internalVars.serviceName = newServiceName
        }
    }
    
    // MARK: Public Methods
    class func hasValue(forKey key: String) -> Bool {
        return self.data(forKey: key) != nil
    }
    
    // MARK: Getting Values
    class func string(forKey keyName: String) -> String? {
        let keychainData: Data? = self.data(forKey: keyName)
        var stringValue: String?
        if let data = keychainData {
            stringValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
        }
        
        return stringValue
    }
    
    class func object(forKey keyName: String) -> NSCoding? {
        let dataValue: Data? = self.data(forKey: keyName)
        
        var objectValue: NSCoding?
        
        if let data = dataValue {
            objectValue = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
        }
        
        return objectValue
    }
    
    class func data(forKey keyName: String) -> Data? {
        let keychainQueryDictionary = self.setupKeychainQueryDictionary(forKey: keyName)
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want NSData/CFData returned
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        // Search
        var searchResultRef: AnyObject?
        var keychainValue: Data?
        
        let status: OSStatus = SecItemCopyMatching(keychainQueryDictionary, &searchResultRef)
        
        if status == noErr {
            if let resultRef = searchResultRef {
                keychainValue = resultRef as? Data
            }
        }
        
        return keychainValue;
    }
    
    // MARK: Setting Values
    class func setString(_ value: String, forKey keyName: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8) {
            return self.setData(data, forKey: keyName)
        } else {
            return false
        }
    }
    
    class func setObject(_ value: NSCoding, forKey keyName: String) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        
        return self.setData(data, forKey: keyName)
    }
    
    class func setData(_ value: Data, forKey keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionary(forKey: keyName)
        
        keychainQueryDictionary[SecValueData] = value
        
        // Protect the keychain entry so it's only valid when the device is unlocked
        keychainQueryDictionary[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return self.updateData(value, forKey: keyName)
        } else {
            return false
        }
    }
    
    // MARK: Removing Values
    class func removeObject(forKey keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionary(forKey: keyName)
        
        // Delete
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary);
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Private Methods
    fileprivate class func updateData(_ value: Data, forKey keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionary(forKey: keyName)
        let updateDictionary = [SecValueData:value]
        
        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary, updateDictionary as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    fileprivate class func setupKeychainQueryDictionary(forKey keyName: String) -> NSMutableDictionary {
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        let keychainQueryDictionary: NSMutableDictionary = [SecClass:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = KeychainWrapper.serviceName
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = keyName.data(using: String.Encoding.utf8)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}
