//
//  StringExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/6.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String {
    /// 生成UUID
    static func UUID() -> String {
        let uuid = CFUUIDCreate(nil)
        let str = CFUUIDCreateString(nil, uuid)!
        return str as String
    }
    
    /// 指定字体单行高度
    ///
    /// - Parameter font: 字体
    /// - Returns: 高度
    func height(for font: UIFont) -> CGFloat {
        return size(for: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: .byWordWrapping).height
    }
    
    /// 指定字体单行宽度
    ///
    /// - Parameter font: 字体
    /// - Returns: 宽度
    func width(for font: UIFont) -> CGFloat {
        return size(for: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: .byWordWrapping).width
    }
    
    /// 计算指定字体的尺寸
    ///
    /// - Parameters:
    ///   - font: 字体
    ///   - size: 区域大小
    ///   - lineBreakMode: 换行模式
    /// - Returns: 尺寸
    func size(for font: UIFont, size: CGSize, lineBreakMode: NSLineBreakMode) -> CGSize {
        var attr:[NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        if lineBreakMode != .byWordWrapping {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode
            attr[.paragraphStyle] = paragraphStyle
        }
        let rect = (self as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        return rect.size
    }
    
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - options: 匹配选项
    /// - Returns: 是否匹配
    func matches(regex: String, options: NSRegularExpression.Options) -> Bool {
        guard let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return false }
        return pattern.numberOfMatches(in: self, options: [], range: rangeOfAll) > 0
    }
    
    
    /// 枚举所有正则表达式匹配项
    ///
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - options: 匹配选项
    ///   - closure: 功能闭包
    func enumerate(regex: String, options: NSRegularExpression.Options, closure: (_ match: String, _ matchRange: Range<String.Index>,_ stop: UnsafeMutablePointer<ObjCBool>) -> Void) {
        guard regex.isNotBlank else { return }
        guard let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return }
        pattern.enumerateMatches(in: self, options: [], range: rangeOfAll) { (result, flags, stop) in
            if let result = result, let range = range(for: result.range) {
                closure(String(self[range]), range, stop)
            }
        }
    }
    
    
    /// 正则替换
    ///
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - options: 匹配选项
    ///   - with: 待替换字符串
    /// - Returns: 新的字符串
    func replace(regex: String, options: NSRegularExpression.Options, with: String) -> String? {
        guard regex.isNotBlank else { return nil }
        guard let pattern = try? NSRegularExpression(pattern: regex, options: options) else { return nil }
        return pattern.stringByReplacingMatches(in: self, options: [], range: rangeOfAll, withTemplate: with)
    }
    
    func append(scale: CGFloat) -> String {
        if fabsf(Float((scale - 1))) <= .ulpOfOne || !isNotBlank || hasSuffix("/") { return self }
        return appendingFormat("@%dx", Int(scale))
    }
}

// MARK: - Path
public extension String {
    /// Documents目录路径
    static var documentsDirectoryPath: String {
        return URL.documentsDirectoryUrl.path
    }
    
    /// Caches目录路径
    static var cachesDirectoryPath: String {
        return URL.cachesDirectoryUrl.path
    }
    
    /// Library目录路径
    static var libraryDirectoryPath: String {
        return URL.libraryDirectoryUrl.path
    }
    
    /// tmp目录路径
    static var tmpDirectoryPath: String {
        return NSTemporaryDirectory()
    }
}

public extension String {
    /// 返回组成字符串的字符数组
    var charactersArray: [Character] {
        return Array(self)
    }
    
    
    /// 去掉字符串首尾的空格换行，中间的空格和换行忽略
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 是否不为空
    ///
    /// "", "  ", "\n", "  \n   "都视为空
    /// 不为空返回true， 为空返回false
    var isNotBlank: Bool {
        return !trimmed.isEmpty
    }
    
    
    /// 字符串的全部范围
    var rangeOfAll: NSRange {
        return NSRange(location: 0, length: count)
    }
    
    /// NSRange转换为当前字符串的Range
    ///
    /// - Parameter range: NSRange对象
    /// - Returns: 当前字符串的范围
    func range(for range: NSRange) -> Range<String.Index>? {
        return Range(range, in: self)
    }
}

// MARK: - 编解码属性
public extension String {
    /// 转换为32位小写的md2散列值
    var md2: String {
        return data(using:.utf8)!.md2String
    }
    
    /// 转换为32位小写的md4散列值
    var md4: String {
        return data(using:.utf8)!.md4String
    }
    
    /// 转换为32位小写的md5散列值
    var md5: String {
        return data(using:.utf8)!.md5String
    }
    
    /// 转换为40位小写的sha1散列值
    var sha1: String {
        return data(using:.utf8)!.sha1String
    }
    
    /// 转换为56位小写的sha224散列值
    var sha224: String {
        return data(using:.utf8)!.sha224String
    }
    
    /// 转换为64位小写的sha256散列值
    var sha256: String {
        return data(using:.utf8)!.sha256String
    }
    
    /// 转换为96位小写的sha256散列值
    var sha384: String {
        return data(using:.utf8)!.sha384String
    }
    
    /// 转换为128位小写的sha256散列值
    var sha512: String {
        return data(using:.utf8)!.sha512String
    }
    
    /// 解码base64
    var base64Decoded: String? {
        // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
        guard let decodedData = Data(base64Encoded: self) else { return nil }
        return String(data: decodedData, encoding: .utf8)
    }
    
    /// 编码base64
    var base64Encoded: String? {
        // https://github.com/Reza-Rg/Base64-Swift-Extension/blob/master/Base64.swift
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
    
    /// Url编码
    var urlEncode: String? {
        
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
         - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
         - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
         - parameter string: The string to be percent-escaped.
         - returns: The percent-escaped string.
         */
        
        let kAFCharactersGeneralDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let kAFCharactersSubDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: kAFCharactersGeneralDelimitersToEncode + kAFCharactersSubDelimitersToEncode)
        let batchSize = 50
        
        var escaped = ""
        var index = 0
        
        while index < count {
            let length = min(count - index, batchSize)
            var range = self.index(startIndex, offsetBy: index)..<self.index(startIndex, offsetBy: length)
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = rangeOfComposedCharacterSequences(for: range)
            let subString = String(self[range])
            if let encoded = subString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
                escaped.append(encoded)
            }
            index += subString.count
        }
        return escaped.isNotBlank ? escaped : nil
    }
    
    
    /// Url解码
    var urlDecode: String? {
        return removingPercentEncoding
    }
    
    
    /// html字符转义
    ///
    /// 例子:
    /// ```
    /// #""&><"#.escapingHtml
    /// //&quot;&amp;&gt;&lt;
    /// ```
    var escapingHtml: String {
        var result = String.UnicodeScalarView()
        unicodeScalars.forEach({
            switch $0 {
            case "\"":
                result.append(contentsOf: "&quot;".unicodeScalars)
            case "&":
                result.append(contentsOf: "&amp;".unicodeScalars)
            case "<":
                result.append(contentsOf: "&lt;".unicodeScalars)
            case ">":
                result.append(contentsOf: "&gt;".unicodeScalars)
            default:
                break
            }
        })
        return String(result)
    }
    
    
    /// 返回CRC32字符串
    var crc32: String {
        return data(using: .utf8)!.crc32String
    }
}


public extension String {
    
    /// 返回 32位小写 HMAC MD5 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacMD5(key: String) -> String {
        return data(using:.utf8)!.hmacMD5String(key: key)
    }
    
    /// 返回 40位小写 HMAC SHA1 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA1(key: String) -> String {
        return data(using:.utf8)!.hmacSHA1String(key: key)
    }
    
    /// 返回 56位小写 HMAC SHA224 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA224(key: String) -> String {
        return data(using:.utf8)!.hmacSHA224String(key: key)
    }
    
    /// 返回 64位小写 HMAC SHA224 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA256(key: String) -> String {
        return data(using:.utf8)!.hmacSHA256String(key: key)
    }
    
    /// 返回 96位小写 HMAC SHA384 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA384(key: String) -> String {
        return data(using:.utf8)!.hmacSHA384String(key: key)
    }
    
    /// 返回 128位小写 HMAC SHA512 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA512(key: String) -> String {
        return data(using:.utf8)!.hmacSHA512String(key: key)
    }
}

// MARK: - base64类方法
public extension String {
    
    /// 类方法编码base64
    ///
    /// - Parameter string: 待编码字符串
    /// - Returns: base64字符串
    static func base64Encoded(_ string: String) -> String? {
        let plainData = string.data(using: .utf8)
        return plainData?.base64EncodedString()
    }
    
    /// 类方法解码base64
    ///
    /// - Parameter string: 待解码字符串
    /// - Returns: 解码后的字符串
    static func base64Decoded(_ string: String) -> String? {
        guard let decodedData = Data(base64Encoded: string) else { return nil }
        return String(data: decodedData, encoding: .utf8)
    }
}


// MARK: - 验证方法
public extension String {
    
    /// 验证字符串是否为Email
    ///
    /// 对于是否选择支持online类邮箱可以考虑修改正则表达式结尾限制为{2,8}
    var isValidEmail: Bool {
        guard isNotBlank, let r = range(of: #"([A-Za-z0-9_\-\.])+@([A-Za-z0-9_\-\.])+.([A-Za-z]{2,4})"#,
                               options: .regularExpression, range: nil, locale: nil),
            startIndex..<endIndex == r else {
                return false
        }
        return true
    }
    
    /// 针对临时邮箱（也称10分钟邮箱或一次性邮箱）的白名单验证方式
    var isValueEmailByWhiteList: Bool {
        if isValidEmail {
            let whiteList: Set = ["qq.com","163.com","vip.163.com","263.net","yeah.net","sohu.com","sina.cn","sina.com","eyou.com","gmail.com","hotmail.com","42du.cn"]
            let startIndex = index(after: firstIndex(of: "@")!)
            let emailTailStr = String(self[startIndex..<endIndex])
            return whiteList.contains(emailTailStr)
        }
        return false
    }
    
    /// 验证字符串是否为Url
    var isValidUrl: Bool {
        return URL(string: self) != nil
    }
    
}



// MARK: - 字符串插值方法
extension String.StringInterpolation {
    /// 提供 `Optional` 字符串插值
    ///
    /// 而不必强制使用 `String(describing:)`
    /// ```
    /// // There's 23 and nil
    /// "There's \(value1, default: "nil") and \(value2, default: "nil")"
    /// ```
    public mutating func appendInterpolation<T>(_ value: T?, default defaultValue: String) {
        if let value = value {
            appendInterpolation(value)
        } else {
            appendLiteral(defaultValue)
        }
    }
    
    public enum OptionalStyle {
        /// 有值和没有值两种情况下都包含单词 `Optional`
        case descriptive
        /// 有值和没有值两种情况下都去除单词 `Optional`
        case stripped
        /// 使用系统的插值方式，在有值时包含单词 `Optional`，没有值时则不包含
        case `default`
    }
    
    /// 使用提供的 `optStyle` 样式来插入可选值
    /// ```
    /// // "There's Optional(23) and nil"
    /// "There's \(value1, optStyle: .default) and \(value2, optStyle: .default)"
    ///
    /// // "There's Optional(23) and Optional(nil)"
    /// "There's \(value1, optStyle: .descriptive) and \(value2, optStyle: .descriptive)"
    /// ```
    public mutating func appendInterpolation<T>(_ value: T?, optStyle style: String.StringInterpolation.OptionalStyle) {
        switch style {
        // 有值和没有值两种情况下都包含单词 `Optional`
        case .descriptive:
            if value == nil {
                appendLiteral("Optional(nil)")
            } else {
                appendLiteral(String(describing: value))
            }
        // 有值和没有值两种情况下都去除单词 `Optional`
        case .stripped:
            if let value = value {
                appendInterpolation(value)
            } else {
                appendLiteral("nil")
            }
        // 使用系统的插值方式，在有值时包含单词 `Optional`，没有值时则不包含
        default:
            appendLiteral(String(describing: value))
        }
    }
    
    /// 使用 `stripped` 样式来对可选值进行插值
    /// 有值和没有值两种情况下都省略单词 `Optional`
    /// ```
    /// // "There's 23 and nil"
    /// "There's \(describing: value1) and \(describing: value2)"
    /// ```
    public mutating func appendInterpolation<T>(describing value: T?) {
        appendInterpolation(value, optStyle: .stripped)
    }
}

// 成功时包含（感谢 Nate Cook）
// MARK: - 条件成立才插值
extension String.StringInterpolation {
    /// 只有 `condition` 的返回值为 `true` 才进行插值
    /// ```
    /// // 旧写法
    /// "Cheese Sandwich \(isStarred ? "(*)" : "")"
    ///
    /// // 新写法
    /// "Cheese Sandwich \(if: isStarred, "(*)")"
    /// ```
    mutating func appendInterpolation(if condition: @autoclosure () -> Bool, _ literal: StringLiteralType) {
        guard condition() else { return }
        appendLiteral(literal)
    }
}

