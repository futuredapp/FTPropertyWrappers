import Foundation

extension Mirror {
    
    func forEachChildInClassHiearchy(do block: (Child)->Void ) {
        children.forEach(block)
        superclassMirror?.forEachChildInClassHiearchy(do: block)
    }
    
}

protocol WrappedConfiguringElement {
    var constraints: [KeychainQueryPresenceConstraint] { get }
    var key: String { get }
    var wrappedAsAnonymous: Any? { get set }
}

public enum KeychainQueryPresenceConstraint {
    case override(CFString)
    case overridenBy(CFString)
}

@propertyWrapper
public final class QueryElement<T>: WrappedConfiguringElement {
    public var wrappedValue: T?
    
    let key: String
    let readOnly: Bool
    let constraints: [KeychainQueryPresenceConstraint]

    init(key: CFString, constraints: [KeychainQueryPresenceConstraint] = []){
        self.key = key as String
        self.readOnly = false
        self.constraints = constraints
    }
    
    init(readOnlyKey: CFString) {
        self.key = readOnlyKey as String
        self.readOnly = true
        self.constraints = []
    }

    var wrappedAsAnonymous: Any? {
        get { wrappedValue }
        set { wrappedValue = newValue.flatMap {$0 as? T} }
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
