//
//  WebImageSessionDelegate.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class SessionDelegate: NSObject {

    /// onReceiveSessionChallenge的代理参数元组
    /// urlSession(_:didReceive:completionHandler:)
    typealias SessionChallengeFunc = (
        URLSession,
        URLAuthenticationChallenge,
        (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
    /// onReveiveSessionTaskChallenge代理参数元组
    /// urlSession(_:task:didReceive:completionHandler:)
    typealias SessionTaskChallengeFunc = (
        URLSession,
        URLSessionTask,
        URLAuthenticationChallenge,
        (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
    
    
    // 在访问资源的时候，如果服务器返回需要授权(提供一个URLCredential对象)
    // 那么该方法就回被调用（这个是URLSessionDelegate代理方法）
    let onReceiveSessionChallenge = Delegate<SessionChallengeFunc, Void>()
    /// URLSessionTaskDelegate代理方法
    let onReceiveSessionTaskChallenge = Delegate<SessionTaskChallengeFunc, Void>()

    
    /// 判断http状态码
    let onValidStatusCode = Delegate<Int, Bool>()
    /// 下载完成后回调
    let onDownloadingFinished = Delegate<(URL, Result<URLResponse, WebImageError>), Void>()
    /// 下载完成后回调 返回下载后的数据
    let onDidDownloadData = Delegate<SessionDataTask, Data?>()

    
    private var tasks: [URL: SessionDataTask] = [:]
    private let lock = DispatchSemaphore(value: 1)
    
    func add(_ dataTask: URLSessionDataTask,
             url: URL,
             callback: SessionDataTask.TaskCallback) -> DownloadTask {
        lock.wait()
        defer { lock.signal() }
        let task = SessionDataTask(task: dataTask)
        task.onCallbackCancelled.delegate(on: self) { [unowned task](self, tuple) in
            let (token, callback) = tuple
            let error = WebImageError.requestError(reason: .taskCancelled(task: task, token: token))
            task.onTaskDone.call((.failure(error), [callback]))
            if !task.containsCallbacks {
                let dataTask = task.task
                self.remove(dataTask)
            }
        }
        let token = task.addCallback(callback)
        tasks[url] = task
        return DownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func append(_ task: SessionDataTask, url: URL, callback: SessionDataTask.TaskCallback) -> DownloadTask {
        let token = task.addCallback(callback)
        return DownloadTask(sessionTask: task, cancelToken: token)
    }
    
    func task(for url: URL) -> SessionDataTask? {
        lock.wait()
        defer { lock.signal() }
        return tasks[url]
    }
    
    /// 从数组中取出代理的下载任务
    private func task(for task: URLSessionTask) -> SessionDataTask? {
        guard let url = task.originalRequest?.url else { return nil }
        
        lock.wait()
        defer { lock.signal() }
        
        guard let sessionTask = tasks[url] else { return nil }
        guard sessionTask.task.taskIdentifier == task.taskIdentifier else { return nil }
        return sessionTask
    }
    
    /// 从数组中删除代理任务
    private func remove(_ task: URLSessionTask) {
        guard let url = task.originalRequest?.url else { return }
        lock.wait()
        defer { lock.signal() }
        tasks[url] = nil
    }
    
    func cancelAll() {
        lock.wait()
        let taskValues = tasks.values
        lock.signal()
        for task in taskValues {
            task.forceCancel()
        }
    }
    
    func cancel(url: URL) {
        lock.wait()
        let task = tasks[url]
        lock.signal()
        task?.forceCancel()
    }
}


extension SessionDelegate: URLSessionDataDelegate {
    
    
    /// 判断请求响应是否成功
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // 判断http响应数据是否有效
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = WebImageError.responseError(reason: .invalidURLResponse(response: response))
            onCompleted(task: dataTask, result: .failure(error))
            completionHandler(.cancel)
            return
        }
        
        //判断状态码是否有效
        let httpStatusCode = httpResponse.statusCode
        guard onValidStatusCode.call(httpStatusCode) == true else {
            let error = WebImageError.responseError(reason: .invalidHTTPStatusCode(response: httpResponse))
            onCompleted(task: dataTask, result: .failure(error))
            completionHandler(.cancel)
            return
        }
        //通过请求
        completionHandler(.allow)
    }
    
    /// 接收数据代理
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = task(for: dataTask) else { return }
        task.didReceiveData(data)
        // 取得下载数据的总长度和已下载数据的长度作进度回调
        if let expectedContentLength = dataTask.response?.expectedContentLength, expectedContentLength != -1 {
            // 使用Int64 防止数据太大 整形越界
            let dataLength = Int64(task.mutableData.count)
            DispatchQueue.main.async {
                task.callbacks.forEach { callback in
                    callback.onProgress?.call((dataLength, expectedContentLength))
                }
            }
        }
    }
    
    /// 下载完成或者发生错误
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let sessionTask = self.task(for: task) else { return }
        if let url = task.originalRequest?.url {
            let result: Result<URLResponse, WebImageError>
            if let error = error {
                result = .failure(WebImageError.responseError(reason: .URLSessionError(error: error)))
            } else if let response = task.response {
                result = .success(response)
            } else {
                result = .failure(WebImageError.responseError(reason: .noURLResponse(task: sessionTask)))
            }
            onDownloadingFinished.call((url, result))
        }
        
        let result: Result<(Data, URLResponse?), WebImageError>
        if let error = error {
            result = .failure(WebImageError.responseError(reason: .URLSessionError(error: error)))
        } else {
            if let data = onDidDownloadData.call(sessionTask), let finalData = data {
                result = .success((finalData, task.response))
            } else {
                result = .failure(WebImageError.responseError(reason: .dataModifyingFailed(task: sessionTask)))
            }
        }
        onCompleted(task: task, result: result)
    }
    
    /// 处理服务器资源鉴权
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        /// 被代理给ImageDownloader的默认 AuthenticationChallengeResponder协议默认提供的鉴权操作
        onReceiveSessionChallenge.call((session, challenge, completionHandler))
    }
    /// 处理服务器资源鉴权
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        onReceiveSessionTaskChallenge.call((session, task, challenge, completionHandler))
    }
    
    /// 处理重定向
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let sessionDataTask = self.task(for: task),
        let redirectHandler = Array(sessionDataTask.callbacks).last?.options.redirectHandler else {
            completionHandler(request)
            return
        }
        // 调用到options指定的重定向处理对象
        redirectHandler.handleHTTPRedirection(for: sessionDataTask, response: response, newRequest: request, completionHandler: completionHandler)
    }
    
    
    /// 下载任务的回调
    private func onCompleted(task: URLSessionTask, result: Result<(Data, URLResponse?), WebImageError>) {
        guard let sessionTask = self.task(for: task) else {
            return
        }
        remove(task)
        sessionTask.onTaskDone.call((result, sessionTask.callbacks))
    }
}
