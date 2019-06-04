//
//  UIbuttonExtensions.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/29.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

extension UIButton: WrapperObject { }

extension Wrapper where Base: UIButton {
    
    @discardableResult
    public func image(with url: URL, for state: UIControl.State,placeholder: UIImage? = nil,
                      options: WebImageOptionsInfo? = nil,progressBlock: DownloadProgressBlock? = nil,
                      completionHandler: ((Result<Image, WebImageError>) -> UIImage?)? = nil) -> DownloadTask? {
        if let placeholder = placeholder {
            base.setImage(placeholder.withRenderingMode(.alwaysOriginal), for: state)
        }
        
        var mutatingSelf = self
        let issuedTaskIdentifier = Identifier.next()
        setTaskIdentifier(issuedTaskIdentifier, for: state)
        
        let options =  WebImageParsedOptionsInfo(WebImageManager.shared.defaultOptions + (options ?? .empty))
        if !options.keepCurrentImageWhileLoading {
            base.setImage(placeholder?.withRenderingMode(.alwaysOriginal), for: state)
        }
        
        let task = WebImageManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            guard issuedTaskIdentifier == self.taskIdentifier(for: state) else { return }
            if let progressBlock = progressBlock {
                progressBlock(receivedSize, totalSize)
            }
        },completionHandler: { result in
                DispatchQueue.main.safeAsync  {
                    guard issuedTaskIdentifier == self.taskIdentifier(for: state) else {
                        let reason: WebImageError.ImageSettingErrorReason
                        do {
                            let value = try result.get()
                            reason = .notCurrentSourceTask(result: value, error: nil, source: url)
                        } catch {
                            reason = .notCurrentSourceTask(result: nil, error: error, source: url)
                        }
                        let error = WebImageError.imageSettingError(reason: reason)
                        _ = completionHandler?(.failure(error))
                        return
                    }
                    
                    mutatingSelf.imageTask = nil
                    
                    switch result {
                    case .success(let value):
                        if let image = completionHandler?(result) {
                            self.base.setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                        } else {
                            self.base.setImage((value as UIImage).withRenderingMode(.alwaysOriginal), for: state)
                        }
                        return
                    case .failure:
                        _ = completionHandler?(result)
                    }
                }
        })
        
        mutatingSelf.imageTask = task
        return task
    }
    
    @discardableResult
    public func backgroundImage(with url: URL, for state: UIControl.State, placeholder: UIImage? = nil,
                                options: WebImageOptionsInfo? = nil,progressBlock: DownloadProgressBlock? = nil,
                                completionHandler: ((Result<Image, WebImageError>) -> UIImage?)? = nil) -> DownloadTask? {
        if let placeholder = placeholder {
            base.setBackgroundImage(placeholder.withRenderingMode(.alwaysOriginal), for: state)
        }
        
        var mutatingSelf = self
        let issuedTaskIdentifier = Identifier.next()
        setBackgroundTaskIdentifier(issuedTaskIdentifier, for: state)
        
        let options =  WebImageParsedOptionsInfo(WebImageManager.shared.defaultOptions + (options ?? .empty))
        if !options.keepCurrentImageWhileLoading {
            base.setBackgroundImage(placeholder?.withRenderingMode(.alwaysOriginal), for: state)
        }
        
        let task = WebImageManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            guard issuedTaskIdentifier == self.backgroundTaskIdentifier(for: state) else { return }
            if let progressBlock = progressBlock {
                progressBlock(receivedSize, totalSize)
            }
        },completionHandler: { result in
            DispatchQueue.main.safeAsync  {
                guard issuedTaskIdentifier == self.backgroundTaskIdentifier(for: state) else {
                    let reason: WebImageError.ImageSettingErrorReason
                    do {
                        let value = try result.get()
                        reason = .notCurrentSourceTask(result: value, error: nil, source: url)
                    } catch {
                        reason = .notCurrentSourceTask(result: nil, error: error, source: url)
                    }
                    let error = WebImageError.imageSettingError(reason: reason)
                    _ = completionHandler?(.failure(error))
                    return
                }
                
                mutatingSelf.imageTask = nil
                
                switch result {
                case .success(let value):
                    if let image = completionHandler?(result) {
                        self.base.setBackgroundImage(image.withRenderingMode(.alwaysOriginal), for: state)
                    } else {
                        self.base.setBackgroundImage((value as UIImage).withRenderingMode(.alwaysOriginal), for: state)
                    }
                    return
                case .failure:
                    _ = completionHandler?(result)
                }
            }
        })
        
        mutatingSelf.imageTask = task
        return task
    }
}

private var taskIdentifierKey: Void?
private var imageTaskKey: Void?

extension Wrapper where Base: UIButton {
    public func taskIdentifier(for state: UIControl.State) -> Identifier.Value? {
        return (taskIdentifierInfo[NSNumber(value:state.rawValue)] as? Box<Identifier.Value>)?.value
    }
    
    private func setTaskIdentifier(_ identifier: Identifier.Value?, for state: UIControl.State) {
        taskIdentifierInfo[NSNumber(value:state.rawValue)] = identifier.map { Box($0) }
    }
    
    private var taskIdentifierInfo: NSMutableDictionary {
        get {
            guard let dictionary: NSMutableDictionary = objc_getAssociatedObject(base, &taskIdentifierKey) as? NSMutableDictionary else {
                let dic = NSMutableDictionary()
                var mutatingSelf = self
                mutatingSelf.taskIdentifierInfo = dic
                return dic
            }
            return dictionary
        }
        set {
            objc_setAssociatedObject(base, &taskIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var imageTask: DownloadTask? {
        get { return objc_getAssociatedObject(base, &imageTaskKey) as? DownloadTask }
        set { objc_setAssociatedObject(base, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private var backgroundTaskIdentifierKey: Void?
private var backgroundImageTaskKey: Void?

extension Wrapper where Base: UIButton {
    public func backgroundTaskIdentifier(for state: UIControl.State) -> Identifier.Value? {
        return (backgroundTaskIdentifierInfo[NSNumber(value: state.rawValue)] as? Box<Identifier.Value>)?.value
    }
    
    private func setBackgroundTaskIdentifier(_ identifier: Identifier.Value?, for state: UIControl.State) {
        backgroundTaskIdentifierInfo[NSNumber(value:state.rawValue)] = identifier.map { Box($0) }
    }
    
    private var backgroundTaskIdentifierInfo: NSMutableDictionary {
        get {
            guard let dictionary: NSMutableDictionary = objc_getAssociatedObject(base, &backgroundTaskIdentifierKey) as? NSMutableDictionary else {
                let dict = NSMutableDictionary()
                var mutatingSelf = self
                mutatingSelf.backgroundTaskIdentifierInfo = dict
                return dict
            }
            return dictionary
        }
        set {
            objc_setAssociatedObject(base, &backgroundTaskIdentifierKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var backgroundImageTask: DownloadTask? {
        get { return objc_getAssociatedObject(base, &backgroundImageTaskKey) as? DownloadTask }
        set { objc_setAssociatedObject(base, &backgroundImageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
