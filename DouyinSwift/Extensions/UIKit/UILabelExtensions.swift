//
//  UILabelExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UILabel {
    /// 使用指定字符串和字体初始化Label
    ///
    /// - Parameters:
    ///   - text: 字符串
    ///   - font: 字体
    convenience init(text: String, font: UIFont) {
        self.init()
        self.font = font
        self.text = text
    }
}


public extension UILabel {
    
    /// 返回Lable的高度
    ///
    /// - Parameter fitWidth: 宽度
    /// - Returns: 高度
    func labelHeight(fitWidth: CGFloat) -> CGFloat {
        guard let str: NSString = self.text as NSString? else { return 0 }
        let size = str.boundingRect(with: CGSize(width: fitWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin,
                                    attributes: [.font: self.font!], context: nil)
        return size.height
    }
}
