//
//  DispatchExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/9.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

struct Lock {
    static var recursive: UnsafeMutablePointer<pthread_mutex_t> {
        let lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: MemoryLayout<pthread_mutex_t>.size)
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: MemoryLayout<pthread_mutexattr_t>.size)
        pthread_mutexattr_init(attr)
        pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(lock, attr)
        pthread_mutexattr_destroy(attr)
        return lock
    }
}

extension DispatchQueue {
    /// 主线程安全的异步派发
    /// https://github.com/onevcat/Kingfisher/blob/master/Sources/Utility/CallbackQueue.swift
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
