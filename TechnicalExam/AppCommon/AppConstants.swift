//
//  AppConstants.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import KeychainAccess
import UIKit

protocol AppConstantConvertible {
    init?(storeValue: Any)
    var storeValue: Any? { get }
}

protocol AppConstantKeychainType: AppConstantConvertible {
    static var type: String { get }
}

extension Optional: AppConstantConvertible where Wrapped: AppConstantConvertible {
    init?(storeValue: Any) {
        guard let value = Wrapped(storeValue: storeValue) else { return nil }
        self = .some(value)
    }

    var storeValue: Any? {
        switch self {
        case .some(let value): value.storeValue
        case .none: nil
        }
    }

    static var defaultValue: Any? { nil }
}

extension Optional: AppConstantKeychainType where Wrapped: AppConstantKeychainType {
    static var type: String { Wrapped.type }
}

extension Int: AppConstantConvertible {
    init?(storeValue: Any) {
        guard let value = storeValue as? Int else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var defaultValue: Any? { 0 }
}

extension Int64: AppConstantConvertible {
    init?(storeValue: Any) {
        guard let value = storeValue as? Int64 else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var defaultValue: Any? { 0 }
}

extension Bool: AppConstantConvertible {
    init?(storeValue: Any) {
        guard let value = storeValue as? Bool else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var defaultValue: Any? { false }
}

extension String: AppConstantKeychainType {
    init?(storeValue: Any) {
        guard let value = storeValue as? String else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var type: String { "string" }
    static var defaultValue: Any? { "" }
}

extension Data: AppConstantKeychainType {
    init?(storeValue: Any) {
        guard let value = storeValue as? Data else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var type: String { "data" }
    static var defaultValue: Any? { Data() }
}

extension Date: AppConstantConvertible {
    init?(storeValue: Any) {
        guard let value = storeValue as? Date else { return nil }
        self = value
    }

    var storeValue: Any? { self }
    static var type: String { "date" }
    static var defaultValue: Any? { Date() }
}

class Observable<Value>: NSObject {
    private let notificationName: Notification.Name
    private let defaultValue: Value

    init(notificationName: Notification.Name, default: Value) {
        self.notificationName = notificationName
        defaultValue = `default`
        super.init()
    }

    func subscribe(onChange: @escaping (Value, Value?) -> Void) -> NSObjectProtocol {
        NotificationCenter.default
            .addObserver(forName: notificationName,
                         object: nil,
                         queue: nil,
                         using: {
                            let newValue = $0.object as? Value ?? self.defaultValue
                            let oldValue = $0.userInfo?["old"] as? Value
                            onChange(newValue, oldValue)
                         })
    }
}

class AppConstant: NSObject {
    @propertyWrapper struct UserDefaultsReadAndWrite<Value: AppConstantConvertible> {
        private let key: String
        private let defaultValue: Value
        private let notificationName: Notification.Name

        var projectedValue: Observable<Value> {
            Observable(notificationName: notificationName, default: defaultValue)
        }

        var wrappedValue: Value {
            get {
                AppConstant.appInfoQueue.sync(flags: .barrier) {
                    if let object = UserDefaults.standard.object(forKey: key),
                       let value = Value(storeValue: object) {
                        return value
                    }
                    return defaultValue
                }
            }
            set {
                AppConstant.appInfoQueue.sync(flags: .barrier) {
                    let userDefaults = UserDefaults.standard
                    if let userDefaultValue = newValue.storeValue {
                        userDefaults.set(userDefaultValue, forKey: key)
                    } else {
                        userDefaults.removeObject(forKey: key)
                    }
                    userDefaults.synchronize()
                    let notification = Notification(name: notificationName,
                                                    object: newValue)
                    DispatchQueue.main.async {
                        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
                    }
                }
            }
        }

        init(_ key: String, default: Value) {
            self.key = key
            defaultValue = `default`
            notificationName = Notification.Name("notificationForAppInfo.\(key)")
        }
    }

    @propertyWrapper struct UserDefaultsReadOnly<Value: AppConstantConvertible> {
        private var key: String
        private var defaultValue: Value

        var wrappedValue: Value {
            if let object = UserDefaults.standard.object(forKey: key),
               let value = Value(storeValue: object) {
                return value
            }
            return defaultValue
        }

        init(_ key: String, default: Value) {
            self.key = key
            defaultValue = `default`
        }
    }

    @propertyWrapper struct MemoryReadAndWrite<Value: AppConstantConvertible> {
        private var key: String
        private var value: Value
        private var defaultValue: Value
        private var notificationName: Notification.Name

        var projectedValue: Observable<Value> {
            Observable(notificationName: notificationName,
                       default: defaultValue)
        }

        var wrappedValue: Value {
            get { AppConstant.appInfoQueue.sync(flags: .barrier) { value } }
            set {
                AppConstant.appInfoQueue.sync(flags: .barrier) {
                    value = newValue
                    let notification = Notification(name: notificationName,
                                                    object: newValue)
                    DispatchQueue.main.async {
                        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
                    }
                }
            }
        }

        init(_ key: String, default value: Value) {
            self.key = key
            self.value = value
            defaultValue = value
            notificationName = Notification.Name(rawValue: "notificationForAppInfo.\(key)")
        }
    }

    enum ServerType: AppConstantConvertible, Equatable {
        case manual
        case test
        case staging
        case production

        init?(storeValue: Any) {
            guard let value = storeValue as? String else { self = .test; return }
            switch value {
            case "test": self = .test
            case "staging": self = .staging
            case "production": self = .production
            default: self = .manual
            }
        }

        var storeValue: Any? {
            switch self {
            case .test: "test"
            case .staging: "staging"
            case .production: "production"
            default: "manual"
            }
        }

        static var defaultValue: ServerType { .manual }
    }

    @propertyWrapper struct KeychainReadAndWrite<Value: AppConstantKeychainType> {
        private let key: String
        private let defaultValue: Value
        private let notificationName: Notification.Name

        var projectedValue: Observable<Value> {
            Observable(notificationName: notificationName, default: defaultValue)
        }

        var wrappedValue: Value {
            get {
                AppConstant.appInfoQueue.sync(flags: .barrier) {
                    switch Value.type {
                    case "data":
                        if let object = AppConstant.keychain[data: key],
                           let value = Value(storeValue: object) {
                            return value
                        }
                    case "string":
                        if let object = AppConstant.keychain[string: key],
                           let value = Value(storeValue: object) {
                            return value
                        }
                    case "date":
                        if let object = AppConstant.keychain[string: key],
                           let date = Date(iso8601: object),
                           let value = Value(storeValue: date) {
                            return value
                        }
                    case "int":
                        if let object = AppConstant.keychain[string: key],
                           let intValue = Int(safe: object),
                           let value = Value(storeValue: intValue) {
                            return value
                        }
                    default:
                        return defaultValue
                    }
                    return defaultValue
                }
            }
            set {
                AppConstant.appInfoQueue.sync(flags: .barrier) {
                    if let value = newValue.storeValue {
                        switch Value.type {
                        case "data":
                            AppConstant.keychain[data: key] = value as? Data
                        case "string":
                            AppConstant.keychain[string: key] = value as? String
                        case "date":
                            AppConstant.keychain[string: key] = (value as? Date)?.toIso8601
                        case "int":
                            let storeValue: String? = if let intValue = value as? Int { String(intValue) } else { nil }
                            AppConstant.keychain[string: key] = storeValue
                        default:
                            fatalError("You must set type.")
                        }
                    } else {
                        try? AppConstant.keychain.remove(key)
                    }
                    let notification = Notification(name: notificationName,
                                                    object: newValue)
                    DispatchQueue.main.async {
                        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
                    }
                }
            }
        }

        init(_ key: String, default: Value) {
            self.key = key
            defaultValue = `default`
            notificationName = Notification.Name("notificationForAppInfo.\(key)")
        }
    }

    private static var keychainServiceIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "jp.aeonretail.aeon-coupon"
    }
    private static var keychain: Keychain = .init(service: keychainServiceIdentifier)
        .synchronizable(false)
        .accessibility(.afterFirstUnlockThisDeviceOnly)

    private static var appInfoQueue = DispatchQueue(label: "AppInfoQueue",
                                                    qos: .userInteractive)
    static var shared = AppConstant()

    var appServerScheme: String {
        switch serverType {
        case .manual:
            guard let url = URL(string: AppConstant.shared.manualHost),
                  let scheme = url.scheme,
                  scheme.hasPrefix("http")
            else { return "http" }
            return scheme
        case .test, .staging, .production:
            return "https"
        }
    }

    var appServerHost: String {
        switch serverType {
        case .manual:
            let manualHost = AppConstant.shared.manualHost
            guard let url = URL(string: manualHost), let host = url.host
            else { return "\(manualHost)" }
            if let port = url.port {
                return "\(host):\(port)"
            }
            return host
        case .production:
            return ""
        case .staging:
            return ""
        case .test:
            return "dev.prepcirca.com/api/v1"
        }
    }

    @UserDefaultsReadOnly("SERVER_TYPE", default: .test)
    var serverType: ServerType
    @UserDefaultsReadOnly("MANUAL_HOST", default: "localhost:8000")
    var manualHost: String

    @KeychainReadAndWrite("userName", default: nil)
    var userName: String?
    @KeychainReadAndWrite("password", default: nil)
    var password: String?
    
    @KeychainReadAndWrite("keychainValue", default: nil)
    var keychainValue: String?
}

// MARK: - App specification infos
extension AppConstant {
    static var appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""

    static var appName: String = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? ""

    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?
            .windows
            .first(where: \.isKeyWindow)
    }

    static var safeAreaInsets: UIEdgeInsets {
        guard let keyWindow
        else { fatalError("There is no keyWindow. You must check source.") }
        return keyWindow.safeAreaInsets
    }
    
    static var statusBarHeight: CGFloat {
        keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }

    static var hasSafeAreaBottomMargin: Bool { AppConstant.safeAreaInsets.bottom > 0 }
}

// MARK: - Reset data
extension AppConstant {
    static func clearAllConstants() {
        try? AppConstant.keychain.removeAll()
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys.forEach {
            #if DEBUG
            switch $0 {
            case "SERVER_TYPE", "MANUAL_HOST": return
            default: break
            }
            #endif
            defaults.removeObject(forKey: $0)
        }
    }
}
