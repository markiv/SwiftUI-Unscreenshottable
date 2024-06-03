# SwiftUI Unscreenshottable 📵
Prevent screenshots and screen sharing of sensitive content on iOS.

## Usage

You can apply the `protected` modifier to your top-level view, typically `ContentView`:

> [!CAUTION]
> Unscreenshottable relies on internal, undocumented iOS view hierarchy. It *may* be safe to submit to the App Store, 
but may stop working in future iOS versions – if Apple changes the view hierarchy.
 
```swift
import SwiftUI
import Unscreenshottable

@main
struct UnscreenshottableDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .protected {
                    Text("No screenshots nor screen sharing, please.")
                }
        }
    }
}
```

## Installation
### Swift Package Manager

Use the package URL or search for the SwiftUI-Unscreenshottable package: https://github.com/markiv/SwiftUI-Unscreenshottable.git.

For how to integrate package dependencies refer to the [*Adding Package Dependencies to Your App* documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
