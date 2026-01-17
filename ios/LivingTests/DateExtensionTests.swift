import XCTest
@testable import Living

final class DateExtensionTests: XCTestCase {

    func testRelativeString_justNow() {
        // 0秒前
        let date = Date()
        XCTAssertEqual(date.relativeString, "たった今")
    }

    func testRelativeString_30SecondsAgo() {
        // 30秒前
        let date = Date().addingTimeInterval(-30)
        XCTAssertEqual(date.relativeString, "たった今")
    }

    func testRelativeString_59SecondsAgo() {
        // 59秒前（1分未満は「たった今」）
        let date = Date().addingTimeInterval(-59)
        XCTAssertEqual(date.relativeString, "たった今")
    }

    func testRelativeString_1MinuteAgo() {
        // 1分前
        let date = Date().addingTimeInterval(-60)
        let result = date.relativeString
        XCTAssertTrue(result.contains("分前"), "Expected '分前' but got: \(result)")
    }

    func testRelativeString_5MinutesAgo() {
        // 5分前
        let date = Date().addingTimeInterval(-300)
        let result = date.relativeString
        XCTAssertTrue(result.contains("分前"), "Expected '分前' but got: \(result)")
    }

    func testRelativeString_1HourAgo() {
        // 1時間前
        let date = Date().addingTimeInterval(-3600)
        let result = date.relativeString
        XCTAssertTrue(result.contains("時間前"), "Expected '時間前' but got: \(result)")
    }

    func testRelativeString_1DayAgo() {
        // 1日前
        let date = Date().addingTimeInterval(-86400)
        let result = date.relativeString
        XCTAssertTrue(result.contains("日前") || result.contains("昨日"), "Expected '日前' or '昨日' but got: \(result)")
    }

    func testRelativeString_2DaysAgo() {
        // 2日前（通知が送られる閾値）
        let date = Date().addingTimeInterval(-172800)
        let result = date.relativeString
        XCTAssertTrue(result.contains("日前") || result.contains("おととい"), "Expected '日前' or 'おととい' but got: \(result)")
    }
}
