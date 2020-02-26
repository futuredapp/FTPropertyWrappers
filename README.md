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
