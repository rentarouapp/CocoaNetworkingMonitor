# CocoaNetworkingMonitor

## Installation

### Swift Package Manager (Recommended)
#### Package

You can add this package to Package.swift, include it in your target dependencies.
```
let package = Package(
    dependencies: [
        .package(url: "https://github.com/rentarouapp/CocoaNetworkingMonitor.git", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "<YourTarget>",
            dependencies: ["CocoaNetworkingMonitor"]),
    ]
)
```
#### Package

You can add this package on Xcode.

See [documentation](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).
