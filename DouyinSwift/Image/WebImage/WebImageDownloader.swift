//
//  WebImageDownloader.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public struct ImageDownloadResult {
    /// 下载完成的图片
    public let image: Image
    /// url地址
    public let url: URL?
    /// 图片原数据
    public let originalData: Data
}

public struct DownloadTask {
    
    /// 下载任务
    public let sessionTask: SessionDataTask
    
    /// 用于取消的令牌
    public let cancelToken: SessionDataTask.CancelToken
    
    /// 取消任务
    public func cancel() {
        sessionTask.cancel(token: cancelToken)
    }
}

open class WebImageDownloader {
    public static let `default` = WebImageDownloader(name: "default")
    
    open var downloadTimeout: TimeInterval = 15.0
    
    open var requestsUsePipelining = false
    
    // 信任的主机地址
    open var trustedHosts: Set<String>?
    
    /// 默认的Session配置为ephemeral 不会将高速缓存，cookie或凭据写入磁盘
    open var sessionConfiguration = URLSessionConfiguration.ephemeral {
        didSet {
            session.invalidateAndCancel()
            session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        }
    }
    /// 代理方法
    open weak var delegate: ImageDownloaderDelegate?
    
    /// 处理https鉴权操作的对象 默认是实现了默认操作的本类
    open weak var authenticationChallengeResponder: AuthenticationChallengeResponsable?
    
    private let name: String
    private let sessionDelegate: SessionDelegate
    private var session: URLSession
    
    public init(name: String) {
        if name.isEmpty {
            fatalError("下载器的名称不能为空")
        }
        self.name = name
        
        sessionDelegate = SessionDelegate()
        session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        
        authenticationChallengeResponder = self
        setupSessionHandler()
    }
    
    deinit { session.invalidateAndCancel() }
    
    private func setupSessionHandler() {
        /// 处理服务器资源鉴权
        sessionDelegate.onReceiveSessionChallenge.delegate(on: self) { (self, tuple) in
            self.authenticationChallengeResponder?.downloader(self, didReceive: tuple.1, completionHandler: tuple.2)
        }
        /// 处理服务器资源鉴权
        sessionDelegate.onReceiveSessionTaskChallenge.delegate(on: self) { (self, tuple) in
            self.authenticationChallengeResponder?.downloader(self, task: tuple.1, didReceive: tuple.2, completionHandler: tuple.3)
        }
        
        sessionDelegate.onValidStatusCode.delegate(on: self) { (self, code) in
            return (self.delegate ?? self).isValidStatusCode(code, for: self)
        }
        
        sessionDelegate.onDownloadingFinished.delegate(on: self) { (self, tuple) in
            let (url, result) = tuple
            do {
                let value = try result.get()
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: value, error: nil)
            } catch {
                self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: nil, error: error)
            }
        }
        
        sessionDelegate.onDidDownloadData.delegate(on: self) { (self, task) in
            guard let url = task.task.originalRequest?.url else {
                return task.mutableData
            }
            return (self.delegate ?? self).imageDownloader(self, didDownload: task.mutableData, for: url)
        }
    }
    
    @discardableResult
    func downloadImage(with url: URL, options: WebImageParsedOptionsInfo,
                       progressBlock: DownloadProgressBlock? = nil,
                       completionHandler: ((Result<Image, WebImageError>) -> Void)? = nil) -> DownloadTask? {
        //创建默认请求
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: downloadTimeout)
        request.httpShouldUsePipelining = requestsUsePipelining
        
        //处理错误情况
        guard let url = request.url, !url.absoluteString.isEmpty else {
            DispatchQueue.main.safeAsync {
                completionHandler?(.failure(WebImageError.requestError(reason: .invalidURL(request: request))))
            }
            return nil
        }
        
        // 将闭包对象转换为代理对象 将被SessionDataTask的TaskCallback结构体持有
        let onProgress = progressBlock.map { block -> Delegate<(Int64, Int64), Void> in
            let delegate = Delegate<(Int64, Int64), Void>()
            delegate.delegate(on: self) { (_, progress) in
                let (downloaded, total) = progress
                block(downloaded, total)
            }
            return delegate
        }
        // 完成的闭包转换为了代理对象
        let onCompleted = completionHandler.map { block -> Delegate<Result<ImageDownloadResult, WebImageError>, Void> in
            let delegate = Delegate<Result<ImageDownloadResult, WebImageError>, Void>()
            delegate.delegate(on: self) { (_, tuple) in
                switch tuple {
                case .success(let imageResult):
                    block(.success(imageResult.image))
                case .failure(let error):
                    block(.failure(error))
                }
            }
            return delegate
        }
        
        let callback = SessionDataTask.TaskCallback(onProgress: onProgress, onCompleted: onCompleted, options: options)
        
        // 将下载回调组装到下载任务当中
        let downloadTask: DownloadTask
        if let existingTask = sessionDelegate.task(for: url) {
            downloadTask = sessionDelegate.append(existingTask, url: url, callback: callback)
        } else {
            let sessionDataTask = session.dataTask(with: request)
            sessionDataTask.priority = options.downloadPriority
            downloadTask = sessionDelegate.add(sessionDataTask, url: url, callback: callback)
        }
        
        let sessionTask = downloadTask.sessionTask
        
        if !sessionTask.started {
            // 下载任务完成以后要执行的动作
            sessionTask.onTaskDone.delegate(on: self) { (self, done) in
                let (result, callbacks) = done
                do {
                    let value = try result.get()
                    self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: value.1, error: nil)
                } catch {
                    self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: nil, error: error)
                }
                
                switch result {
                case .success(let (data, response)):
                    if let image = Image(data: data) {
                        self.delegate?.imageDownloader(self, didDownload: image, for: url, with: response)
                        let imageResult = ImageDownloadResult(image: image, url: url, originalData: data)
                        callbacks.forEach{ callback in
                            DispatchQueue.main.safeAsync {
                                callback.onCompleted?.call(.success(imageResult))
                            }
                        }
                    } else {
                        let error = WebImageError.imageDecodeError(reason: .unknownImageData(raw: data))
                        self.delegate?.imageDownloader(self, didFinishDownloadingImageForURL: url, with: response, error: error)
                        callbacks.forEach{ callback in
                            DispatchQueue.main.safeAsync {
                                callback.onCompleted?.call(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    callbacks.forEach{ callback in
                        DispatchQueue.main.safeAsync {
                            callback.onCompleted?.call(.failure(error))
                        }
                    }
                }
            }
            //调用代理方法 通知将要下载图片的地址
            delegate?.imageDownloader(self, willDownloadImageForURL: url, with: request)
            //启动下载
            sessionTask.resume()
        }
        return downloadTask
    }
}

extension WebImageDownloader {
    public func cancelAll() {
        sessionDelegate.cancelAll()
    }
    
    public func cancel(url: URL) {
        sessionDelegate.cancel(url: url)
    }
}

extension WebImageDownloader: AuthenticationChallengeResponsable { }
extension WebImageDownloader: ImageDownloaderDelegate { }

/// 代理协议
public protocol ImageDownloaderDelegate: AnyObject {
    func imageDownloader(_ downloader: WebImageDownloader, willDownloadImageForURL url: URL, with request: URLRequest?)
    
    func imageDownloader(
        _ downloader: WebImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: Error?)

    func imageDownloader(_ downloader: WebImageDownloader, didDownload data: Data, for url: URL) -> Data?
    

    func imageDownloader(
        _ downloader: WebImageDownloader,
        didDownload image: Image?,
        for url: URL,
        with response: URLResponse?)
    
    func isValidStatusCode(_ code: Int, for downloader: WebImageDownloader) -> Bool
}

/// 默认代理实现
extension ImageDownloaderDelegate {
    public func imageDownloader(
        _ downloader: WebImageDownloader,
        willDownloadImageForURL url: URL,
        with request: URLRequest?) {}
    
    public func imageDownloader(
        _ downloader: WebImageDownloader,
        didFinishDownloadingImageForURL url: URL,
        with response: URLResponse?,
        error: Error?) {}
    
    public func imageDownloader(
        _ downloader: WebImageDownloader,
        didDownload image: Image?,
        for url: URL,
        with response: URLResponse?) {}
    
    public func isValidStatusCode(_ code: Int, for downloader: WebImageDownloader) -> Bool {
        return (200..<400).contains(code)
    }
    public func imageDownloader(_ downloader: WebImageDownloader, didDownload data: Data, for url: URL) -> Data? {
        return data
    }
}


/// 处理https鉴权协议
public protocol AuthenticationChallengeResponsable: AnyObject {
    func downloader(
        _ downloader: WebImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    
    func downloader(
        _ downloader: WebImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

/// 默认实现
extension AuthenticationChallengeResponsable {
    public func downloader(
        _ downloader: WebImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trustedHosts = downloader.trustedHosts, trustedHosts.contains(challenge.protectionSpace.host) {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func downloader(
        _ downloader: WebImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        completionHandler(.performDefaultHandling, nil)
    }

}
