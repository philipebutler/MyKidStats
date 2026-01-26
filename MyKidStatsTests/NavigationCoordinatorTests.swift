import XCTest
@testable import MyKidStats

@MainActor
final class NavigationCoordinatorTests: XCTestCase {
    var coordinator: NavigationCoordinator!

    override func setUp() async throws {
        try await super.setUp()
        coordinator = NavigationCoordinator()
    }

    override func tearDown() async throws {
        coordinator = nil
        try await super.tearDown()
    }

    func testDefaultSelectedTabIsHome() {
        XCTAssertEqual(coordinator.selectedTab, .home)
    }

    func testSelectedTabChanges() {
        coordinator.selectedTab = .teams
        XCTAssertEqual(coordinator.selectedTab, .teams)
    }

    func testPresentedSheetLifecycle() {
        XCTAssertNil(coordinator.presentedSheet)

        coordinator.showCreateTeam()
        XCTAssertNotNil(coordinator.presentedSheet)

        if case .createTeam = coordinator.presentedSheet {
            // expected
        } else {
            XCTFail("presentedSheet should be .createTeam")
        }

        coordinator.dismissSheet()
        XCTAssertNil(coordinator.presentedSheet)
    }
}
