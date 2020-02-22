//
//  RYDeviceInfoCollector.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/19.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import AdSupport
import CoreTelephony
import SystemConfiguration
import CoreLocation
import Alamofire

private let kRYNullString = "null"


class RYDeviceInfoCollector: NSObject {
    
    @objc static let shared = RYDeviceInfoCollector()
    
    func basicInfos() -> [String: Any] {
        return ["device_model": deviceModel,
                "product_type": UIDevice.productType,
                "device_model_name": UIDevice.deviceModelName,
                "os": "iOS",
                "os_version": systemVersion,
                "channel": "App Store",
                "sdk_version": "", // default is empty.
            "assistant_version": appVersion,
            "assistant_name": appDisplayName,
            "assistant_id": bundleIdentifier,
            "language": language,
            "resolution": screenResolusion,
            "timezone": timezone,
            "access": reachabilityStatus(),
            "device_id": identifierForAdvertising,
            "idfv": identifierForVerdor,
            "carrier": carrierName,
            "is_jailbroken": RYDeviceInfoCollector.adapter() // 0, 1
        ]
    }
    
    // ssp infos
    func sspInfos() -> [String: Any] {
        return ["product_type": UIDevice.productType,
                "device_model_name": UIDevice.deviceModelName,
                "os_type": "iOS",
                "os_version": systemVersion,
            "app_version": appVersion,
            "connect_type": reachabilityStatus(),
            "idfa": identifierForAdvertising,
            "idfv": identifierForVerdor,
            "timezone": timezone,
            "app_id": bundleIdentifier,
            "language": language,
            "carrier": carrierName,
            "resolution": screenResolusion,
            "location": ""
        ]
    }
    
    // MARK: - device related
    private let device = UIDevice.current
    
    var deviceModel: String {
        return device.model
    }
    
    var systemVersion: String {
        return device.systemVersion
    }
    
    private var systemName: String {
        return device.systemName
    }
    
    var identifierForVerdor: String {
        if let idfv = device.identifierForVendor {
            return idfv.uuidString
        } else {
            return kRYNullString
        }
    }
    
    var ipAddress: String {
        if let string = device.ipAddress() {
            return string
        }
        return kRYNullString
    }
    
    // MARK: - app related
    private let infoDict = Bundle.main.infoDictionary
    
    var appVersion: String {
        guard let infoDict = infoDict else { return kRYNullString }
        if let appVersion = infoDict["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
            return kRYNullString
        }
    }
    
    var appBuildVersion: String {
        guard let infoDict = infoDict else { return kRYNullString }
        if let buildVersion = infoDict["CFBundleVersion"] as? String {
            return buildVersion
        } else {
            return kRYNullString
        }
    }
    
    var appDisplayName: String {
        guard let infoDict = infoDict else { return kRYNullString }
        if let appVersion = infoDict["CFBundleDisplayName"] as? String {
            return appVersion
        } else {
            return kRYNullString
        }
    }
    
    private var language: String {
        return NSLocale.preferredLanguages.first ?? kRYNullString
    }
    
    var bundleIdentifier: String {
        guard let bundleId = Bundle.main.bundleIdentifier else { return kRYNullString }
        return bundleId
    }
    
    var identifierForAdvertising: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    /// https://developer.apple.com/library/archive/releasenotes/General/WhatsNewIniOS/Articles/iOS7.html#//apple_ref/doc/uid/TP40013162-SW1
    var mac: String {
        return "02:00:00:00:00:00"
    }
    
    func reachabilityStatus() -> String {
        var statusDecription = ""
        
        if let reachability = NetworkReachabilityManager.init() {
            reachability.startListening()
            let status = reachability.networkReachabilityStatus
            if status == .notReachable { // NotReachable
                statusDecription = "Not Reachable"
            } else if status == .reachable(.ethernetOrWiFi) { // ReachableViaWiFi
                statusDecription = "WiFi"
            } else if status == .reachable(.wwan) { // ReachableViaWWAN
                let netInfo = CTTelephonyNetworkInfo()
                if let cRAT = netInfo.currentRadioAccessTechnology {
                    switch cRAT {
                    case CTRadioAccessTechnologyGPRS,
                         CTRadioAccessTechnologyEdge,
                         CTRadioAccessTechnologyCDMA1x:
                        statusDecription = "2G"
                        
                    case CTRadioAccessTechnologyWCDMA,
                         CTRadioAccessTechnologyHSDPA,
                         CTRadioAccessTechnologyHSUPA,
                         CTRadioAccessTechnologyCDMAEVDORev0,
                         CTRadioAccessTechnologyCDMAEVDORevA,
                         CTRadioAccessTechnologyCDMAEVDORevB,
                         CTRadioAccessTechnologyeHRPD:
                        statusDecription = "3G"
                        
                    case CTRadioAccessTechnologyLTE:
                        statusDecription = "4G"
                        
                    default:
                        fatalError("error")
                    }
                }
            }
        }
        return statusDecription
    }
    
    private var carrierName: String {
        let netInfo = CTTelephonyNetworkInfo()
        if let carrier = netInfo.subscriberCellularProvider, let carrierName = carrier.carrierName, !carrierName.isEmpty {
            return carrierName
        }
        return kRYNullString
    }
    
    private var location: String {
        guard CLLocationManager.locationServicesEnabled() else { return kRYNullString }
        return kRYNullString
    }
    
}

extension RYDeviceInfoCollector {
    private var screenResolusion: String {
        return "\(Int(UIScreen.main.bounds.width)),\(Int(UIScreen.main.bounds.height))"
    }
    
    private var timezone: String {
        guard let timzoneString = TimeZone.current.abbreviation() else {
            return kRYNullString
        }
        return timzoneString
    }
}


extension UIDevice {
    private struct InterfaceNames {
        static let wifi = ["en0"]
        static let wired = ["en2", "en3", "en4"]
        static let cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
        static let supported = wifi + wired + cellular
    }
    
    fileprivate func ipAddress() -> String? {
        var ipAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr
            
            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }
                
                guard let interface = pointer?.pointee,
                    interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) || interface.ifa_addr.pointee.sa_family == UInt8(AF_INET6),
                    let interfaceName = interface.ifa_name,
                    let interfaceNameFormatted = String(cString: interfaceName, encoding: .utf8),
                    InterfaceNames.supported.contains(interfaceNameFormatted)
                    else { continue }
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                
                getnameinfo(interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST)
                
                guard let formattedIpAddress = String(cString: hostname, encoding: .utf8),
                    !formattedIpAddress.isEmpty
                    else { continue }
                
                ipAddress = formattedIpAddress
                break
            }
            
            freeifaddrs(ifaddr)
        }
        
        return ipAddress
    }
    
    /// Such as iPhone8,4: The fourth product in eighth generation phone
    static let productType: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machMirror.children.reduce("") { identifier, arg1 in
            guard let value = arg1.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if identifier.isEmpty {
            return kRYNullString
        }
        
        return identifier
    }()
    
    /// Such as iPhone XR, iPhone X ...
    static let deviceModelName: String = {
        let productTypeString = UIDevice.productType
        return deviceModelNameMapped(productTypeString)
    }()
    
    private static func deviceModelNameMapped(_ productType: String) -> String {
        #if os(iOS)
        
        switch productType {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator \(deviceModelNameMapped(ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
        default:                                        return productType
        }
        
        #elseif os(tvOS)
        switch productTypeName {
        case "AppleTV5,3": return "Apple TV 4"
        case "AppleTV6,2": return "Apple TV 4K"
        case "i386", "x86_64": return "Simulator \(deviceModelNameMapped(ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
        default: return identifier
        }
        
        #endif
    }
}

// 1、check files
// 2、check authorizations

// MARK: - JailBreak checker

extension RYDeviceInfoCollector {
    class func adapter() -> Int {
        #if !(TARGET_IPHONE_SIMULATOR)
        
        var result: Int = 0 // default value
        
        // 1. first
        if let urlScheme = URL(string: "cydia://home"), UIApplication.shared.canOpenURL(urlScheme) {
            result = 1
            return result
        }
        
        if let urlScheme = URL(string: "cydia://package/com.example.package"), UIApplication.shared.canOpenURL(urlScheme) {
            result = 1
            return result
        }
        
        // 2. second
        let filePath1 = "/Applications/Cydia.app"
        if FileManager.default.fileExists(atPath: filePath1) {
            result = 1
            return result
        }
        
        let filePath5 = "/etc/apt"
        if FileManager.default.fileExists(atPath: filePath5) {
            result = 1
            return result
        }
        
        let file6 = "/private/var/lib/apt"
        if FileManager.default.fileExists(atPath: file6) {
            result = 1
            return result
        }
        
        // failed sometimes
        let filePath2 = "/Library/MobileSubstrate/MobileSubstrate.dylib"
        if FileManager.default.fileExists(atPath: filePath2) {
            result = 1
            return result
        }
        
        // failed sometimes
        let filePath3 = "/bin/bash"
        if FileManager.default.fileExists(atPath: filePath3) {
            result = 1
            return result
        }
        
        // failed sometimes
        let filePath4 = "/usr/sbin/sshd"
        if FileManager.default.fileExists(atPath: filePath4) {
            result = 1
            return result
        }
        
        let case1 = "/Applications/Cydia.app"
        let case2 = "/Library/MobileSubstrate/MobileSubstrate.dylib"
        let case3 = "/bin/bash"
        let case4 = "/usr/sbin/sshd"
        let case5 = "/etc/apt"
        let case6 = "/usr/bin/ssh"
        
        if RYDeviceInfoCollector.canOpen(case1) ||
            RYDeviceInfoCollector.canOpen(case2) ||
            RYDeviceInfoCollector.canOpen(case3) ||
            RYDeviceInfoCollector.canOpen(case4) ||
            RYDeviceInfoCollector.canOpen(case5) ||
            RYDeviceInfoCollector.canOpen(case6) {
            result = 1
            return result
        }
        
        // 3. third step
        let string = RYDeviceInfoCollector.description()
        do {
            try string.write(toFile: "/private/string.txt", atomically: true, encoding: .utf8)
            result = 1
            return result
        } catch {
            debugPrint(error.localizedDescription)
        }
        try? FileManager.default.removeItem(atPath: "/private/string.txt")
        
        // 4. fourth step
        if let urlScheme = URL(string: "pphelperNS://"), UIApplication.shared.canOpenURL(urlScheme) {
            result = 1
            return result
        }
        
        if let urlScheme = URL(string: "com.pd.A4Player://"), UIApplication.shared.canOpenURL(urlScheme) {
            result = 1
            return result
        }
        
        if let urlScheme = URL(string: "WB3159381455://"), UIApplication.shared.canOpenURL(urlScheme) {
            result = 1
            return result
        }
        
        return result
        
        #endif
    }
    
    private class func canOpen(_ path: String) -> Bool {
        guard let file = fopen(path, "r") else { return false }
        fclose(file)
        return true
    }
}
