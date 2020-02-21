import Foundation

struct KeychainEncoder {

    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()

    func encode<T: Encodable>(_ value: T) throws -> Data {
        switch value {
        case let value as Int:
            return encode(value)
        case let value as Int8:
            return encode(value)
        case let value as Int16:
            return encode(value)
        case let value as Int32:
            return encode(value)
        case let value as Int64:
            return encode(value)
        case let value as UInt:
            return encode(value)
        case let value as UInt8:
            return encode(value)
        case let value as UInt16:
            return encode(value)
        case let value as UInt32:
            return encode(value)
        case let value as UInt64:
            return encode(value)
        case is Float.Type:
            throw EncodingError.invalidValue( value,
                EncodingError.Context(codingPath: [], debugDescription: "Encoding root type Float not supported!", underlyingError: nil)
            )
        case is Float80.Type:
            throw EncodingError.invalidValue( value,
                EncodingError.Context(codingPath: [], debugDescription: "Encoding root type Float80 not supported!", underlyingError: nil)
            )
        case is Double.Type:
            throw EncodingError.invalidValue( value,
                EncodingError.Context(codingPath: [], debugDescription: "Encoding root type Double not supported!", underlyingError: nil)
            )
        case let value as Bool:
            return encode(value)
        case let value as String:
            return try encode(value)
        case let value as URL:
            return try encode(value)
        case let value as Data:
            return encode(value)
        default:
            return try encoder.encode(value)
        }
    }

    private func encode(_ value: Int) -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int8) -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int16) -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int32) -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int64) -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: UInt) -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt8) -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt16) -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt32) -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt64) -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: Bool) -> Data {
        return encode( value ? 1 : 0)
    }

    private func encode(_ value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.generalEncodingFailure
        }
        return data
    }

    private func encode(_ value: URL) throws -> Data {
        return try encode(value.absoluteString)
    }

    private func encode(_ value: Data) -> Data {
        return value
    }

}
