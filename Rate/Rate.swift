import Foundation

open class Rate {
	let currentVersionKey = "currentVersion"
	let usesNumberKey = "usesNumber"
	let tappedRemindMeLaterKey = "tappedRemindMeLater"
	let ratedKey = "rated"
	let dateFirstBootKey = "dateFirstBoot"
	let dateRemindMeLaterKey = "dateRemindMeLater"

	let rateSetup: RateSetupType
	let dataSaver: DataSaverType
	let urlOpener: URLOpenerType

	public init(rateSetup: RateSetupType,
	            dataSaver: DataSaverType,
	            urlOpener: URLOpenerType) {
		self.rateSetup = rateSetup
		self.dataSaver = dataSaver
		self.urlOpener = urlOpener
	}

	open func updateForRelease(_ appVersion: String, date: Date) {
		if let currentVersion = dataSaver.getStringForKey(currentVersionKey) , currentVersion == appVersion {
			let currentUsesNumber = dataSaver.getIntForKey(usesNumberKey) ?? 0
			dataSaver.saveInt(currentUsesNumber + 1, key: usesNumberKey)
		} else {
			let hasNoVersion = dataSaver.getStringForKey(currentVersionKey) == nil
			let shouldResetRemindMeLater = hasNoVersion || rateSetup.timeSetup.rateNewVersionsIndipendently
			if shouldResetRemindMeLater {
				dataSaver.saveBool(false, key: tappedRemindMeLaterKey)
			}
			dataSaver.saveString(appVersion, key: currentVersionKey)
			dataSaver.saveInt(1, key: usesNumberKey)
			resetRatedForNewVersionIfNeeded()
			updateDateFirstBootIfNeeded(date)
		}
	}

	open func getRatingAlertControllerIfNeeded() -> UIAlertController? {
		guard checkShouldRate() && appNotRated() else {
			return nil
		}

		let alertController = UIAlertController(
			title: rateSetup.textsSetup.alertTitle,
			message: rateSetup.textsSetup.alertMessage,
			preferredStyle: .alert)

		alertController.addAction(UIAlertAction(
			title: rateSetup.textsSetup.rateButtonTitle,
			style: .default,
			handler: ignoreInput(voteNowOnAppStore)))

		alertController.addAction( UIAlertAction(
			title: rateSetup.textsSetup.remindButtonTitle,
			style: .default,
			handler: ignoreInput(saveDateRemindMeLater)))

		alertController.addAction(UIAlertAction(
			title: rateSetup.textsSetup.ignoreButtonTitle,
			style: .default,
			handler:ignoreInput(ignoreRating)))

		return alertController
	}

	open func reset() {
		dataSaver.resetValueForKey(currentVersionKey)
		dataSaver.resetValueForKey(usesNumberKey)
		dataSaver.resetValueForKey(tappedRemindMeLaterKey)
		dataSaver.resetValueForKey(ratedKey)
		dataSaver.resetValueForKey(dateFirstBootKey)
		dataSaver.resetValueForKey(dateRemindMeLaterKey)
	}

	//MARK: - private logic

	func ignoreRating() {
		setRated(true)
	}

	func setRated(_ value: Bool) {
		self.dataSaver.saveBool(value, key: self.ratedKey)
	}

	func checkShouldRate() -> Bool {
		switch dataSaver.getBoolForKey(tappedRemindMeLaterKey) {
		case true?:
			return shouldRateForPassedDaysSinceRemindMeLater()
		default:
			return shouldRateForNumberOfUses()
				|| shouldRateForPassedDaysSinceStart()
		}
	}

	func resetRatedForNewVersionIfNeeded() {
		let rateNewVersions = rateSetup.timeSetup.rateNewVersionsIndipendently
		guard rateNewVersions else { return }
		setRated(false)
	}

	func updateDateFirstBootIfNeeded(_ date: Date) {
		let noDate = dataSaver.getDateForKey(dateFirstBootKey) == nil
		let rateNewVersions = rateSetup.timeSetup.rateNewVersionsIndipendently
		guard noDate || rateNewVersions else { return }
		dataSaver.saveDate(date, key: dateFirstBootKey)
	}

	func getUsesNumber() -> Int {
		return dataSaver.getIntForKey(usesNumberKey) ?? 0
	}

	func saveDateRemindMeLater() {
		dataSaver.saveDate(Date(), key: dateRemindMeLaterKey)
		dataSaver.saveBool(true, key: tappedRemindMeLaterKey)
	}

	func voteNowOnAppStore() {
		guard let url = URL(string: rateSetup.appStoreUrlString) else { return }
		setRated(true)
		urlOpener.openURL(url)
	}

	func shouldRateForPassedDaysSinceStart() -> Bool {
		if let timeInterval = dataSaver.getDateForKey(dateFirstBootKey)?.timeIntervalSinceNow {
			return (-timeInterval) >= Double(rateSetup.timeSetup.daysUntilPrompt*3600*24)
		} else {
			return false
		}
	}

	func shouldRateForNumberOfUses() -> Bool {
		return getUsesNumber() >= rateSetup.timeSetup.usesUntilPrompt
	}

	func shouldRateForPassedDaysSinceRemindMeLater() -> Bool {
		if let timeInterval = dataSaver.getDateForKey(dateRemindMeLaterKey)?.timeIntervalSinceNow {
			return (-timeInterval) >= Double(rateSetup.timeSetup.remindPeriod*3600*24)
		} else {
			return false
		}
	}

	func appNotRated() -> Bool {
		if let rated = dataSaver.getBoolForKey(ratedKey) {
			return rated == false
		} else {
			return true
		}
	}
}
