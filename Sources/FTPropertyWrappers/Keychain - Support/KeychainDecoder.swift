import Foundation

struct KeychainDecoder {

    private let decoder: PropertyListDecoder = PropertyListDecoder()

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        switch type {
        case let type as Int.Type:
            return try decode(type, from: data) as! T
        case let type as Int8.Type:
            return try decode(type, from: data) as! T
        case let type as Int16.Type:
            return try decode(type, from: data) as! T
        case let type as Int32.Type:
            return try decode(type, from: data) as! T
        case let type as Int64.Type:
            return try decode(type, from: data) as! T
        case let type as UInt.Type:
            return try decode(type, from: data) as! T
        case let type as UInt8.Type:
            return try decode(type, from: data) as! T
        case let type as UInt16.Type:
            return try decode(type, from: data) as! T
        case let type as UInt32.Type:
            return try decode(type, from: data) as! T
        case let type as UInt64.Type:
            return try decode(type, from: data) as! T
        case is Float.Type:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Decoding root type Float not supported!", underlyingError: nil)
            )
        case is Float80.Type:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Decoding root type Float80 not supported!", underlyingError: nil)
            )
        case is Double.Type:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Decoding root type Double not supported!", underlyingError: nil)
            )
        case let type as Bool.Type:
            return try decode(type, from: data) as! T
        case let type as String.Type:
            return try decode(type, from: data) as! T
        case let type as URL.Type:
            return try decode(type, from: data) as! T
        case let type as Data.Type:
            return decode(type, from: data) as! T
        default:
            return try decoder.decode(T.self, from: data)
        }
    }

    private func decode(_ type: Int.Type, from data: Data) throws -> Int {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int(clamping: try decode(Int8.self, from: data))
        case MemoryLayout<Int16>.size:
            return Int(clamping: try decode(Int16.self, from: data))
        case MemoryLayout<Int32>.size:
            return Int(clamping: try decode(Int32.self, from: data))
        case MemoryLayout<Int64>.size:
            return Int(clamping: try decode(Int64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: Int8.Type, from data: Data) throws -> Int8 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int8.self) }
            return storage
        case MemoryLayout<Int16>.size:
            return Int8(clamping: try decode(Int16.self, from: data))
        case MemoryLayout<Int32>.size:
            return Int8(clamping: try decode(Int32.self, from: data))
        case MemoryLayout<Int64>.size:
            return Int8(clamping: try decode(Int64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: Int16.Type, from data: Data) throws -> Int16 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int16(clamping: try decode(Int8.self, from: data))
        case MemoryLayout<Int16>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int16.self) }
            return storage
        case MemoryLayout<Int32>.size:
            return Int16(clamping: try decode(Int32.self, from: data))
        case MemoryLayout<Int64>.size:
            return Int16(clamping: try decode(Int64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: Int32.Type, from data: Data) throws -> Int32 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int32(clamping: try decode(Int8.self, from: data))
        case MemoryLayout<Int16>.size:
            return Int32(clamping: try decode(Int16.self, from: data))
        case MemoryLayout<Int32>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int32.self) }
            return storage
        case MemoryLayout<Int64>.size:
            return Int32(clamping: try decode(Int64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: Int64.Type, from data: Data) throws -> Int64 {
        switch data.count {
        case MemoryLayout<Int8>.size:
            return Int64(clamping: try decode(Int8.self, from: data))
        case MemoryLayout<Int16>.size:
            return Int64(clamping: try decode(Int16.self, from: data))
        case MemoryLayout<Int32>.size:
            return Int64(clamping: try decode(Int32.self, from: data))
        case MemoryLayout<Int64>.size:
            let storage = data.withUnsafeBytes { $0.load(as: Int64.self) }
            return storage
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: UInt.Type, from data: Data) throws -> UInt {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt(try decode(UInt8.self, from: data))
        case MemoryLayout<UInt16>.size:
            return UInt(try decode(UInt16.self, from: data))
        case MemoryLayout<UInt32>.size:
            return UInt(try decode(UInt32.self, from: data))
        case MemoryLayout<UInt64>.size:
            return UInt(try decode(UInt64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: UInt8.Type, from data: Data) throws -> UInt8 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            return storage
        case MemoryLayout<UInt16>.size:
            return UInt8(try decode(UInt16.self, from: data))
        case MemoryLayout<UInt32>.size:
            return UInt8(try decode(UInt32.self, from: data))
        case MemoryLayout<UInt64>.size:
            return UInt8(try decode(UInt64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: UInt16.Type, from data: Data) throws -> UInt16 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt16(try decode(UInt8.self, from: data))
        case MemoryLayout<UInt16>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            return storage
        case MemoryLayout<UInt32>.size:
            return UInt16(try decode(UInt32.self, from: data))
        case MemoryLayout<UInt64>.size:
            return UInt16(try decode(UInt64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: UInt32.Type, from data: Data) throws -> UInt32 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt32(try decode(UInt8.self, from: data))
        case MemoryLayout<UInt16>.size:
            return UInt32(try decode(UInt16.self, from: data))
        case MemoryLayout<UInt32>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            return storage
        case MemoryLayout<UInt64>.size:
            return UInt32(try decode(UInt64.self, from: data))
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: UInt64.Type, from data: Data) throws -> UInt64 {
        switch data.count {
        case MemoryLayout<UInt8>.size:
            return UInt64(try decode(UInt8.self, from: data))
        case MemoryLayout<UInt16>.size:
            return UInt64(try decode(UInt16.self, from: data))
        case MemoryLayout<UInt32>.size:
            return UInt64(try decode(UInt32.self, from: data))
        case MemoryLayout<UInt64>.size:
            let storage = data.withUnsafeBytes { $0.load(as: UInt64.self) }
            return storage
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: Bool.Type, from data: Data) throws -> Bool {
        let value: Int = try decode(Int.self, from: data)
        switch value {
        case 0:
            return false
        case 1:
            return true
        default:
            throw KeychainError.generalDecodingFailure
        }
    }

    private func decode(_ type: String.Type, from data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8)
                        ?? String(data:data, encoding: .ascii) else {
            throw KeychainError.generalDecodingFailure
        }

        return string
    }

    private func decode(_ type: URL.Type, from data: Data) throws -> URL {
        guard let url = URL(string: try decode(String.self, from: data)) else {
            throw KeychainError.generalDecodingFailure
        }

        return url
    }

    private func decode(_ type: Data.Type, from data: Data) -> Data {
        return data
    }
}

