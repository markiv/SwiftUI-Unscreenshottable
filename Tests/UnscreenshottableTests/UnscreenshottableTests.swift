import XCTest
//@testable import Unscreenshottable

final class UnscreenshottableTests: XCTestCase {
    /// Tests that a canvas view can still be harvested from a secure TextField.
    /// If this test fails, view protection will not work on your target iOS version.
    func testSecureCanvasExists() throws {        
        let textField = UITextField()
        textField.isSecureTextEntry = true
        let secureCanvas = textField.subviews.first {
            ["_UITextLayoutCanvasView", "_UITextFieldCanvasView"].contains(type(of: $0).description())
        }
        XCTAssertNotNil(secureCanvas, "Canvas view not found. View protection will not work on this iOS version.")
    }
}
