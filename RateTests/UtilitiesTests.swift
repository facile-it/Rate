import XCTest
import Foundation
@testable import Rate

class UtilitiesTests: XCTestCase {
	func testIgnoreInput() {
		let willBeCalled = expectation(description: "willBeCalled")

		let shouldBeCalled: () -> () = {
			willBeCalled.fulfill()
		}

		let willCall: (Int) -> () = ignoreInput(shouldBeCalled)

		willCall(3)

		waitForExpectations(timeout: 1, handler: nil)
	}
}
