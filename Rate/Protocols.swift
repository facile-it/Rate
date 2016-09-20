import Foundation

public protocol RateSetupType {
    var appStoreUrlString: String { get }
    var timeSetup: RatingTimeSetup { get }
    var textsSetup: RatingTextSetup { get }
}

public protocol DataSaverType {
    func saveInt(_ value: Int, key: String)
    func saveBool(_ value: Bool, key: String)
    func saveDate(_ date: Date, key: String)
    func saveString(_ string: String, key: String)

    func getIntForKey(_ key: String) -> Int?
    func getBoolForKey(_ key: String) -> Bool?
    func getDateForKey(_ key: String) -> Date?
    func getStringForKey(_ key: String) -> String?

	func resetValueForKey(_ key: String)
}

public protocol URLOpenerType {
	@discardableResult func openURL(_ url: URL) -> Bool
}
