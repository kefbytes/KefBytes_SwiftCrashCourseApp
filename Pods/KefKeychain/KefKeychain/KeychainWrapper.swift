//
//  KeychainWrapper.swift
//  Passwords
//
//  Created by Franks, Kent on 9/9/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import Foundation

open class KeychainWrapper {
    
    open class func set(_ key: String, value: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8)
        {
            return set(key, value: data)
        }
        return false
    }
    
    open class func set(_ key: String, value: Data) -> Bool {
        let keyQuery = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecValueData as String)   : value
        ] as [String : Any]
        SecItemDelete(keyQuery as CFDictionary)
        return SecItemAdd(keyQuery as CFDictionary, nil) == noErr
    }
    
    open class func get(_ key: String) -> NSString? {
        if let data = getData(key)
        {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        }
        return nil
    }
    
    open class func getData(_ key: String) -> Data? {
        let keyQuery = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String)  : kCFBooleanTrue,
            (kSecMatchLimit as String)  : kSecMatchLimitOne
        ] as [String : Any]
        var dataTypeRef: Unmanaged<AnyObject>?
        let status: OSStatus = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(keyQuery as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == noErr && dataTypeRef != nil
        {
            return dataTypeRef!.takeRetainedValue() as? Data
        }
        return nil
    }
    
    open class func delete(_ key: String) -> Bool {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key
        ] as [String : Any]
        return SecItemDelete(query as CFDictionary) == noErr
    }
    
    open class func clear() -> Bool {
        let keyQuery = [
            (kSecClass as String): kSecClassGenericPassword
        ]
        return SecItemDelete(keyQuery as CFDictionary) == noErr
    }
}
