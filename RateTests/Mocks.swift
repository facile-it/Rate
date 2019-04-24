import Foundation
@testable import Rate

func after(_ value: Double, callback: @escaping () -> ()) {
	let delayTime = DispatchTime.now() + Double(Int64(value * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
	DispatchQueue.main.asyncAfter(deadline: delayTime,execute: callback)
}

class MockRateSetup: RateSetupType {
	var appStoreUrlString: String
	var timeSetup: RatingTimeSetup
	var textsSetup: RatingTextSetup

	init(urlString: String,
	     timeSetup: RatingTimeSetup,
	     textSetup: RatingTextSetup) {
		self.appStoreUrlString = urlString
		self.textsSetup = textSetup
		self.timeSetup = timeSetup
	}
}

class UrlOpenerMock: URLOpenerType {
	var lastOpenedURL: URL?
	func openURL(_ url: URL) -> Bool {
		lastOpenedURL = url
		return true
	}
}

class DataSaverMock: DataSaverType {
    var dict: [String:AnyObject] = [:]
    
    func resetValueForKey(_ key: String) {
        dict[key] = nil
    }
    
    func saveInt(_ value: Int, key: String) {
        dict[key] = value as AnyObject?
    }
    
    func saveBool(_ value: Bool, key: String) {
        dict[key] = value as AnyObject?
    }

    func saveDate(_ date: Date, key: String) {
        dict[key] = date as AnyObject?
    }

    func saveString(_ string: String, key: String) {
        dict[key] = string as AnyObject?
    }

    func getIntForKey(_ key: String) -> Int? {
        return dict[key] as? Int
    }
    
    func getBoolForKey(_ key: String) -> Bool? {
        return dict[key] as? Bool
    }

    func getDateForKey(_ key: String) -> Date? {
        return dict[key] as? Date
    }

    func getStringForKey(_ key: String) -> String? {
        return dict [key] as? String
    }
}

extension URL {
    static func test() -> URL {
        return URL.init(string: "https://www.facile.it")!
    }
}
