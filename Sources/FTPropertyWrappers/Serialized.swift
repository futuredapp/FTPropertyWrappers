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

/// This class provides user with easy way to serialize access to a property in multiplatform environment. This class is written with future PropertyWrapper feature of swift in mind.
final class Serialized<Value> {

    /// Synchronization queue for the property. Read or write to the property must be perforimed on this queue
    private let queue = DispatchQueue(label: "com.thefuntasty.ftapikit.serialization")

    /// The value itself with did-set observing.
    private var value: Value {
        didSet {
            didSet?(value)
        }
    }

    /// Did set observer for stored property. Notice, that didSet event is called on the synchronization queue. You should free this thread asap with async call, since complex operations would slow down sync access to the property.
    var didSet: ((Value) -> Void)?

    /// Inserting initial value to the property. Notice, that this operation is NOT DONE on the synchronization queue.
    init(initialValue: Value) {
        value = initialValue
    }

    /// It is enouraged to use this method to make more complex operations with the stored property, like read-and-write. Do not perform any time-demading operations in this block since it will stop other uses of the stored property.
    func asyncAccess(transform: @escaping (Value) -> Value) {
        queue.async {
            self.value = transform(self.value)
        }
    }
}
