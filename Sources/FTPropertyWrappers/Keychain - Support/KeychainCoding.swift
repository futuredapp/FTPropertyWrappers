import Foundation

struct KeychainCoding {

    private let encoder: PropertyListEncoder = {
        let newEncoder = PropertyListEncoder()
        newEncoder.outputFormat = .binary
        return newEncoder
    }()

    private let decoder: PropertyListDecoder = PropertyListDecoder()

    func encode(_ value: Int) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int8) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int16) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int32) throws -> Data {
        var data = Int64(value)
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: Int64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<Int64>.size)
    }

    func encode(_ value: UInt) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt8) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt16) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt32) throws -> Data {
        var data = UInt64(value)
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: UInt64) throws -> Data {
        var data = value
        return Data(bytes: &data, count: MemoryLayout<UInt64>.size)
    }

    func encode(_ value: Float) throws -> Data {
        fatalError("Encoding root type Float not supported!")
    }

    func encode(_ value: Float80) throws -> Data {
        fatalError("Encoding root type Float80 not supported!")
    }

    func encode(_ value: Double) throws -> Data {
        fatalError("Encoding root type Double not supported!")
    }

    func encode(_ value: Bool) throws -> Data {
        return try encode( value ? 1 : 0)
    }

    func encode(_ value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.generalEncodingFailure
        }
        return data
    }

    // TODO: Fix URL
    func encode(_ value: URL) throws -> Data {
        return try encode(value.absoluteString)
    }

    func encode(_ value: Data) throws -> Data {
        return value
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }


    func decode(from data: Data) throws -> Int {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int8 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int8(current)
            }
        case MemoryLayout<Int16>.size:
            return Int8(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int8(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int8(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int16 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int16(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int16(current)
            }
        case MemoryLayout<Int32>.size:
            return Int16(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return Int16(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int32 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int32(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int32(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int32(current)
            }
        case MemoryLayout<Int64>.size:
            return Int32(try decode(from: data) as Int64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Int64 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int64(try decode(from: data) as Int8)
        case MemoryLayout<Int16>.size:
            return Int64(try decode(from: data) as Int16)
        case MemoryLayout<Int32>.size:
            return Int64(try decode(from: data) as Int32)
        case MemoryLayout<Int64>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | Int64(current)
            }
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt {
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

    func decode(from data: Data) throws -> UInt8 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt8(current)
            }
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

    func decode(from data: Data) throws -> UInt16 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt16(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt16(current)
            }
        case MemoryLayout<UInt32>.size:
            return UInt16(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return UInt16(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt32 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt32(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt32(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt32(current)
            }
        case MemoryLayout<UInt64>.size:
            return UInt32(try decode(from: data) as UInt64)
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> UInt64 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt64(try decode(from: data) as UInt8)
        case MemoryLayout<UInt16>.size:
            return UInt64(try decode(from: data) as UInt16)
        case MemoryLayout<UInt32>.size:
            return UInt64(try decode(from: data) as UInt32)
        case MemoryLayout<UInt64>.size:
            return data.reduce(into: 0) { result, current in
                result = (result << 8) | UInt64(current)
            }
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    func decode(from data: Data) throws -> Float {
        fatalError("Encoding root type Float not supported!")
    }

    func decode(from data: Data) throws -> Float80 {
        fatalError("Encoding root type Float80 not supported!")
    }

    func decode(from data: Data) throws -> Double {
        fatalError("Encoding root type Double not supported!")
    }

    func decode(from data: Data) throws -> Bool {
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

    func decode(from data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8)
                        ?? String(data:data, encoding: .ascii) else {
            throw KeychainError.generalDecodingFailure
        }

        return string
    }

    // TODO: Fix URL
    func decode(from data: Data) throws -> URL {
        guard let string: String = try decode(from: data), let url = URL(string: string) else {
            throw KeychainError.generalDecodingFailure
        }

        return url
    }

    func decode(from data: Data) throws -> Data {
        return data
    }

    func decode<T: Decodable>(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }

}
