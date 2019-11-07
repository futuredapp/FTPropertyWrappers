import Foundation

@propertyWrapper
public final class DefaultsStore<Value: Codable> {

    private let defaults: UserDefaults

    private let encoder: PropertyListEncoder
    private let decoder: PropertyListDecoder

    private let key: String
    private let defaultValue: Value?

    public init(key: String, defaultValue: Value? = nil, defaults: UserDefaults = .standard, encoder: PropertyListEncoder = PropertyListEncoder(), decoder: PropertyListDecoder = PropertyListDecoder()) {
        self.key = key
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
        self.defaultValue = defaultValue
    }

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
