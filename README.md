<img alt="FTPropertyWrappers logo" align="right" src="Documentation/wrapper.svg">

# FTPropertyWrappers

![Swift](https://github.com/futuredapp/FTPropertyWrappers/workflows/Swift/badge.svg)

Package featuring wrappers commonly used in our projects. This package contains property wrappers for User Defaults, Keychain, StoredSubject and synchronization.

## Installation

When using Swift package manager install using Xcode 11+
or add following line to your dependencies:

```swift
.package(url: "https://github.com/futuredapp/FTPropertyWrappers.git", from: "1.2.0")
```
When using CocoaPods add following line to your `Podfile`:

```ruby
pod 'FTPropertyWrappers', '~> 1.0'
```
## Features

The main aim of this package is to provide programmer with access to commonly used features or snippets with as easy API as possible. Runtime efficiency, while important, is not the main focus of this package. As for today, this package contains wrappers for following features:

- `Serialized` is naive implementation of property living on a certain thread using Dispatch
- `GenericPassword` and `InternetPassword` are implementation of two classes storable in Keychain, with ability to inspect certain keychain item's attributes

## Usage

### `Serialized`

Searialized is a naive implementation of thread local property based on Dispatch (GCD). Special thread is created upon initialization and all read/write operations are performed on the thread. By default, read and write operations are blocking, therefore if you use read and write operation (like += on Int) two blocking operations are dispatched. 

User may provide custom label for the thread.

```swift
@Serialized var number: Int = 20
@Serialized(customQueue: "my.queue.identifier") var otherNumber: Int = 30
```

If you want to make multiple operations, dispatching multiple sync operations (and possible dead-lock) may be avoided by using `asyncAccess(transform:)` method.

```swift
_number.asyncAccess { current -> Int in
    var someAggregator = current
    for 0...10 {
        someAggregator += current
    }
    return someAggregator
}
```

### `GenericPassword` 

Generic Password is property wrappech which makes possible to store data in Keychain as `kSecClassGenericPassword` keychain item class. It allowes to store any `Codable` data type including single values like `Int` or `String`.  Our implementation has also some advanced features like inspecting and modifying attributes. However, the main aim is to avoid putting uneeded syntax burden on user. Just keep in mind, that some attributes, like `service` is required by implementation in order to identify data in keychain and provide stable property wrapper API.

```swift
@GenericPassword(service: "my.service") var myName: String?
myName = "Peter Parker"
@GenericPassword(service: "my.service") var otherProperty: String?
print(otherProperty) // prints Optional("Peter Parker")
```

As you can see, property was loaded and stored upon access. It is possible to disable such a behavior. However, if you want inspect and modify attributes of the keychain item, like for example `comment`, you need to load the keychain item manually and store it manually. Due to limitations in C-based API, we're not able to reset (delete) an attribute once it's set. You would need to delete and re-insert the item into keychain.

```swift
@GenericPassword(service: "my.service") var myName: String?
try _myName.loadFromKeychain()
_myName.comment = "This is name of a secret hero! Do not show it on public!"
try _myName.saveToKeychain()
```

If you want to delete item from keychain, simply set wrapped property to nil and save it to the keychain. You can also delete the item manually. 

```swift
@GenericPassword(service: "my.service") var myName: String?
myName = nil // Deletes immediately since myName is saved upon access
try _myName.saveToKeychain() // Deletes since wrapped property is nil
try _myName.deleteKeychain() // Explicit delete.
```
Access control enables you to specify which authentication method should be used before access to data of keychain item is granted. For example, app may create its own password or require biometric authentication. Generic password wrapper allows you to modify access parameters of an item. Two different approaches are possible. Define new access control modifiers before each write or define default access control parameters for the wrapper instance. In the latter case, access control modifiers are instantiated upon save when `kSecAccessControl` attribute is nil. This may result in exception resulting in save operation abortion. Example of generic password with access control can be found in the example project in this repository.

```swift
// Example declaration of GenericPassword with access control from exaple project
@GenericPassword(
    service: "app.futured.ftpropertywrappers.example.name",
    account: "example@futred.com",
    refreshPolicy: .manual,
    accessOption: kSecAttrAccessibleWhenUnlocked,
    accessFlags: [.biometryAny, .or, .devicePasscode]
) var data: Hidden?
```
![Biometry example](Documentation/example.gif)

Internally, all keychain property wrappes use coders which encode single value types in a specific way (refer to `KeychainEncoder` and `KeychainDecoder` structures for more details) and for keyed value types or collections uses binary Plist. However, in case that default coding is not desired, using type `Data` as generic type will provide user with bare data as loaded and stored in keychain. Use this approarch, for example, to store or load Utf16 encoded strings or JSON encoded keyed containers.

```swift
@GenericPassword(service: "my.service") var myData: Data?
```

### `InternetPassword`

Internet password is keychain item class which is aimed at storing and organizing password for various internet services. It takes a huge advantage of attributes however, lacks biometric authentication support.

```swift 
@InternetPassword(
    server: "my.server",
    account: "my.account",
    domain: "my.domain",
    aProtocol: kSecAttrProtocolSSH,
    authenticationType: kSecAttrAuthenticationTypeHTMLForm,
    port: 8080,
    path: "/a/b/c"
) var myPassword: String?
```

Notice, that each argument in example above is park of "primary key" and omitting any of them may result in ambiguity. Following example will demonstrate two property wrappers with different declarations however with only one record in keychain.


```swift 
@InternetPassword(
    server: "my.server",
    account: "my.account",
    domain: "my.domain",
    aProtocol: kSecAttrProtocolSSH,
    authenticationType: kSecAttrAuthenticationTypeHTMLForm,
    port: 8080,
    path: "/a/b/c"
) var declA: String?
@InternetPassword(
    server: "my.server",
    account: "my.account"
) var declB: String?

declA = "The Valley Wind"
print(declB) // Prints Optional("The Valley Wind")
```

But different run with properties swapped will have different results.

```swift 
declB = "The Valley Wind"
print(declA) // Prints nil
```

Let's consider third example, where we have property named `declC` that deffers from `declA` at `aProtocol` attribute. This will result in two different records in keychain. Which value will be displayed by `declB`?

```swift 
@InternetPassword(
    server: "my.server",
    account: "my.account",
    domain: "my.domain",
    aProtocol: kSecAttrProtocolFTP,
    authenticationType: kSecAttrAuthenticationTypeHTMLForm,
    port: 8080,
    path: "/a/b/c"
) var declc: String?

declC = "The Sixth Station"
declA = "The Valley Wind"
print(declB) // Prints Optional("The Sixth Station")
try _declC.deleteKeychain()
print(declB) // Prints Optional("The Valley Wind")
```

It appears, that in case of ambiguity, element with the oldest `creationDate` is selected as the result. This statement has no basis in documentation, however is tested in unit tests. Same considertation do apply for other keychain item classes.

## Migration notes

### 1.2.0

`@UserDefaults` was removed in favor of  [`@AppStorage`](https://developer.apple.com/documentation/swiftui/appstorage/) in iOS 14+.
`@StoredSubject` was removed in favor of  [`CurrentValueSubject`](https://developer.apple.com/documentation/combine/currentvaluesubject) in iOS 13+.

### 1.0.0

During this migration process, code breaking changes were made only to Keychain property wrappers. Other changes were additive. In order to successfully migrate your Keychain related code, you have to take four steps.

1. Change all `KeychainStore`, `CodableKeychainAdapter` or `KeychainAdapter` variables to `@GenericPassword`.
2. The `key` you provided to old implementation represents `account` of the `GenericPassword` in the new implementation.
3. The `service` attribute is represented by `serviceIdentifier` in old implementation. Its value is  `Bundle.main.bundleIdentifier! + ".securedomain.default"` in case you use `CodableKeychainAdapter.defaultDomain`.
4. In case you use coding implementation of `CodableKeychainAdapter` for composed types, you'll need to provide decoding code yourself, since the new implementation uses Plist instead of JSON. Simply use type `Data` as the generic parameter for the new `GenericPassword` property wrapper and use any coding method you need. _You'll find additional information on that matter above._

## Contributors

Current maintainer and main contributor is [Mikoláš Stuchlík](https://github.com/mikolasstuchlik), <mikolas.stuchlik@futured.app>.

We want to thank other contributors, namely:

- [Matěj Kašpar Jirásek](https://github.com/mkj-is)

## License

FTPropertyWrappers is available under the MIT license. See the [LICENSE file](LICENSE) for more information.
