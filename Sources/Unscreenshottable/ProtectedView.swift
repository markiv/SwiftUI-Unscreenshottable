//
//  ProtectedView.swift
//  Unscreenshottable
//
//  Created by Vikram Kriplaney on 03.06.2024.
//

import class Combine.AnyCancellable
import SwiftUI

struct ProtectedView<Content: View>: UIViewRepresentable {
    @State private var textField: UITextField
    @State private var secureCanvas: UIView?
    @State private var hostingController: UIHostingController<Content>
    // @Environment(\.isSceneCaptured) private var isSceneCaptured // since iOS 17
    private var cancellables = Set<AnyCancellable>()

    init(content: @escaping () -> Content) {
        self.textField = .init()
        self.hostingController = UIHostingController(rootView: content())
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false

        // Observe screen capture state with a Combine publisher.
        NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)
            .sink { [weak hostingController] notification in
                let isCaptured = (notification.object as? UIScreen)?.isCaptured ?? false
                hostingController?.view.isHidden = isCaptured
            }
            .store(in: &cancellables)

        // Observe screen capture state with an async sequence (since iOS 15).
        // Task { [weak hostingController] in
        //     for await notification in await // NotificationCenter.default.notifications(
        //         named: UIScreen.capturedDidChangeNotification
        //     ) {
        //         let isCaptured = await (notification.object as? // UIScreen)?.isCaptured ?? false
        //         await MainActor.run { [weak hostingController] in
        //             hostingController?.view.isHidden = isCaptured
        //         }
        //     }
        // }
    }

    func makeUIView(context: Context) -> UIView {
        hostingController.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard secureCanvas == nil else { return }

        DispatchQueue.main.async {
            // "Harvest" a canvas view from a secure `TextField`.
            // The canvas view is a private view that hides its subviews during a screenshot.
            // Warning: This may stop working if Apple changes the view hierarchy in future iOS versions.
            secureCanvas = textField.subviews.first {
                ["_UITextLayoutCanvasView", "_UITextFieldCanvasView"].contains(type(of: $0).description())
            }
            if let secureCanvas, let view = hostingController.view {
                hostingController.view = secureCanvas
                secureCanvas.overlay(subview: view)
                hostingController.view.isHidden = view.window?.screen.isCaptured ?? false
            }
        }
    }
}

public extension View {
    /// Protects this view from screenshotting and screen sharing.
    /// - Parameter content: The optional content to display instead of this view during a screenshot or screen sharing.
    /// An empty view is displayed by default.
    /// - Returns: A protected view.
    ///
    /// - Warning: This may stop working if Apple changes the view hierarchy in future iOS versions.
    func protected(@ViewBuilder content: () -> some View = { EmptyView() }) -> some View {
        ProtectedView {
            self
        }
        .background(content())
        // .background { content() } // since iOS 15
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

#if DEBUG
struct DemoProtectedView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera")
                .foregroundColor(.accentColor)
                // .foregroundStyle(.tint) // since iOS 15
            Text("Can you screenshot this?")
            Spacer().frame(height: 20)
            Image(systemName: "airplayvideo")
                .foregroundColor(.accentColor)
            // .foregroundStyle(.tint) // since iOS 15
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
