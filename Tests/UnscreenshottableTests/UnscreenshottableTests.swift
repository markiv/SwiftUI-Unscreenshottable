@testable import Unscreenshottable
import XCTest

final class UnscreenshottableTests: XCTestCase {
    /// Tests that a canvas view can still be harvested from a secure TextField.
    /// If this test fails, view protection will not work on your target iOS version.
    func testSecureCanvasExists() throws {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        XCTAssertNotNil(
            textField.canvasView,
            "Canvas view not found. Screenshot protection will not work on this iOS version."
        )
    }
}
