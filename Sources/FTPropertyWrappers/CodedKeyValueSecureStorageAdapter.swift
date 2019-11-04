// MIT License
//
// Copyright (c) 2019 The FUNTASTY
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
// Made with <3 at Funtasty

import Foundation

protocol JSONCodedKeyValueSecureStorageAdapter: KeyValueSecureStorageAdapter {
    var jsonEncoder: JSONEncoder { get }
    var jsonDecoder: JSONDecoder { get }

    func load<Property: Codable>(for key: String) throws -> Property
    func save<Property: Codable>(value: Property, for key: String) throws
}

extension JSONCodedKeyValueSecureStorageAdapter {
    func load<Property: Codable>(for key: String) throws -> Property {
        let saved: Data = try load(for: key)
        return try jsonDecoder.decode(Property.self, from: saved)
    }

    func save<Property: Codable>(value: Property, for key: String) throws {
        let data = try jsonEncoder.encode(value)
        try save(value: data, for: key)
    }
}

final class CodableKeychainAdapter: KeychainAdapter, JSONCodedKeyValueSecureStorageAdapter {

    let jsonDecoder: JSONDecoder
    let jsonEncoder: JSONEncoder

    init(serviceIdentifier: String, biometricAuthRequired: Bool, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder

        super.init(serviceIdentifier: serviceIdentifier, biometricAuthRequired: biometricAuthRequired)
    }
}

final class CodableKeychainElement<Property> where Property: Codable {
    let key: String
    let storageAdapter: JSONCodedKeyValueSecureStorageAdapter

    init(storageAdapter: JSONCodedKeyValueSecureStorageAdapter, key: String) {
        self.storageAdapter = storageAdapter
        self.key = key
    }

    var value: Property? {
        get {
            return try? storageAdapter.load(for: key)
        }
        set {
            guard let newValue = newValue else {
                try? storageAdapter.delete(for: key)
                return
            }

            try? storageAdapter.save(value: newValue, for: key)
        }
    }
}

enum LegacyKeychainError: Error {
    case unexpectedTypeFound
}

struct LegacyCredentialFormat {
    let userId: NSNumber?
    let refresh: String?
    let access: String?
}

final class LegacyKeychainElement {
    private let storageAdapter: KeyValueSecureStorageAdapter

    init(storageAdapter: KeyValueSecureStorageAdapter) {
        self.storageAdapter = storageAdapter
    }

    private let legacyUserIdKey: String = "user_id"
    private let legacyRefreshTokenKey: String = "refresh_token"
    private let legacyAccessTokenKey: String = "access_token"

    public func attemptLoad() throws -> LegacyCredentialFormat {
        let keychainEncoded = try storageAdapter.loadAll()
        guard let data = keychainEncoded.first?.1 else {
            throw LegacyKeychainError.unexpectedTypeFound
        }

        guard let decodedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else {
            throw LegacyKeychainError.unexpectedTypeFound
        }

        return LegacyCredentialFormat(userId: decodedData[legacyUserIdKey] as? NSNumber,
                                      refresh: decodedData[legacyRefreshTokenKey] as? String,
                                      access: decodedData[legacyAccessTokenKey] as? String)
    }

    public func purgeKeychain() throws {
        try storageAdapter.deleteAll()
    }
}

typealias KeychainQuery = [String: AnyObject]

enum KeychainError: Error {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
}

protocol KeyValueSecureStorageAdapter {
    func load(for key: String) throws -> Data
    func loadAll() throws -> [(String, Data)]
    func save(value: Data, for key: String) throws
    func deleteAll() throws
    func delete(for key: String) throws
}

class KeychainAdapter: KeyValueSecureStorageAdapter {
    let serviceIdentifier: String
    let biometricAuthRequired: Bool

    init(serviceIdentifier: String, biometricAuthRequired: Bool) {
        self.serviceIdentifier = serviceIdentifier
        self.biometricAuthRequired = biometricAuthRequired
    }

    func load(for key: String) throws -> Data {
        let queryResult: AnyObject? = try getResult(account: key, single: true)

        guard let item = queryResult as? KeychainQuery, let data = item[kSecValueData as String] as? Data else {
            throw KeychainError.unexpectedData
        }

        return data
    }

    func loadAll() throws -> [(String, Data)] {
        let queryResult: AnyObject? = try getResult(account: nil, single: false)

        guard let array = queryResult as? [[String: Any]] else {
            throw KeychainError.unexpectedData
        }

        var values = [(String, Data)]()

        for item in array {
            if let key = item[kSecAttrAccount as String] as? String,
                let value = item[kSecValueData as String] as? Data {
                values.append((key, value))
            }
        }

        return values
    }

    func save(value: Data, for key: String) throws {
        // delete item if already exists
        var deleteQuery = getQuery(account: key)
        deleteQuery[kSecReturnData as String] = kCFBooleanFalse
        SecItemDelete(deleteQuery as CFDictionary)

        var newQuery = getQuery(account: key)
        newQuery[kSecValueData as String] = value as AnyObject
        if biometricAuthRequired {
            let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
            newQuery[kSecAttrAccessControl as String] = sacObject!
        }

        let status = SecItemAdd(newQuery as CFDictionary, nil)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func deleteAll() throws {
        let query = getQuery()
        let status = SecItemDelete(query as CFDictionary)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func delete(for key: String) throws {
        var deleteQuery = getQuery(account: key)
        deleteQuery[kSecReturnData as String] = kCFBooleanFalse
        let status = SecItemDelete(deleteQuery as CFDictionary)

        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }
    }

    private func getResult(account: String? = nil, single: Bool, biometricAuthMessage: String? = nil) throws -> AnyObject? {
        var query = getQuery(account: account)
        query[kSecMatchLimit as String] = single ? kSecMatchLimitOne : kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        if biometricAuthRequired {
            query[kSecUseOperationPrompt as String] = (biometricAuthMessage ?? "Authenticate to login") as AnyObject
        }

        // fetch the existing keychain item that matches the query
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // handle errors
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }
        if status != noErr {
            throw KeychainError.unhandledError(status: status)
        }

        return queryResult
    }

    private func getQuery(account: String? = nil) -> KeychainQuery {
        var query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier as AnyObject
        ]
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }
        return query
    }
}
