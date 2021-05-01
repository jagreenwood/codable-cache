//
//  CodableCaching.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

@propertyWrapper
public final class CodableCaching<Value: Codable> {
    private lazy var codableCache: CodableCache = {
        CodableCache(self.storageType, appGroupID: appGroupID)
    }()

    private let key: Keyable
    private let storageType: StorageType
    private let appGroupID: String?
    private let ttl: TTL
    private let defaultValue: Value

    public var wrappedValue: Value {
        get {
            codableCache.object(key: key) ?? defaultValue
        }
        set {
            do {
                if let newValue = newValue as Optional<Value>?, newValue == nil {
                    try codableCache.delete(objectWith: key)
                } else {
                    try codableCache.cache(object: newValue, key: key, ttl: ttl)
                }
            } catch(let error as NSError) {
                switch error.code {
                case NSFileNoSuchFileError: break
                default:
                    debugPrint("\(#function) - \(error)")
                }
            }
        }
    }

    public init(defaultValue: Value,
                key: Keyable,
                storageType: StorageType = .temporary(.custom("codable-cache")),
                appGroupID: String? = nil,
                ttl: TTL = .default) {
        self.key = key
        self.defaultValue = defaultValue
        self.storageType = storageType
        self.appGroupID = appGroupID
        self.ttl = ttl
    }

    public init(wrappedValue: Value,
                key: Keyable,
                storageType: StorageType = .temporary(.custom("codable-cache")),
                appGroupID: String? = nil,
                ttl: TTL = .default) {
        self.key = key
        self.defaultValue = wrappedValue
        self.storageType = storageType
        self.appGroupID = appGroupID
        self.ttl = ttl
    }
}
