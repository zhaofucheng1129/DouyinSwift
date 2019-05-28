//
//  WebImageSessionDataTask.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

/// 真实Task的包装类
public class SessionDataTask {
    
    /// 一个别名
    public typealias CancelToken = Int
    
    struct TaskCallback {
        let onProgress: Delegate<(Int64, Int64), Void>?
        let onCompleted: Delegate<Result<ImageDownloadResult, WebImageError>, Void>?
        let options: WebImageParsedOptionsInfo
    }
    // 任务完成时的代理
    let onTaskDone = Delegate<(Result<(Data, URLResponse?), WebImageError>, [TaskCallback]), Void>()
    // 任务取消时的代理
    let onCallbackCancelled = Delegate<(CancelToken, TaskCallback), Void>()
    
    public let task: URLSessionDataTask
    public private(set) var mutableData: Data
    
    private var callbacksStore = [CancelToken: TaskCallback]()
    private var currentToken = 0
    private let lock = DispatchSemaphore(value: 1)
    
    
    /// 表示这个任务的状态
    var started = false
    
    /// 是否含有回调任务 应该判断`task.state != .running` 但是有些情况下 任务正在取消也会是running状态
    var containsCallbacks: Bool {
        return !callbacks.isEmpty
    }
    
    /// 取得下载任务绑定的所有回调对象
    var callbacks: [TaskCallback] {
        lock.wait()
        defer { lock.signal() }
        return Array(callbacksStore.values)
    }
    
    init(task: URLSessionDataTask) {
        self.task = task
        mutableData = Data()
    }
    
    
    /// 启动任务
    func resume() {
        guard !started else { return }
        started = true
        task.resume()
    }
    
    /// 取消任务
    ///
    /// - Parameter token: 令牌
    func cancel(token: CancelToken) {
        guard let callback = removeCallback(token) else { return }
        if callbacksStore.count == 0 {
            task.cancel()
        }
        onCallbackCancelled.call((token, callback))
    }
    
    /// 取消全部任务
    func forceCancel() {
        for token in callbacksStore.keys {
            cancel(token: token)
        }
    }
    
    
    /// 添加一个回调任务
    func addCallback(_ callback: TaskCallback) -> CancelToken {
        lock.wait()
        defer { lock.signal() }
        callbacksStore[currentToken] = callback
        defer { currentToken += 1 }
        return currentToken
    }
    
    
    /// 移除任对应的回调
    func removeCallback(_ token: CancelToken) -> TaskCallback? {
        lock.wait()
        defer { lock.signal() }
        if let callback = callbacksStore[token] {
            callbacksStore[token] = nil
            return callback
        }
        return nil
    }
    
    /// 当有新数据下载时 添加到内部数据对象中
    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
}
