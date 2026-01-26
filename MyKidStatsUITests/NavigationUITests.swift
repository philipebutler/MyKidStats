import XCTest

final class NavigationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTabNavigationShowsExpectedViews() throws {
        let homeButton = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeButton.waitForExistence(timeout: 5))
        homeButton.tap()
        XCTAssertTrue(app.navigationBars["Basketball Stats"].waitForExistence(timeout: 5))

        let liveButton = app.tabBars.buttons["Live"]
        XCTAssertTrue(liveButton.exists)
        liveButton.tap()
        XCTAssertTrue(app.staticTexts["Live Game"].exists)

        let teamsButton = app.tabBars.buttons["Teams"]
        XCTAssertTrue(teamsButton.exists)
        teamsButton.tap()
        XCTAssertTrue(app.staticTexts["Teams"].exists)

        let settingsButton = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
    }
}
