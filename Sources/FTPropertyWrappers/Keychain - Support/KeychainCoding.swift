import Foundation

struct KeychainCoding {

    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()

    private let decoder: PropertyListDecoder = PropertyListDecoder()

    func encode<T: Encodable>(_ value: T) throws -> Data {
        switch value {
        case let value as Int:
            return try encode(value)
        case let value as Int8:
            return try encode(value)
        case let value as Int16:
            return try encode(value)
        case let value as Int32:
            return try encode(value)
        case let value as Int64:
            return try encode(value)
        case let value as UInt:
            return try encode(value)
        case let value as UInt8:
            return try encode(value)
        case let value as UInt16:
            return try encode(value)
        case let value as UInt32:
            return try encode(value)
        case let value as UInt64:
            return try encode(value)
        case is Float:
            fatalError("Encoding root type Float not supported!")
        case is Float80:
            fatalError("Encoding root type Float80 not supported!")
        case is Double:
            fatalError("Encoding root type Double not supported!")
        case let value as Bool:
            return try encode(value)
        case let value as String:
            return try encode(value)
        case let value as URL:
            return try encode(value)
        case let value as Data:
            return try encode(value)
        default:
            return try encoder.encode(value)
        }
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        switch type {
        case is Int.Type:
            return (try decode(from: data) as Int) as! T
        case is Int8.Type:
            return (try decode(from: data) as Int8) as! T
        case is Int16.Type:
            return (try decode(from: data) as Int16) as! T
        case is Int32.Type:
            return (try decode(from: data) as Int32) as! T
        case is Int64.Type:
            return (try decode(from: data) as Int64) as! T
        case is UInt.Type:
            return (try decode(from: data) as UInt) as! T
        case is UInt8.Type:
            return (try decode(from: data) as UInt8) as! T
        case is UInt16.Type:
            return (try decode(from: data) as UInt16) as! T
        case is UInt32.Type:
            return (try decode(from: data) as UInt32) as! T
        case is UInt64.Type:
            return (try decode(from: data) as UInt64) as! T
        case is Float.Type:
            fatalError("Encoding root type Float not supported!")
        case is Float80.Type:
            fatalError("Encoding root type Float80 not supported!")
        case is Double.Type:
            fatalError("Encoding root type Double not supported!")
        case is Bool.Type:
            return (try decode(from: data) as Bool) as! T
        case is String.Type:
            return (try decode(from: data) as String) as! T
        case is URL.Type:
            return (try decode(from: data) as URL) as! T
        case is Data.Type:
            return (try decode(from: data) as Data) as! T
        default:
            return try decoder.decode(T.self, from: data)
        }

    }

    // MARK: - Encoders overloaded
    private func encode(_ value: Int) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int8) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int16) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int32) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: Int64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    private func encode(_ value: UInt) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt8) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt16) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt32) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: UInt64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    private func encode(_ value: Bool) throws -> Data {
        return try encode( value ? 1 : 0)
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

    private func encode(_ value: Data) throws -> Data {
        return value
    }

    // MARK: - Decoders overloaded

    private func decode(from data: Data) throws -> Int {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int(clamping: try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int(clamping: try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int(clamping: try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int(clamping: try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> Int8 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int8.self) }
            return storage
        case MemoryLayout<Int16>.size:
            return Int8(clamping: try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int8(clamping: try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int8(clamping: try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> Int16 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int16(clamping: try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int16.self) }
            return storage
        case MemoryLayout<Int32>.size:
            return Int16(clamping: try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int16(clamping: try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> Int32 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int32(clamping: try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int32(clamping: try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int32.self) }
            return storage
        case MemoryLayout<Int64>.size:
            return Int32(clamping: try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> Int64 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int64(clamping: try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int64(clamping: try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int64(clamping: try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int64.self) }
            return storage
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> UInt {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> UInt8 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            return storage
        case MemoryLayout<UInt16>.size:
            return UInt8(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt8(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt8(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> UInt16 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt16(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            return storage
        case MemoryLayout<UInt32>.size:
            return UInt16(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt16(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> UInt32 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt32(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt32(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            return storage
        case MemoryLayout<UInt64>.size:
            return UInt32(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> UInt64 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt64(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt64(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt64(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt64.self) }
            return storage
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> Bool {
        let value: Int = try decode(from: data)
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(from data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8)
                        ?? String(data:data, encoding: .ascii) else {
            throw KeychainError.generalDecodingFailure
        }

        return string
    }

    private func decode(from data: Data) throws -> URL {
        let string: String = try decode(from: data)
        guard let url = URL(string: string) else {
            throw KeychainError.generalDecodingFailure
        }

        return url
    }

    private func decode(from data: Data) throws -> Data {
        return data
    }
}
