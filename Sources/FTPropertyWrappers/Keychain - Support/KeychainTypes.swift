import Foundation


extension Mirror {

    /// Child is any property inside a class. This convenience function provides you access to each property of a class instance. Class hiearchy is iterated from derived class to parent class. Base class's children are accessed last.
    /// - Parameter block: Code executed for each child.
    func forEachChildInClassHiearchy(do block: (Child) -> Void ) {
        children.forEach(block)
        superclassMirror?.forEachChildInClassHiearchy(do: block)
    }

}

/// Internal protocol that is used to determine which mirrored element is a QueryElement and only QueryElements should conform to this protocol.
protocol WrappedConfiguringElement {

    /// Contraints used for determine which are used to resolve incorrect combination of keys in keychain query. Calling convention applies: this collection should be empty when `readOnly` is true.
    var constraints: [KeychainQueryPresenceConstraint] { get }

    /// kSecAttr**** key at keychain query.
    var key: String { get }

    /// Determines, whether this element is read only. Calling convention applies: this property should be false when `contraints` collection is not empty.
    var readOnly: Bool { get }

    /// Type anonymous setter and getter for propety stored into or loaded from keychain query.
    var wrappedAsAnonymous: Any? { get set }
}

/// Keychain documentation provides certain rules for which key may be present in a query. Generally some keys are supposed to be nil when other keys are present. Expressing such relations in a way, that is compile-time checkable has proven to be hard. Using this type, we are able to present those relations when `QueryElement` is declared. Constraints are resolved in two steps. Firstly, query is constructed with all keys present. In second step, each key that could be removed according to contrains is removed. For example, if there is a cycle of keys that may not be in a same request, all of them are removed. Even if removing only one would be sufficient. This strategy is used, because no such a complicated relations were observed in Apple's documentation, so we can stick with rather naive solution like this.
public enum KeychainQueryPresenceConstraint {

    /// When this `QueryElement`'s value is not nil, attribute specified in this constraint is set to nil.
    case override(CFString)

    /// When attribute with this key is present in query, this `Query Element` is removed from the query.
    case overridenBy(CFString)
}


@propertyWrapper
/// Query element is envelope for a single value that represents a kSecAttr**** inside a keychain query or a keychain response. It provides user with easy-to-read API that describes relation between a value and a key. It also specifies what constraints or access permissions do apply. When request into keychain is being prepared or results are being parsed, properties of this type are going to be scanned by mirror reflecting enclosing class instance. At this time, wrapped properties and constrains are being read or written to. Notice, that if you have more than one `QueryElement` in hiearchy with the same key, behavior may be undefined. In such a case only guarantee is, that if at least one of such properties is not nil, this key will be written to query before contraints are resolved.
public final class QueryElement<T>: WrappedConfiguringElement {

    /// Value corresponding to the attribute key. *Notice: when a value of corresponding key is alredy present in the keychain, setting wrapped value to nil will not unset this attribute in keychain.*
    public var wrappedValue: T?

    /// kSecAttr**** key at keychain query.
    let key: String

    /// Determines, whether this element is read only. Calling convention applies: this property should be false when `contraints` collection is not empty.
    let readOnly: Bool

    /// Contraints used for determine which are used to resolve incorrect combination of keys in keychain query. Calling convention applies: this collection should be empty when `readOnly` is true.
    let constraints: [KeychainQueryPresenceConstraint]

    /// Type anonymous setter and getter for propety stored into or loaded from keychain query.
    var wrappedAsAnonymous: Any? {
        get { wrappedValue }
        set { wrappedValue = newValue.flatMap {$0 as? T} }
    }

    /// Creates regular query element. Elements created with this initializer are written to queries and parsed from responses. *Notice: when a value of corresponding key is alredy present in the keychain, setting wrapped value to nil will not unset this attribute in keychain.*
    /// - Parameters:
    ///   - key: Corresponding kSecAttr**** key at keychain query.
    ///   - constraints: Constraints are result of conditions described in Apple's documentation.
    init(key: CFString, constraints: [KeychainQueryPresenceConstraint] = []) {
        self.key = key as String
        self.readOnly = false
        self.constraints = constraints
    }

    /// Created query element that corresponds to read-only keychain query attribute. Such query element is not being written into a query.
    /// - Parameter readOnlyKey: Corresponding kSecAttr**** key at keychain query
    init(readOnlyKey: CFString) {
        self.key = readOnlyKey as String
        self.readOnly = true
        self.constraints = []
    }

}

/// This enum describes read and write strategy of keychain item's property wrapper.
public enum KeychainDataRefreshPolicy {

    /// This options disables all automatic read and writes. Use `try loadFromKeychain()` in oder to replace all data and attributes by data already present in keychain, `try saveToKeychain()` in order to replace data in keychain by contents of the property wrapper and `try deleteKeychain()` to delete contents of the keychain and reset data in this property wrapper. This behavior applies for both, attributes and wrapped value.
    case manual

    /// This options enables automatic read and writes trigerred by accessing or setting wrapped value. Alongside with the value all attributes will be read or written. Use `try loadFromKeychain()` and `try saveToKeychain()` when attributes were updated.
    case onAccess
}

/// `KeychainError` encapsulates common errors throws by enclosed services.
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
    case osSecureInvalidValue

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
        case errSecInvalidValue:
            self = .osSecureInvalidValue
        default:
            self = .osSecure(status: status)
        }
    }
}

/// `AccesibleOption` encapsulates all constants for attribute kSecAttrAccessible, that are present in current OS versions.
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
