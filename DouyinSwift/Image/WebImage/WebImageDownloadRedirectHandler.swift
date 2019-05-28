//
//  ImageDownloadRedirectHandler.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/22.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public protocol ImageDownloadRedirectHandler {
    //当出触发重定向时 代理方法会调用这个协议方法
    func handleHTTPRedirection(
        for task: SessionDataTask,
        response: HTTPURLResponse,
        newRequest: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
}
