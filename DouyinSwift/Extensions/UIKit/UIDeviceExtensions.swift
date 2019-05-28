//
//  UIDeviceExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/8.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UIDevice {
    // 系统版本
    static func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /// 是否是iPad
    static func isPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    /// 是否为模拟器
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 是否越狱
    static func isJailbroken() -> Bool {
        if isSimulator() { return false }
        let paths = ["/Applications/Cydia.app","/private/var/lib/apt/","/private/var/lib/cydia","/private/var/stash"]
        for path in paths { if FileManager.default.fileExists(atPath: path) { return true } }
        if let fileHandler = fopen("/bin/bash", "r") { fclose(fileHandler); return true }
        let path = "/private/\(String.UUID())"
        do { try "".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {  }
        return false
    }
    
    /// 是否可以打电话
    static func canMakePhoneCall() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "tel://")!)
    }
    
    /// 设备型号
    ///
    /// e.g. "iPhone6,1" "iPad4,6"
    static func machineModel() -> String? {
        if let key = "hw.machine".cString(using: String.Encoding.utf8) {
            var size: Int = 0
            sysctlbyname(key, nil, &size, nil, 0)
//            var machine = [CChar](repeating: 0, count: Int(size))
//            sysctlbyname(key, &machine, &size, nil, 0)
//            return String(cString: machine)
            var machine = Data(count: size - 1)
            _ = machine.withUnsafeMutableBytes { (bytes) -> UnsafeMutablePointer<Int>? in
                sysctlbyname(key, bytes.baseAddress, &size, nil, 0)
                return nil
            }
            return machine.utf8String
        }
        return nil
    }
    
    
    /// 设备型号名称
    ///
    /// e.g. "iPhone 5s" "iPad mini 2"
    static func machineModelName() -> String? {
        guard let model = machineModel() else { return nil }
        let dict = [
            "Watch1,1" : "Apple Watch 38mm case",
            "Watch1,2" : "Apple Watch 38mm case",
            "Watch2,6" : "Apple Watch Series 1 38mm case",
            "Watch2,7" : "Apple Watch Series 1 42mm case",
            "Watch2,3" : "Apple Watch Series 2 38mm case",
            "Watch2,4" : "Apple Watch Series 2 42mm case",
            "Watch3,1" : "Apple Watch Series 3 38mm case (GPS+Cellular)",
            "Watch3,2" : "Apple Watch Series 3 42mm case (GPS+Cellular)",
            "Watch3,3" : "Apple Watch Series 3 38mm case (GPS)",
            "Watch3,4" : "Apple Watch Series 3 42mm case (GPS)",
            "Watch4,1" : "Apple Watch Series 4 40mm case (GPS)",
            "Watch4,2" : "Apple Watch Series 4 44mm case (GPS)",
            "Watch4,3" : "Apple Watch Series 4 40mm case (GPS+Cellular)",
            "Watch4,4" : "Apple Watch Series 4 44mm case (GPS+Cellular)",
            
            "iPod1,1" : "iPod touch 1",
            "iPod2,1" : "iPod touch 2",
            "iPod3,1" : "iPod touch 3",
            "iPod4,1" : "iPod touch 4",
            "iPod5,1" : "iPod touch 5",
            "iPod7,1" : "iPod touch 6",
            
            "iPhone1,1" : "iPhone 1G",
            "iPhone1,2" : "iPhone 3G",
            "iPhone2,1" : "iPhone 3GS",
            "iPhone3,1" : "iPhone 4 (GSM)",
            "iPhone3,2" : "iPhone 4",
            "iPhone3,3" : "iPhone 4 (CDMA)",
            "iPhone4,1" : "iPhone 4S",
            "iPhone5,1" : "iPhone 5",
            "iPhone5,2" : "iPhone 5",
            "iPhone5,3" : "iPhone 5c",
            "iPhone5,4" : "iPhone 5c",
            "iPhone6,1" : "iPhone 5S (GSM)",
            "iPhone6,2" : "iPhone 5S (Global)",
            "iPhone7,1" : "iPhone 6 Plus",
            "iPhone7,2" : "iPhone 6",
            "iPhone8,1" : "iPhone 6s",
            "iPhone8,2" : "iPhone 6s Plus",
            "iPhone8,3" : "iPhone SE (GSM+CDMA)",
            "iPhone8,4" : "iPhone SE (GSM)",
            "iPhone9,1" : "iPhone 7",
            "iPhone9,2" : "iPhone 7 Plus",
            "iPhone9,3" : "iPhone 7",
            "iPhone9,4" : "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X Global",
            "iPhone10,4": "iPhone 8",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,6": "iPhone X GSM",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max Global",
            "iPhone11,8": "iPhone XR",
            
            "iPad1,1" : "iPad",
            "iPad1,2" : "iPad 3G",
            "iPad2,1" : "2nd Gen iPad",
            "iPad2,2" : "2nd Gen iPad GSM",
            "iPad2,3" : "2nd Gen iPad CDMA",
            "iPad2,4" : "2nd Gen iPad New Revision",
            "iPad2,5" : "iPad mini",
            "iPad2,6" : "iPad mini GSM+LTE",
            "iPad2,7" : "iPad mini CDMA+LTE",
            "iPad3,1" : "3rd Gen iPad",
            "iPad3,2" : "3rd Gen iPad CDMA",
            "iPad3,3" : "3rd Gen iPad GSM",
            "iPad3,4" : "4th Gen iPad",
            "iPad3,5" : "4th Gen iPad GSM+LTE",
            "iPad3,6" : "4th Gen iPad CDMA+LTE",
            "iPad4,1" : "iPad Air (WiFi)",
            "iPad4,2" : "iPad Air (GSM+CDMA)",
            "iPad4,3" : "1st Gen iPad Air (China)",
            "iPad4,4" : "iPad mini Retina (WiFi)",
            "iPad4,5" : "iPad mini Retina (GSM+CDMA)",
            "iPad4,6" : "iPad mini Retina (China)",
            "iPad4,7" : "iPad mini 3 (WiFi)",
            "iPad4,8" : "iPad mini 3 (GSM+CDMA)",
            "iPad4,9" : "iPad mini 3 (China)",
            "iPad5,1" : "iPad mini 4 (WiFi)",
            "iPad5,2" : "iPad mini 4 (WiFi+Cellular)",
            "iPad5,3" : "iPad Air 2 (WiFi)",
            "iPad5,4" : "iPad Air 2 (Cellular)",
            "iPad6,3" : "iPad Pro (9.7 inch, WiFi)",
            "iPad6,4" : "iPad Pro (9.7 inch, WiFi+LTE)",
            "iPad6,7" : "iPad Pro (12.9 inch, WiFi)",
            "iPad6,8" : "iPad Pro (12.9 inch, WiFi+LTE)",
            "iPad6,11": "iPad (2017)",
            "iPad6,12": "iPad (2017)",
            "iPad7,1" : "iPad Pro 2nd Gen (WiFi)",
            "iPad7,2" : "iPad Pro 2nd Gen (WiFi+Cellular)",
            "iPad7,3" : "iPad Pro 10.5-inch",
            "iPad7,4" : "iPad Pro 10.5-inch",
            "iPad7,5" : "iPad 6th Gen (WiFi)",
            "iPad7,6" : "iPad 6th Gen (WiFi+Cellular)",
            "iPad8,1" : "iPad Pro 3rd Gen (11 inch, WiFi)",
            "iPad8,2" : "iPad Pro 3rd Gen (11 inch, 1TB, WiFi)",
            "iPad8,3" : "iPad Pro 3rd Gen (11 inch, WiFi+Cellular)",
            "iPad8,4" : "iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)",
            "iPad8,5" : "iPad Pro 3rd Gen (12.9 inch, WiFi)",
            "iPad8,6" : "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)",
            "iPad8,7" : "iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)",
            "iPad8,8" : "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)",
            "iPad11,1": "iPad mini 5 (WiFi)",
            "iPad11,2": "iPad mini 5 (WiFi+Cellular)",
            "iPad11,3": "iPad Air 2 (WiFi)",
            "iPad11,4": "iPad Air 2 (WiFi+Cellular)",
            
            "AppleTV2,1" : "Apple TV 2",
            "AppleTV3,1" : "Apple TV 3",
            "AppleTV3,2" : "Apple TV 3",
            "AppleTV5,3" : "Apple TV 4",
            "AppleTV6,2" : "Apple TV 5 4K",
            
            "i386" : "Simulator x86",
            "x86_64" : "Simulator x64",
        ]
        
        return dict[model]
    }
}


// MARK: - 磁盘空间
public extension UIDevice {
    /// 磁盘总空间
    static func diskSpace() -> Double? {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return nil }
        return attrs[.systemSize] as? Double
    }
    
    /// 可用磁盘空间
    static func diskSpaceFree() -> Double? {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return nil }
        return attrs[.systemFreeSize] as? Double
    }
    
    /// 已用空间
    static func diskSpaceUsed() -> Double? {
        guard let total = diskSpace(), let free = diskSpaceFree() else { return nil }
        let used = total - free
        if used > 0 { return used }
        return nil
    }
}


// MARK: - IP地址
public extension UIDevice {
    
    /// Wifi环境下IP地址
    static func ipAddressInWifi() -> String? {
        return ipAddress(ifaName: "en0")
    }
    
    
    /// 蜂窝网路环境下IP地址
    static func ipAddressInCellular() -> String? {
        return ipAddress(ifaName: "pdp_ip0")
    }
    
    
    /// 取得IP地址
    /// 参考 https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address
    private static func ipAddress(ifaName: String) -> String? {
        guard !ifaName.isEmpty else { return nil }
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            guard addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) else { continue }
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            guard name == ifaName else { continue }
            // Convert interface address to a human readable string:
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0), NI_NUMERICHOST)
            address = String(cString: hostname)
        }
        
        return address
    }
    
}

public extension UIDevice {
    
    /// CPU核心数量
    static func cpuCount() -> Int {
        return ProcessInfo.processInfo.activeProcessorCount
    }
    
    
    /// CPU使用量
    static func cpuUsage() -> Double? {
        guard let cpus = cpuUsagePerProcessor(), cpus.count > 0 else { return nil }
        return cpus.reduce(0, { $0 + $1 })
    }
    
    
    /// 每颗CPU核心的CPU使用量
    static func cpuUsagePerProcessor() -> [Double]? {
        var cpuInfo: processor_info_t? = nil
        let prevCPUInfo: processor_info_t? = nil
        var numCPUInfo: mach_msg_type_number_t = 0
        let numPrevCPUInfo: mach_msg_type_number_t = 0
        
        var numCPUs: Int32 = 0
        let cpuUsageLock = NSLock()
        
        var mib = [CTL_HW, HW_NCPU]
        var sizeOfNumCPUs = MemoryLayout.size(ofValue: numCPUs)
        if sysctl(&mib, 2, &numCPUs, &sizeOfNumCPUs, nil, 0) != 0 {
            numCPUs = 1
        }
        
        var numCPUsU: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCPUInfo)
        guard result == KERN_SUCCESS else { return nil }
        cpuUsageLock.lock()
        var cpus = [Double]()
        (0..<numCPUs).forEach { (i) in
            var inUse: Double = 0
            var total: Double = 0
            if let prevCPUInfo = prevCPUInfo, let cpuInfo = cpuInfo {
                inUse = Double((cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_USER)]   - prevCPUInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_USER)])
                    + (cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_SYSTEM)] - prevCPUInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_SYSTEM)])
                    + (cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_NICE)]   - prevCPUInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_NICE)]))
                
                total = inUse + Double((cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_IDLE)] - prevCPUInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_IDLE)]))
            } else {
                if let cpuInfo = cpuInfo {
                    inUse = Double(cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_USER)] + cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_SYSTEM)] + cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_NICE)]);
                    total = inUse + Double(cpuInfo[Int((CPU_STATE_MAX * i) + CPU_STATE_IDLE)]);
                }
            }
            cpus.append(inUse / total)
        }
        cpuUsageLock.unlock()
        if let prevCPUInfo = prevCPUInfo {
            let prevCpuInfoSize = MemoryLayout<integer_t>.size * Int(numPrevCPUInfo)
            vm_deallocate(mach_task_self_, vm_address_t(prevCPUInfo.pointee), vm_size_t(prevCpuInfoSize))
        }
        return cpus
    }
}
