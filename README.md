# FreeformJSON: Type-safe freeform JSON data structure with Codable support for Swift

[![License](https://img.shields.io/cocoapods/l/FreeformJSON.svg?style=flat)](https://github.com/fabiorodella/FreeformJSON/blob/master/LICENSE) ![Platform](https://img.shields.io/cocoapods/p/FreeformJSON.svg?style=flat) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FreeformJSON.svg)](https://img.shields.io/cocoapods/v/FreeformJSON.svg) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift PM Compatible](https://img.shields.io/badge/Swift%20PM-compatible-4BC51D.svg)](https://swift.org/package-manager/) [![Coverage Status](https://coveralls.io/repos/github/fabiorodella/FreeformJSON/badge.svg?branch=master)](https://coveralls.io/github/fabiorodella/FreeformJSON?branch=master)

FreeformJSON is a tiny data structure that allows you to create and/or access freeform JSON data in a type safe manner, while still enjoying the benefits of the Codable protocol. This can be useful if there are parts of your model that you want to have access to, but don't want the overhead of having a  `class`/`struct` for it.

## Examples

### Use inside other `Codable` data structures
```swift
import FreeformJSON

struct Post: Codable {
    let name: String
    let embeddedContent: JSON
}
...
let link = post.embeddedContent["origin"]["link"].string
```

### Create from literal values
```swift
let post: JSON = [
    "name": "My Post",
    "rating": 4,
    "hidden": false,
    "tags": ["tag1", "tag2"]
]
```

### Create from any  `Encodable` type
```swift
struct Post: Encodable {
    let name: String
    let rating: Double
    let hidden: Bool
    let tags: [String]
}

let post = Post(name: "My Post", rating: 4.0, hidden: false, tags: ["tag1", "tag2"])
let postJson = try JSON.fromEncodable(post)
let name = post["name"].string // Optional("My Post")
```

### Safe or raw access to properties
```swift
let name = post["name"].string                      // Optional("My Post")
let notAString = post["rating"].string              // nil
let nonExisting = post["nonExisting"].string        // nil
let tag = post["tags"][0]                           // Optional("tag1")
let rawTags = post["tags"].rawValue! as! [String]   // ["tag1", "tag2"]
```

## Requirements

FreeformJSON is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 9.0+
* macOS 10.9+
* watchOS 2.0+
* tvOS 9.0+

## Installation

### Single file

Just drop `JSON.swift` anywhere in your own project.

### Framework

Download the repo, drag `FreeformJSON.xcodeproj` into your own project and link the appropriate target for your platform.

### CocoaPods
Inside your `Podfile`:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'TargetName' do
use_frameworks!
pod 'FreeformJSON'
end
```

### Carthage
Inside your `Cartfile`:
```ogdl
github "fabiorodella/FreeformJSON"
```

### Swift Package Manager
Inside your `Package.swift`:
```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "TargetName",
    dependencies: [
        .package(url: "https://github.com/fabiorodella/FreeformJSON.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "TargetName",
            dependencies: ["FreeformJSON"]),
    ]
)
```
