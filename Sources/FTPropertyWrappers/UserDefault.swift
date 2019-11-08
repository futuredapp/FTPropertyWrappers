import Foundation

@propertyWrapper
/// Property wrapper for storing Codable values in UserDefaults store.
public final class DefaultsStore<Value: Codable> {

    /// User defaults store used for this property
    private let defaults: UserDefaults

    /// Encoder used to encode complex types
    private let encoder: PropertyListEncoder

    /// Dencoder used to decode complex types
    private let decoder: PropertyListDecoder

    /// Key for encoled property, programmer is responsible for keeping this key unique in target UserDefaults domain.
    private let key: String

    /// Default valure returned by enclodes property getter in case, that property is not found in the UserDefaults
    private let defaultValue: Value?

    /// Initializer for user defaults property wrapper.
    /// - Parameters:
    ///   - key: Key for encoled property, programmer is responsible for keeping this key unique in target UserDefaults domain
    ///   - defaultValue: User defaults store used for this property
    ///   - defaults: Default valure returned by enclodes property getter in case, that property is not found in the UserDefaults
    ///   - encoder: Encoder used to encode complex types
    ///   - decoder: Dencoder used to decode complex types
    public init(key: String, defaultValue: Value? = nil, defaults: UserDefaults = .standard, encoder: PropertyListEncoder = PropertyListEncoder(), decoder: PropertyListDecoder = PropertyListDecoder()) {
        self.key = key
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
        self.defaultValue = defaultValue
    }

    /// Getter and setter for enclosed property. Property itself is not stored in this class and is always returned and stored from/in UserDefaults. This computed property attempts to store/load type as if it was a complex propety first. In case it is not encodable/decodable, this getter attemts to retrieve it it's raw form and cast it into requested type, thus being able to store default primitive types such as int or other types such as String. If those attempts fail, default value is returned. Setter also tries to store enclosed type as encoded value, otherwise it calls default set(:forKey:) method, thus storing primitive types such as int.
    public var wrappedValue: Value? {
        get {
            if let data = defaults.data(forKey: key), let value = try? decoder.decode(Value.self, from: data) {
                return value
            } else if let value = defaults.value(forKey: key) as? Value {
                return value
            }
            return defaultValue
        }
        set {
            if let data = try? encoder.encode(newValue) {
                defaults.set(data, forKey: key)
            } else if newValue == nil {
                defaults.removeObject(forKey: key)
            } else {
                defaults.set(newValue, forKey: key)
            }
        }
    }
}
