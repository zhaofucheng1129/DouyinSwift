//
//  Extensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

extension ImageView: WrapperObject { }

extension Wrapper where Base: ImageView {
    
    @discardableResult
    public func image(with url: URL, placeholder: UIView? = nil, options: WebImageOptionsInfo? = nil,
                      progressBlock: DownloadProgressBlock? = nil,
                      completionHandler: ((Result<Image, WebImageError>) -> Void)? = nil) -> DownloadTask? {
        var mutatingSelf = self
        
        //防止options为空 使用默认的空数组做后续操作
        let options = WebImageParsedOptionsInfo(WebImageManager.shared.defaultOptions + (options ?? .empty))
        let noImageOrPlaceholderSet = base.image == nil && self.placeholder == nil
        if !options.keepCurrentImageWhileLoading || noImageOrPlaceholderSet {
            mutatingSelf.placeholder = placeholder
        }
        
        //保存一个标示 用来判断回调时还是否是当前ImageView 在TableView重用时将起作用
        let issuedIdentifier = Identifier.next()
        mutatingSelf.taskIdentifier = issuedIdentifier
        
        
        let task = WebImageManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            guard issuedIdentifier == self.taskIdentifier else { return }
            if let progressBlock = progressBlock {
                progressBlock(receivedSize, totalSize)
            }
        }) { result in
            DispatchQueue.main.safeAsync {
                // 如果发现下载完成后和之前的ImageView不一致了 会回调一个错误信息
                guard issuedIdentifier == self.taskIdentifier else {
                    let reason: WebImageError.ImageSettingErrorReason
                    do {
                        let value = try result.get()
                        reason = .notCurrentSourceTask(result: value, error: nil, source: url)
                    } catch {
                        reason = .notCurrentSourceTask(result: nil, error: error, source: url)
                    }
                    let error = WebImageError.imageSettingError(reason: reason)
                    completionHandler?(.failure(error))
                    return
                }
                
                mutatingSelf.imageTask = nil
                
                switch result {
                case .success(let value):
                    mutatingSelf.placeholder = nil
                    self.base.image = value
                    completionHandler?(result)
                    return
                case .failure:
                    completionHandler?(result)
                }
            }
        }
        
        mutatingSelf.imageTask = task
        return task
    }
    
}

class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

public enum Identifier {
    /// The underlying value type of source identifier.
    public typealias Value = UInt
    static var current: Value = 0
    static func next() -> Value {
        current += 1
        return current
    }
}

private var placeholderKey: Void?
private var taskIdentifierKey: Void?
private var imageTaskKey: Void?

extension Wrapper where Base: ImageView {
    
    private var imageTask: DownloadTask? {
        get { return objc_getAssociatedObject(base, &imageTaskKey) as? DownloadTask }
        set { objc_setAssociatedObject(base, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public private(set) var taskIdentifier: Identifier.Value? {
        get {
            let b: Box<Identifier.Value>? = objc_getAssociatedObject(base, &taskIdentifierKey) as? Box<Identifier.Value>
            return b?.value
        }
        set {
            let b = newValue.map { Box($0) }
            objc_setAssociatedObject(base, &taskIdentifierKey, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public private(set) var placeholder: UIView? {
        get { return objc_getAssociatedObject(base, &placeholderKey) as? UIView }
        set {
            if let previousPlaceholder = placeholder {
                previousPlaceholder.removeFromSuperview()
            }
            
            if let newPlaceholder = newValue {
                base.addSubview(newPlaceholder)
                newPlaceholder.translatesAutoresizingMaskIntoConstraints = false
                
                if #available(iOS 9.0, *) {
                    newPlaceholder.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
                    newPlaceholder.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
                    newPlaceholder.heightAnchor.constraint(equalTo: base.heightAnchor).isActive = true
                    newPlaceholder.widthAnchor.constraint(equalTo: base.widthAnchor).isActive = true
                } else {
                    let width = NSLayoutConstraint(item: newPlaceholder, attribute: .width, relatedBy: .equal, toItem: base, attribute: .width, multiplier: 1, constant: 0)
                    let height = NSLayoutConstraint(item: newPlaceholder, attribute: .height, relatedBy: .equal, toItem: base, attribute: .height, multiplier: 1, constant: 0)
                    let centerX = NSLayoutConstraint(item: newPlaceholder, attribute: .centerX, relatedBy: .equal, toItem: base, attribute: .centerX, multiplier: 1, constant: 0)
                    let centerY = NSLayoutConstraint(item: newPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: base, attribute: .centerY, multiplier: 1, constant: 0)
                    base.addConstraints([width, height, centerX, centerY])
                }
            } else {
                base.image = nil
            }
            objc_setAssociatedObject(base, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
