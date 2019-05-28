//
//  UIScrollViewExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/10.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UIScrollView {
    /// 返回视图快照
    override var snapshotImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(contentSize, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension UIScrollView {
    
    /// 滚动到顶部
    ///
    /// - Parameter animated: 是否启用动画
    func scrollToTop(animated: Bool = true) {
        scroll(to: .top, animated: animated)
    }
    
    /// 滚动到底部
    ///
    /// - Parameter animated: 是否启用动画
    func scrollToBottom(animated: Bool = true) {
        scroll(to: .bottom, animated: animated)
    }
    
    /// 滚动到最左边
    ///
    /// - Parameter animated: 是否启用动画
    func scrollToLeft(animated: Bool = true) {
        scroll(to: .left, animated: animated)
    }
    
    /// 滚动到最右边
    ///
    /// - Parameter animated: 是否启用动画
    func scrollToRight(animated: Bool = true) {
        scroll(to: .right, animated: animated)
    }
}

public extension UIScrollView {
    fileprivate enum ScrollDirection {
        case top
        case bottom
        case left
        case right
    }
    
    fileprivate func scroll(to direction: ScrollDirection, animated: Bool = true) {
        var offset = contentOffset
        switch direction {
        case .top:
            offset.y = 0 - contentInset.top
        case .bottom:
            offset.y = contentSize.height - bounds.size.height + contentInset.bottom
        case .left:
            offset.x = 0 - contentInset.left
        case .right:
            offset.x = contentSize.width - bounds.size.width + contentInset.right
        }
        setContentOffset(offset, animated: animated)
    }
}
