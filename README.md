# FTPropertyWrappers

![Swift](https://github.com/futuredapp/FTPropertyWrappers/workflows/Swift/badge.svg)

Commonly used features implemented in Swift's property wrapper layer. This package contains wrappers for User Defaults, Keychain, Publisher and synchronization.

## Installation

When using Swift package manager install using Xcode 11+
or add following line to your dependencies:

```swift
.package(url: "https://github.com/futuredapp/FTPropertyWrappers.git", from: "1.0.0")
```
When using CocoaPods add following line to your `Podfile`:

```ruby
pod 'FTPropertyWrappers', '~> 1.0'
```
## Features

The main aim of this package is to provide programmer with access to commonly used features or snippets with as easy API as possible. Runtime efficiency, while important, is not the main focus of this package. As for today, this package contains wrappers for following features:

- `UserDefaults<T>` for storing a value inside Foundation's User Defaults
- `StoredSubject<T>` which is simple multidelegate/observing primitive for Swift
- `Serialized<T>` is naive implementation of property living on a certain thread using Dispatch
- `GenericPassword<T>` and `InternetPassword<T>` are implementation of two classes storable in Keychain, with ability to inspect certain keychain item's attributes

## Usage

### `UserDefaults<T>`

User Defaults property wrapper uses two main approaches for storing data in User Defaults. Primary approach is usage of Plist coders. If a data type can't be encoded using Plist coders, value is passed directly to User Default. When creating property wrapper, you have to provide key. All properties wrapped in this property wrapper have to be optional. 

```swift
// Stored via User Default's method
@DefaultsStore(key: "key.for.number") var number: Int?

// Stored as `Data` encoded by Plist coder
struct Person: Codable {
    let age: Int
    let name: String
}
@DefaultsStore(key: "key.for.person") var person: Person?
```

Data are stored into `UserDefaults.standard` instance as a default. This behavior may be changed, if user provides custom `UserDefaults` instance with custom configuration. The same approach applies for Plist encoder/decoder.

User may provide `defaultValue` during initialization. This value is returned as the property wrapper's value, in case that decoding process failed and/or there is no such value in the store. 

```swift
// Stored via User Default's method
@DefaultsStore(key: "key.for.number", defaultValue: 10) var number: Int?

print(number) // Prints: Optional(10)
number = 30
print(number) // Prints: Optional(30)
number = nil
print(number) // Prints: Optional(10)
```

### `StoredSubject<T>`
TODO:

### `Serialized<T>`

### `GenericPassword<T>` 

### `InternetPassword<T>`

## Contributors

Current maintainer and main contributor is [Mikoláš Stuchlík](https://github.com/mikolasstuchlik), <mikolas.stuchlik@futured.app>.

We want to thank other contributors, namely:

- [Matěj Kašpar Jirásek](https://github.com/mkj-is)

## License

FTPropertyWrappers is available under the MIT license. See the [LICENSE file](LICENSE) for more information.
