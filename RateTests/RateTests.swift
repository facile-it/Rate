import XCTest
import Foundation
@testable import Rate

class RateTests: XCTestCase {
	let urlOpenerMock = UrlOpenerMock()

	let ratingTimeSetup = RatingTimeSetup(
		daysUntilPrompt: 2,
		usesUntilPrompt: 2,
		remindPeriod: 2,
		rateNewVersionIndipendently: false)

	let ratingTextSetup = RatingTextSetup(
		alertTitle: "",
		alertMessage: "",
		rateButtonTitle: "",
		remindButtonTitle: "",
		ignoreButtonTitle: "")

	func testSaveParametersNewReleaseApp_saveInt() {

		let dataSaverMock = DataSaverMock()

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())

		XCTAssertEqual(dataSaverMock.getIntForKey(rate.usesNumberKey), 1)
	}


	func testSaveParametersNewReleaseApp_saveDate() {
		let dataSaverMock = DataSaverMock()
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		let expectedDate = Date()
		rate.updateForRelease("", date: expectedDate)

		XCTAssertEqual(dataSaverMock.getDateForKey(rate.dateFirstBootKey), expectedDate)
	}

	func testGetUsesNumber() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		dataSaverMock.saveInt(101, key: rate.usesNumberKey)

		XCTAssertEqual(101, rate.getUsesNumber())
	}

	func testUpdateUsesNumber() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())

		XCTAssertEqual(dataSaverMock.getIntForKey(rate.usesNumberKey), 1)
		rate.updateForRelease("", date: Date())
		rate.updateForRelease("", date: Date())
		rate.updateForRelease("", date: Date())
		rate.updateForRelease("", date: Date())
		XCTAssertEqual(dataSaverMock.getIntForKey(rate.usesNumberKey), 5)
	}

	func testSaveDateFirstBoot() {
		let expectedDate = Date()

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()
		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: expectedDate)

		XCTAssertEqual(dataSaverMock.getDateForKey(rate.dateFirstBootKey), expectedDate)
	}

	func testSaveDateRemindMeLater() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		rate.saveDateRemindMeLater()
	}

	func testShouldRateForPassedDaysSinceStart() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		XCTAssertEqual(rate.shouldRateForPassedDaysSinceStart(), false)
		dataSaverMock.saveDate(Date(), key: rate.dateFirstBootKey)

		let willPassTime = expectation(description: "willPassTime")

		after(0.1) {
			XCTAssertEqual(rate.shouldRateForPassedDaysSinceStart(), true)
			willPassTime.fulfill()
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testShouldRateForNumberOfUses() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		XCTAssertEqual(rate.shouldRateForNumberOfUses(), false)
	}

	func testShoulRateForPassedDaysSinceRemindMeLater() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		XCTAssertEqual(rate.shouldRateForPassedDaysSinceRemindMeLater(), false)
		dataSaverMock.saveDate(Date(), key: rate.dateRemindMeLaterKey)
		XCTAssertEqual(rate.shouldRateForPassedDaysSinceRemindMeLater(), true)
	}

	func testShouldRateForRemindMeLaterIfRemindPeriodChanged() {
		let ratingTimeSetup1 = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 3,
			rateNewVersionIndipendently: false)

		let rateSetupMock1 = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup1,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate1 = Rate(rateSetup: rateSetupMock1,
		                 dataSaver: dataSaverMock,
		                 urlOpener: urlOpenerMock)

		XCTAssertEqual(rate1.shouldRateForPassedDaysSinceRemindMeLater(), false)

		rate1.saveDateRemindMeLater()

		XCTAssertEqual(rate1.shouldRateForPassedDaysSinceRemindMeLater(), false)

		let ratingTimeSetup2 = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock2 = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup2,
			textSetup: ratingTextSetup)

		let rate2 = Rate(rateSetup: rateSetupMock2,
		                 dataSaver: dataSaverMock,
		                 urlOpener: urlOpenerMock)

		XCTAssertEqual(rate2.shouldRateForPassedDaysSinceRemindMeLater(), true)
	}

	func testShouldShowAlertForRemindMeLaterIfRemindPeriodChanged() {
		let ratingTimeSetup1 = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 3,
			rateNewVersionIndipendently: false)

		let rateSetupMock1 = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup1,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate1 = Rate(rateSetup: rateSetupMock1,
		                 dataSaver: dataSaverMock,
		                 urlOpener: urlOpenerMock)

		XCTAssertNotNil(rate1.getRatingAlertControllerIfNeeded())

		rate1.saveDateRemindMeLater()

		XCTAssertNil(rate1.getRatingAlertControllerIfNeeded())

		let ratingTimeSetup2 = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock2 = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup2,
			textSetup: ratingTextSetup)

		let rate2 = Rate(rateSetup: rateSetupMock2,
		                 dataSaver: dataSaverMock,
		                 urlOpener: urlOpenerMock)

		XCTAssertNotNil(rate2.getRatingAlertControllerIfNeeded())
	}

	func testAppNotRated() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		XCTAssertTrue(rate.appNotRated())
		dataSaverMock.saveBool(false, key: "rated")
		XCTAssertEqual(rate.appNotRated(), true)
	}

	func testShouldNotRateIfIgnoredStart() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 3,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			dataSaverMock.saveBool(true, key: rate.ratedKey)

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
				willCheck.fulfill()
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testCheckShouldRate() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 20,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let ratingTextSetup = RatingTextSetup(
			alertTitle: "alert",
			alertMessage: "vuoi votare?",
			rateButtonTitle: "vota",
			remindButtonTitle: "non ora",
			ignoreButtonTitle: "ignora")

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		dataSaverMock.saveBool(false, key: rate.tappedRemindMeLaterKey)
		dataSaverMock.saveDate(Date(), key: rate.dateFirstBootKey)
		XCTAssertEqual(rate.checkShouldRate(), true)
		dataSaverMock.saveBool(true, key: rate.tappedRemindMeLaterKey)
		dataSaverMock.saveDate(Date(), key: rate.dateRemindMeLaterKey)
		XCTAssertEqual(rate.checkShouldRate(), true)
	}

	func testGetRatingAlertControllerIfNeeded_Passed() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 0,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let ratingTextSetup = RatingTextSetup(
			alertTitle: "alert",
			alertMessage: "vuoi votare?",
			rateButtonTitle: "vota",
			remindButtonTitle: "non ora",
			ignoreButtonTitle: "ignora")

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		dataSaverMock.saveBool(false, key: "rated")
		dataSaverMock.saveBool(false, key: rate.tappedRemindMeLaterKey)
		let alertController = rate.getRatingAlertControllerIfNeeded()
		XCTAssertNotNil(alertController)
		XCTAssertEqual(alertController?.title, "alert")
		XCTAssertEqual(alertController?.message, "vuoi votare?")
		XCTAssertEqual(alertController?.preferredStyle, .alert)
		XCTAssertEqual(alertController?.actions[0].title, "vota")
		XCTAssertEqual(alertController?.actions[0].style, .default)
		XCTAssertEqual(alertController?.actions[1].title, "non ora")
		XCTAssertEqual(alertController?.actions[1].style, .default)
		XCTAssertEqual(alertController?.actions[2].title, "ignora")
		XCTAssertEqual(alertController?.actions[2].style, .default)
	}

	func testGetRatingAlertControllerIfNeeded_NotPassed() {

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		dataSaverMock.saveBool(false, key: "rated")
		XCTAssertEqual(rate.getRatingAlertControllerIfNeeded(), nil)
	}

	func testVoteNowOnAppStore() {
		let urlCompare = URL(string: "http://www.facile.it")
		let rateSetupMock = MockRateSetup(
			urlString: "http://www.facile.it",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		rate.voteNowOnAppStore()
		XCTAssertEqual(urlCompare, urlOpenerMock.lastOpenedURL)
		urlOpenerMock.lastOpenedURL = nil
		rate.voteNowOnAppStore()
	}


	func testUpdateForRelease() {
		let ratingTimeSetup = RatingTimeSetup(daysUntilPrompt: 2,
		                                      usesUntilPrompt: 2,
		                                      remindPeriod: 2,
		                                      rateNewVersionIndipendently: true)
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		dataSaverMock.saveString("2.2.2", key: "currentVersion")
		rate.updateForRelease("2.2.2", date: Date())
		XCTAssertEqual(dataSaverMock.getIntForKey(rate.usesNumberKey), 1)
		dataSaverMock.saveString("1.1.1", key: "currentVersion")
		rate.updateForRelease("1.2.1", date: Date())
		dataSaverMock.saveString("1.1.2", key: "currentVersion")
		rate.updateForRelease("1.1.4", date: Date())
		XCTAssertEqual(dataSaverMock.getBoolForKey(rate.tappedRemindMeLaterKey), false)
	}

	func testUpdateDateFirstBootIfNeeded() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)
		let date = Date()
		dataSaverMock.saveDate(date, key: rate.dateFirstBootKey)
		let newDate = Date()
		rate.updateDateFirstBootIfNeeded(newDate)
		XCTAssertNotEqual(dataSaverMock.getDateForKey(rate.dateFirstBootKey), newDate)
	}

	func testResetAll() {
		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		let expectedDate = Date()

		dataSaverMock.saveString("12345", key: rate.currentVersionKey)
		dataSaverMock.saveInt(3, key: rate.usesNumberKey)
		dataSaverMock.saveBool(true, key: rate.tappedRemindMeLaterKey)
		dataSaverMock.saveBool(true, key: rate.ratedKey)
		dataSaverMock.saveDate(expectedDate, key: rate.dateFirstBootKey)
		dataSaverMock.saveDate(expectedDate, key: rate.dateRemindMeLaterKey)

		rate.reset()

		XCTAssertNil(dataSaverMock.getStringForKey(rate.currentVersionKey))
		XCTAssertNil(dataSaverMock.getIntForKey(rate.usesNumberKey))
		XCTAssertNil(dataSaverMock.getBoolForKey(rate.tappedRemindMeLaterKey))
		XCTAssertNil(dataSaverMock.getBoolForKey(rate.ratedKey))
		XCTAssertNil(dataSaverMock.getDateForKey(rate.dateFirstBootKey))
		XCTAssertNil(dataSaverMock.getDateForKey(rate.dateRemindMeLaterKey))
	}

	//MARK: - use cases

	func testNumberOfUsesRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
	}

	func testNumberOfUsesRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
	}

	func testDaysUntilPromptRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
	}

	func testDaysUntilPromptRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 0,
			usesUntilPrompt: 10,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
	}

	func testDaysUntilremindMeLaterRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")
		after(0.1) {
			rate.saveDateRemindMeLater()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
				willCheck.fulfill()
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testDaysUntilremindMeLaterRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")
		after(0.1) {
			rate.saveDateRemindMeLater()

			after(0.1) {
				XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
				willCheck.fulfill()
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testUsesRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")
		after(0.1) {
			rate.updateForRelease("", date: Date())
			rate.updateForRelease("", date: Date())
			rate.updateForRelease("", date: Date())
			rate.updateForRelease("", date: Date())

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					rate.updateForRelease("", date: Date())
					rate.updateForRelease("", date: Date())
					rate.updateForRelease("", date: Date())
					rate.updateForRelease("", date: Date())

					after(0.1) {
						XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

						after(0.1) {
							rate.updateForRelease("", date: Date())
							rate.updateForRelease("", date: Date())
							rate.updateForRelease("", date: Date())
							rate.updateForRelease("", date: Date())

							after(0.1) {
								XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
								willCheck.fulfill()
							}
						}
					}
				}
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testRemindRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")
		after(0.1) {
			rate.saveDateRemindMeLater()

			after(0.1) {
				XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
				willCheck.fulfill()
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testNumberOfUsesAndVoteNowRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.voteNowOnAppStore()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
					willCheck.fulfill()
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testNumberOfUsesAndIgnoredRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.ignoreRating()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
					willCheck.fulfill()
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testVoteNowAndVersionUpdatedAndIndipendentlyRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: true)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.voteNowOnAppStore()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					rate.updateForRelease("2", date: Date())

					after(0.1) {
						XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
						willCheck.fulfill()
					}
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testIgnoredAndVersionUpdatedAndIndipendentlyRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: true)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.ignoreRating()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					rate.updateForRelease("2", date: Date())

					after(0.1) {
						XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
						willCheck.fulfill()
					}
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testVoteNowAndVersionUpdatedAndIndipendentlyRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.voteNowOnAppStore()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					rate.updateForRelease("2", date: Date())

					after(0.1) {
						XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
						willCheck.fulfill()
					}
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testIgnoredAndVersionUpdatedAndIndipendentlyRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 1,
			remindPeriod: 10,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.ignoreRating()

			after(0.1) {
				XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

				after(0.1) {
					rate.updateForRelease("2", date: Date())

					after(0.1) {
						XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
						willCheck.fulfill()
					}
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testRemindAndVersionUpdatedAndIndipendentlyRateFalse() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 0,
			rateNewVersionIndipendently: true)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.saveDateRemindMeLater()

			after(0.1) {
				rate.updateForRelease("2", date: Date())

				after(0.1) {
					XCTAssertNil(rate.getRatingAlertControllerIfNeeded())
					willCheck.fulfill()
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}

	func testRemindAndVersionUpdatedAndNotIndipendentlyRateTrue() {
		let ratingTimeSetup = RatingTimeSetup(
			daysUntilPrompt: 10,
			usesUntilPrompt: 10,
			remindPeriod: 0,
			rateNewVersionIndipendently: false)

		let rateSetupMock = MockRateSetup(
			urlString: "",
			timeSetup: ratingTimeSetup,
			textSetup: ratingTextSetup)

		let dataSaverMock = DataSaverMock()

		let rate = Rate(rateSetup: rateSetupMock,
		                dataSaver: dataSaverMock,
		                urlOpener: urlOpenerMock)

		rate.updateForRelease("1", date: Date())
		XCTAssertNil(rate.getRatingAlertControllerIfNeeded())

		let willCheck = expectation(description: "willCheck")

		after(0.1) {
			rate.saveDateRemindMeLater()

			after(0.1) {
				rate.updateForRelease("2", date: Date())

				after(0.1) {
					XCTAssertNotNil(rate.getRatingAlertControllerIfNeeded())
					willCheck.fulfill()
				}
			}
		}

		waitForExpectations(timeout: 1, handler: nil)
	}
}
