//
//  File.swift
//  
//
//  Created by Mikoláš Stuchlík on 15/02/2020.
//

import Foundation

extension Mirror {
    
    func forEachChildInClassHiearchy(do block: (Child)->Void ) {
        children.forEach(block)
        superclassMirror?.forEachChildInClassHiearchy(do: block)
    }
    
}

protocol ConfiguringElement {
    func insertParameters(into query: inout [String : Any])
    func readParameters(from response: [String : Any])
}

@propertyWrapper
public final class QueryElement<T>: ConfiguringElement {
    public var wrappedValue: T?
    
    let key: String
    let unsets: String?
    let unsetBy: String?
    
    init(key: CFString, unsets: CFString? = nil, unsetBy: CFString? = nil){
        self.key = key as String
        self.unsets = unsets as String?
        self.unsetBy = unsetBy as String?
    }
    
    func insertParameters(into query: inout [String : Any]) {
        if unsetBy.flatMap({ query[$0] }) == nil {
            unsets.flatMap { query[$0] = nil }
            query[key] = wrappedValue
        }
    }

    func readParameters(from response: [String : Any]) {
        wrappedValue = response[key] as? T
    }
}

public enum KeychainDataRefreshPolicy {
    case manual, onAccess
}

public enum KeychainError: Error {
    case unexpectedFormat, generalEncodingFailure, generalDecodingFailure
    case accessControllErrorUnknown
    case accessControllError(status: Error)
    case osSecure(status: OSStatus)
    case osSecureDuplicitItem
    case osSecureNoSuchItem
    case osSecureDiskFull
    case osSucureInvalidParameter
    case osSecureBadRequest
    case osSecureUserCancelledAuthentication
    case osSecureMissingEtitlementForThisFeature

    init(fromOSStatus status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .osSecureDuplicitItem
        case errSecItemNotFound:
            self = .osSecureNoSuchItem
        case errSecDiskFull:
            self = .osSecureDiskFull
        case errSecParam:
            self = .osSucureInvalidParameter
        case errSecBadReq:
            self = .osSecureBadRequest
        case errSecUserCanceled:
            self = .osSecureUserCancelledAuthentication
        case errSecMissingEntitlement:
            self = .osSecureMissingEtitlementForThisFeature
        default:
            self = .osSecure(status: status)
        }
    }
}

public enum AccesibleOption: CaseIterable {
    case whenPasswordSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case whenUnlocked
    case afterFirstUnlockThisDeviceOnly
    case afterFirstUnlock

    public var rawValue: CFString {
        switch self {
        case .whenPasswordSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        }
    }

    public init?(rawValue: CFString) {
        guard let value = AccesibleOption.allCases.first(where: { rawValue == $0.rawValue }) else {
            return nil
        }
        self = value
    }
}
