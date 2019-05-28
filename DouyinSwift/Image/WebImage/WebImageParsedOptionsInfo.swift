//
//  WebImageParsedOptionsInfo.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public typealias WebImageOptionsInfo = [WebImageOptionsInfoItem]

extension Array where Element == WebImageOptionsInfoItem {
    static let empty: WebImageOptionsInfo = []
}

public enum WebImageOptionsInfoItem {
    case redirectHandler(ImageDownloadRedirectHandler)
    case forceRefresh
    // 指定优先级 0.0～1.0
    case downloadPriority(Float)
}

public struct WebImageParsedOptionsInfo {
    // 重定向处理对象
    public var redirectHandler: ImageDownloadRedirectHandler? = nil
    // 强制刷新缓存
    public var forceRefresh = false
    // 默认优先级
    public var downloadPriority: Float = URLSessionTask.defaultPriority
    
    public var keepCurrentImageWhileLoading = false
    
    public init(_ info: WebImageOptionsInfo?) {
        guard let info = info else { return }
        for option in info {
            switch option {
            case .redirectHandler(let value): redirectHandler = value
            case .forceRefresh: forceRefresh = true
            case .downloadPriority(let value): downloadPriority = value
            }
        }
    }
}
