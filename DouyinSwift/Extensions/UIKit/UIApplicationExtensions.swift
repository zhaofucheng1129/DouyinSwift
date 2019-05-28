//
//  UIApplicationExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/9.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

private var networkActivityInfoKey: Void?

public extension UIApplication {
    /// 检查是否被破解
    /// true: 被破解 false: 没破解
    static var isCracked: Bool {        
        if getgid() <= 10 { return true } ///取得执行目前进程的组识别码 识别权限是否过高
        if Bundle.main.object(forInfoDictionaryKey: "SignerIdentity") != nil { return true }
        if !FileManager.fileExistInMainBundle(fileName: "SC_Info") { return true }
        if !FileManager.fileExistInMainBundle(fileName: "iTunesMetadata.plist") { return true }
        if !FileManager.fileExistInMainBundle(fileName: "ResourceRules.plist") { return true }
        if !FileManager.fileExistInMainBundle(fileName: "_CodeSignature") { return true }
        return false
    }
}

// MARK: - 性能
public extension UIApplication {
    
    /// 准确的应用占用内存量
    /// http://www.samirchen.com/ios-app-memory-usage/
    static var memoryUsage: Double? {
        var info = task_vm_info_data_t()
        var size = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<natural_t>.size)
        let kern: kern_return_t = withUnsafeMutablePointer(to: &info) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0.withMemoryRebound(to: Int32.self, capacity: 1, {
                task_info_t($0)
            }), &size)
        }
        guard kern == KERN_SUCCESS else { return nil }
        return Double(info.phys_footprint)
    }
    
    
    /// 应用CPU使用量
    /// 参考 https://github.com/zixun/GodEye/blob/master/Carthage/Checkouts/SystemEye/SystemEye/Classes/CPU.swift
    static func cpuUsage() -> Double? {
        var info = mach_task_basic_info()
        var size = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<natural_t>.size)
        var kern: kern_return_t = withUnsafeMutablePointer(to: &info) {
            task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0.withMemoryRebound(to: Int32.self, capacity: 1, {
                task_info_t($0)
            }), &size)
        }
        guard kern == KERN_SUCCESS else { return nil }
        
        var thread_list: thread_array_t? = nil
        var thread_count = mach_msg_type_number_t()
        
        kern = task_threads(mach_task_self_, &thread_list, &thread_count)
        guard kern == KERN_SUCCESS else { return nil }
        
        guard let thread_array = thread_list else { return nil }
        
        let thinfo: thread_info_t = thread_info_t.allocate(capacity: Int(THREAD_INFO_MAX))
        var thread_info_count: mach_msg_type_number_t = mach_msg_type_number_t()
        var base_info_th: thread_basic_info_t? = nil
        
        var tot_sec: Double = 0
        var tot_usec: Double = 0
        var tot_cpu: Double = 0
        
        (0..<Int(thread_count)).forEach { (index) in
            thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            kern = thread_info(thread_array[index], task_flavor_t(THREAD_BASIC_INFO), thinfo, &thread_info_count)
            guard kern == KERN_SUCCESS else { return }
            base_info_th = withUnsafePointer(to: thinfo, { (ptr) -> thread_basic_info_t? in
                let int8Ptr = ptr.withMemoryRebound(to: thread_basic_info_t.self, capacity: 1, {
                    return $0.pointee
                })
                return int8Ptr
            })
            if let baseInfo = base_info_th?.pointee, (baseInfo.flags & TH_FLAGS_IDLE) == 0 {
                tot_sec = tot_sec + Double(baseInfo.user_time.seconds + baseInfo.system_time.seconds)
                tot_usec = tot_usec + Double(baseInfo.system_time.microseconds + baseInfo.system_time.microseconds)
                tot_cpu = tot_cpu + Double(baseInfo.cpu_usage) / Double(TH_USAGE_SCALE)
            }
        }
        
        kern = vm_deallocate(mach_task_self_, vm_address_t(thread_list!.pointee), vm_size_t(thread_count * UInt32(MemoryLayout<thread_t>.size)))
        assert(kern == KERN_SUCCESS)
        return tot_cpu
    }
}

// MARK: - 网路指示器
public extension UIApplication {
    
    /// 增加网络活动数量并显示网络指示器，线程安全
    static func incrementNetworkActivity(count: Int = 1) {
        UIApplication.shared.incrementNetworkActivity(count: count)
    }
    
    /// 减少网路活动数量，当网络活动数量为0，网络指示器就会停止，线程安全
    static func decrementNetworkActivity(count: Int = 1) {
        UIApplication.shared.decrementNetworkActivity(count: count)
    }
    
    /// 增加网络活动数量并显示网络指示器，线程安全
    func incrementNetworkActivity(count: Int = 1) {
        changeNetworkActivity(num: count)
    }
    
    /// 减少网路活动数量，当网络活动数量为0，网络指示器就会停止，线程安全
    func decrementNetworkActivity(count: Int = 1) {
        changeNetworkActivity(num: -count)
    }
    
    private var networkActivityInfo: NetworkIndicatorInfo? {
        get { return objc_getAssociatedObject(self, &networkActivityInfoKey) as? NetworkIndicatorInfo }
        set { objc_setAssociatedObject(self, &networkActivityInfoKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private struct NetworkIndicatorInfo {
        var count: Int = 0
        var timer: Timer?
        init(count: Int) {
            self.count = count
        }
    }
    
    private func changeNetworkActivity(num: Int) {
        let lock = DispatchSemaphore(value: 1)
        DispatchQueue.main.safeAsync {
            lock.wait()
            var count = num
            let oldInfo = self.networkActivityInfo
            if let oldInfo = oldInfo {
                count += oldInfo.count
                oldInfo.timer?.invalidate()
            }
            
            var newInfo = NetworkIndicatorInfo(count: count)
            let timer = Timer(timeInterval: 1.0 / 30, target: self, selector: #selector(self.delaySetActivity(timer:)), userInfo: newInfo.count > 0, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            newInfo.timer = timer
            self.networkActivityInfo = newInfo
            lock.signal()
        }
    }
    
    @objc private func delaySetActivity(timer: Timer) {
        guard let visiable = timer.userInfo as? Bool, isNetworkActivityIndicatorVisible != visiable else { return }
        isNetworkActivityIndicatorVisible = visiable
        timer.invalidate()
    }
}
