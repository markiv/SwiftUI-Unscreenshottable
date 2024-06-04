//
//  ProtectedView.swift
//  Unscreenshottable
//
//  Created by Vikram Kriplaney on 03.06.2024.
//

import class Combine.AnyCancellable
import SwiftUI

public struct ProtectionOptions: OptionSet {
    public let rawValue: Int
    /// Hide the view from screenshots.
    public static let screenshots = ProtectionOptions(rawValue: 0x01)
    /// Hide the view from screen sharing (e.g. AirPlay).
    public static let screenSharing = ProtectionOptions(rawValue: 0x02)
    /// Hide the view while the app is not active (e.g. while task switching).
    public static let inactivity = ProtectionOptions(rawValue: 0x04)
    /// Hide the view from screenshots, screen sharing and during inactivity (task switching).
    public static let all = ProtectionOptions([.screenshots, .screenSharing, inactivity])

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

struct ProtectedView<Content: View>: UIViewRepresentable {
    let options: ProtectionOptions
    @State private var textField: UITextField
    @State private var secureCanvas: UIView?
    @State private var hostingController: UIHostingController<Content>
    // @Environment(\.isSceneCaptured) private var isSceneCaptured // since iOS 17
    private var cancellables = Set<AnyCancellable>()

    init(options: ProtectionOptions = .all, content: @escaping () -> Content) {
        self.options = options
        self.textField = .init()
        self.hostingController = UIHostingController(rootView: content())
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false

        // Subscribes to NotificationCenter notifications and calls a decision closure.
        func subscribe(to notification: Notification.Name, shouldHide: @escaping (Notification) -> Bool) {
            NotificationCenter.default.publisher(for: notification)
                .sink { [weak hostingController] notification in
                    hostingController?.view.isHidden = shouldHide(notification)
                }
                .store(in: &cancellables)
        }

        if options.contains(.inactivity) {
            subscribe(to: UIApplication.willResignActiveNotification) { _ in true }
            subscribe(to: UIApplication.didBecomeActiveNotification) { _ in false }
        }
        if options.contains(.screenSharing) {
            subscribe(to: UIScreen.capturedDidChangeNotification) { ($0.object as? UIScreen)?.isCaptured ?? false }
        }
    }

    func makeUIView(context: Context) -> UIView {
        hostingController.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard options.contains(.screenshots), secureCanvas == nil else { return }

        DispatchQueue.main.async {
            // "Harvest" a canvas view from the secure `TextField`'s view hierarchy.
            if let secureCanvas = textField.canvasView, let view = hostingController.view {
                hostingController.view = secureCanvas
                secureCanvas.overlay(subview: view)
            }
        }
    }
}

public extension View {
    /// Protects this view from screenshotting, screen sharing and/or during inactivity.
    /// - Parameter placeholder: The optional content to display instead of this view during a screenshotting, screen
    /// sharing and/or inactivity. An empty view is displayed by default.
    /// - Parameter options: Protection options: See ``ProtectionOptions``. ``ProtectionOptions/all`` is the default.
    /// - Returns: A protected view.
    ///
    /// - Warning: Screenshot protection may stop working if Apple changes the view hierarchy in future iOS versions.
    func protected(
        from options: ProtectionOptions = .all, @ViewBuilder placeholder: () -> some View = { EmptyView() }
    ) -> some View {
        ProtectedView(options: options) {
            self
        }
        .background(placeholder()) // place the placeholder behind the protected view.
    }
}

private extension UIView {
    func overlay(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: subview.topAnchor),
            leftAnchor.constraint(equalTo: subview.leftAnchor),
            rightAnchor.constraint(equalTo: subview.rightAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }
}

extension UITextField {
    /// Extracts a canvas view from a secure `TextField`'s view hierarchy.
    /// The canvas view is a internal view that hides its subviews during a screenshot.
    /// - Warning: This may stop working if Apple changes the view hierarchy in future iOS versions.
    var canvasView: UIView? {
        subviews.first {
            // iOS 14...                 iOS 15...
            ["_UITextLayoutCanvasView", "_UITextFieldCanvasView"].contains(type(of: $0).description())
        } ?? subviews.first {
            type(of: $0).description().hasSuffix("CanvasView") // speculative attempt for future versions
        }
    }
}

#if DEBUG
struct DemoProtectedView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera")
                .foregroundColor(.accentColor)
            Text("Can you screenshot this?")
            Spacer().frame(height: 20)
            Image(systemName: "airplayvideo")
                .foregroundColor(.accentColor)
            Text("Can you AirPlay this?")
        }
        .imageScale(.large)
        .padding()
        .protected {
            VStack {
                Text("Sorry").font(.title)
                Text("Screenshots and screen sharing are not allowed.")
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
}

#Preview {
    DemoProtectedView()
}
#endif
