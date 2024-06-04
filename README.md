# SwiftUI Unscreenshottable 📵
Protect sensitive content on iOS.

Unscreenshottable can protect your view from:

### 1. Screenshots
Hide your view during a screenshot, optionally replacing it with another view.
> [!CAUTION]
> Unscreenshottable's screenshot protection relies on internal, undocumented iOS view hierarchy. It *may* be safe to\
> submit to the App Store, but may stop working in future iOS versions – if Apple changes the view hierarchy.
> The library includes a unit test that checks for the availability of the required internal view.

### 2. Screen Sharing
Hide your view while the screen is being shared, for example via AirPlay.

### 3. Inactivity
Hide your view while your app is inactive, for example during task switching.
> [!NOTE]
> You can also protect views with the `.privacySensitive()` modifier available since iOS 15, but Unscreenshottable
> allows you to replace your content with another view and supports iOS 14.

## Usage

You can apply the `protected` modifier to your top-level view, typically `ContentView`:
 
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

### Protection Options

The `.protected` modifier can take an optional parameter if you want to limit the protection types (the default is all three). You can even combine multiple protections:

```swift
ContentView()
    .protected(from: inactivity) {
        Image("logo")
    }
    .protected(from: [.screenshots, .screenSharing]) {
        Text("No screenshots nor screen sharing, please.")
    }
```

## Installation
### Swift Package Manager

Use the package URL or search for the SwiftUI-Unscreenshottable package: https://github.com/markiv/SwiftUI-Unscreenshottable.git.

For how to integrate package dependencies refer to the [*Adding Package Dependencies to Your App* documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
