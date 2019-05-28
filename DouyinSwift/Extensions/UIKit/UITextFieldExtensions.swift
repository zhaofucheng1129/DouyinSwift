//
//  UITextFieldExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/6.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

private var targetsKey: Void?

public extension UITextField {
    /// placeholder颜色属性
    @IBInspectable var placeholderColor: UIColor? {
        get {
            if let attrPlaceHolder = attributedPlaceholder {
                let attr = attrPlaceHolder.attributes(at: 0, effectiveRange: nil)
                return attr[.foregroundColor] as? UIColor
            } else {
                if let label = self.value(forKey: "_placeholderLabel") as? UILabel {
                    return label.textColor
                }
                return nil
            }
        }
        set {
            guard let color = newValue, let placeholder = placeholder, !placeholder.isEmpty else { return }
            if let attributedPlaceholder = attributedPlaceholder {
                let attr = NSMutableAttributedString(attributedString: attributedPlaceholder)
                attr.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: placeholder.count))
                self.attributedPlaceholder = attr
            } else {
                attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: color])
            }
        }
    }
    
    
    /// placeholder字体属性
    @IBInspectable var placeholderFont: UIFont? {
        get {
            if let attrPlaceHolder = attributedPlaceholder {
                let attr = attrPlaceHolder.attributes(at: 0, effectiveRange: nil)
                return attr[.font] as? UIFont
            } else {
                if let label = self.value(forKey: "_placeholderLabel") as? UILabel {
                    return label.font
                }
                return nil
            }
        }
        set {
            guard let font = newValue, let placeholder = placeholder, !placeholder.isEmpty else { return }
            if let attributedPlaceholder = attributedPlaceholder {
                let attr = NSMutableAttributedString(attributedString: attributedPlaceholder)
                attr.addAttribute(.font, value: font, range: NSRange(location: 0, length: placeholder.count))
                self.attributedPlaceholder = attr
            } else {
                attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.font: font])
            }
            
        }
    }
    
    /// 左侧空白距离
    @IBInspectable var paddingLeft: CGFloat {
        get {
            guard let lv = leftView else { return 0 }
            return lv.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    /// 是否为空
    var isEmpty: Bool {
        return text?.isEmpty == true
    }
    
    
    /// 返回开头和结尾没有换行和空格的字符串
    ///
    /// 不会去除字符串中间的换行和空格
    ///
    var trimmedText: String? {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    /// 去除首尾空格后字符串中包含有符合条件的Email格式字符串就返回true
    ///
    /// 对于是否选择支持online类邮箱可以考虑修改正则表达式结尾限制为{2,8}
    var hasValidEmail: Bool {
        guard let trimmedText = trimmedText, trimmedText.range(of: #"([A-Za-z0-9_\-\.])+@([A-Za-z0-9_\-\.])+.([A-Za-z]{2,4})"#,
                           options: String.CompareOptions.regularExpression,
                           range: nil, locale: nil) != nil else { return false }
        return true
    }
    
    
    /// 去除收尾空格后字符串符合Email格式返回true
    ///
    /// 对于是否选择支持online类邮箱可以考虑修改正则表达式结尾限制为{2,8}
    var isValidEmail: Bool {
        guard let text = trimmedText else { return false }
        return text.isValidEmail
    }
    
    
    /// 针对临时邮箱（也称10分钟邮箱或一次性邮箱）的白名单验证方式
    var isValueEmailByWhiteList: Bool {
        return trimmedText!.isValueEmailByWhiteList
    }
    
}

public extension UITextField {
    
    /// 清空输入框
    func clear() {
        text = ""
        attributedText = NSAttributedString(string: "")
    }    
    
    /// 添加左侧图标
    ///
    /// - Parameters:
    ///   - image: 图标
    ///   - padding: 距离大小
    func addPaddingLeftIcon(_ image: UIImage, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        leftView = imageView
        leftView?.frame.size = CGSize(width: image.size.width + padding, height: image.size.height)
        leftViewMode = .always
    }
}

public extension UITextField {
    
    
    /// 便利初始化方法
    ///
    /// - Parameters:
    ///   - frame: 位置
    ///   - placeholder: 占位文字
    ///   - borderStyle: 边框样式
    convenience init(frame: CGRect, placeholder: String? = nil, borderStyle: UITextField.BorderStyle) {
        self.init(frame: frame)
        self.placeholder = placeholder
        self.borderStyle = borderStyle
    }
}
