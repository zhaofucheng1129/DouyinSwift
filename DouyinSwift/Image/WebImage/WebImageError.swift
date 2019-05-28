//
//  WebImageError.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public enum WebImageError: Error {
    
    public enum ResponseErrorReason {
        
        // 无效的http响应 Code 2001
        case invalidURLResponse(response: URLResponse)
        
        // http返回状态码无效 默认检查 200..<400 Code 2002.
        case invalidHTTPStatusCode(response: HTTPURLResponse)
        
        // URLSession回调产生了错误 Code 2003.
        case URLSessionError(error: Error)
        
        // 取得下载任务的数据失败 Code 2004.
        case dataModifyingFailed(task: SessionDataTask)
        
        // 任务完成了，没有对应的响应 Code 2005.
        case noURLResponse(task: SessionDataTask)
    }
    
    public enum RequestErrorReason {
        
        /// The request is empty. Code 1001.
        case emptyRequest
        
        /// The URL of request is invalid. Code 1002.
        /// - request: The request is tend to be sent but its URL is invalid.
        case invalidURL(request: URLRequest)
        
        /// 下载任务取消
        case taskCancelled(task: SessionDataTask, token: SessionDataTask.CancelToken)
    }
    
    public enum ImageSettingErrorReason {
        
        /// 给出的下载地址错误 Code 5001.
        case emptySource
        
        /// Code 5002.
        case notCurrentSourceTask(result: Image?, error: Error?, source: URL)
    }
    
    public enum ImageDecodeErrorReason {
        // 未知的图片数据 Code 6001
        case unknownImageData(raw: Data)
    }
    
    case responseError(reason: ResponseErrorReason)
    
    case requestError(reason: RequestErrorReason)
    
    case imageSettingError(reason: ImageSettingErrorReason)
    
    case imageDecodeError(reason: ImageDecodeErrorReason)
}

extension WebImageError.ImageDecodeErrorReason {
    var errorDescription: String? {
        switch self {
        case .unknownImageData(raw: _):
            return "未知格式的图片数据"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .unknownImageData(raw: _):
            return 6001
        }
    }
}

extension WebImageError.ImageSettingErrorReason {
    var errorDescription: String? {
        switch self {
        case .emptySource:
            return "The input resource is empty."
        case .notCurrentSourceTask(let result, let error, let resource):
            if let result = result {
                return "Retrieving resource succeeded, but this source is " +
                "not the one currently expected. Result: \(result). Resource: \(resource)."
            } else if let error = error {
                return "Retrieving resource failed, and this resource is " +
                "not the one currently expected. Error: \(error). Resource: \(resource)."
            } else {
                return nil
            }
        }
    }
    
    var errorCode: Int {
        switch self {
        case .emptySource: return 5001
        case .notCurrentSourceTask: return 5002
        }
    }
}

