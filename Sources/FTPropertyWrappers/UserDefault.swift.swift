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

final class DefaultsStore<Value: Codable> {

    private let defaults: UserDefaults

    private let encoder: PropertyListEncoder
    private let decoder: PropertyListDecoder

    private let key: String
    private let initialValue: Value?

    init(initialValue: Value? = nil, key: String = #function, defaults: UserDefaults = .standard, encoder: PropertyListEncoder = PropertyListEncoder(), decoder: PropertyListDecoder = PropertyListDecoder()) {
        self.key = key
        self.initialValue = initialValue
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    var value: Value? {
        get {
            if let data = defaults.data(forKey: key), let value = try? decoder.decode(Value.self, from: data) {
                return value
            } else if let value = defaults.value(forKey: key) as? Value {
                return value
            }
            return initialValue
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
