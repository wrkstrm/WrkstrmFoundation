//
//  Archiving.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 7/9/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public struct CodableArchiver<T: Codable> {

    public let encoder: JSONEncoder

    public let decoder: JSONDecoder

    public let fileManager: FileManager = FileManager.default

    public let archiveDirectory: URL

    public let key: AnyHashable

    public init(key: AnyHashable,
                directory: FileManager.SearchPathDirectory,
                encoder: JSONEncoder = .default,
                decoder: JSONDecoder = .default,
                searchPathDomainMask: FileManager.SearchPathDomainMask = [.allDomainsMask]) {
        self.encoder = encoder
        self.decoder = decoder
        let archiveDirectory = fileManager.urls(for: directory, in: searchPathDomainMask).first!
        self.archiveDirectory = archiveDirectory.appendingPathComponent(String(key.description))
        self.key = key
    }

    public init(directory: URL,
                encoder: JSONEncoder = .default,
                decoder: JSONDecoder = .default) {
        self.encoder = encoder
        self.decoder = decoder
        self.archiveDirectory = directory.deletingLastPathComponent()
        self.key = directory.lastPathComponent
    }
}

// MARK: - Filemanager helpers

extension CodableArchiver {
    public func filePathForKey(_ key: AnyHashable) -> String {
        return archiveDirectory.appendingPathComponent(String(key.description)).path
    }
}

// MARK: - workflow operations

extension CodableArchiver {

    public func get(_ key: AnyHashable? = nil) -> T? {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePathForKey(key ?? self.key)) as? Data else {
            return nil
        }

        guard let decoded = try? decoder.decode(T.self, from: data) else {
            return nil
        }

        return decoded
    }

    @discardableResult
    public func set(_ value: T, forKey key: AnyHashable? = nil) -> Bool {
        let data = try? encoder.encode(value)
        try? fileManager.createDirectory(at: archiveDirectory,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        if let data = data {
            return NSKeyedArchiver.archiveRootObject(data, toFile: filePathForKey(key ?? self.key))
        } else {
            return false
        }
    }

    @discardableResult
    public func set(_ value: [T], forKey key: AnyHashable? = nil) -> Bool {
        let encodedValues = try? value.map { try encoder.encode($0) }
        try? fileManager.createDirectory(at: archiveDirectory,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        if let encodedValues = encodedValues {
            return NSKeyedArchiver.archiveRootObject(encodedValues, toFile: filePathForKey(key ?? self.key))
        } else {
            return false
        }
    }

    public func clear() throws {
        try fileManager.removeItem(at: archiveDirectory)
    }
}
