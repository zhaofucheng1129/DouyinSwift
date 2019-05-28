//
//  DataExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/7.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import CommonCrypto
import zlib

public extension Data {
    
    /// utf8字符串
    var utf8String: String? {
        guard count > 0 else { return nil }
        return String(data: self, encoding: .utf8)
    }
}

// MARK: - 散列字符串
public extension Data {
    /// 将字节数据转换为为32位小写的md2散列值
    var md2String: String {
        return md2.dataToString()
    }
    
    /// 将字节数据转换为为32位小写的md4散列值
    var md4String: String {
        return md4.dataToString()
    }
    
    /// 将字节数据转换为为32位小写的md5散列值
    var md5String: String {
        return md5.dataToString()
    }
    
    /// 将字节数据转换为40位小写的sha1散列值
    var sha1String: String {
        return sha1.dataToString()
    }
    
    /// 将字节数据转换为56位小写的sha224散列值
    var sha224String: String {
        return sha224.dataToString()
    }
    
    /// 将字节数据转换为64位小写的sha224散列值
    var sha256String: String {
        return sha256.dataToString()
    }
    
    /// 将字节数据转换为96位小写的sha384散列值
    var sha384String: String {
        return sha384.dataToString()
    }
    
    /// 将字节数据转换为128位小写的sha512散列值
    var sha512String: String {
        return sha512.dataToString()
    }
}


// MARK: - 散列字节数据
public extension Data {
    
    /// 取得md2格式的字节数据
    var md2: Data {
        return hashData(.md2)
    }
    // 取得md4格式的字节数据
    var md4: Data {
        return hashData(.md4)
    }
    /// 取得md5格式的字节数据
    var md5: Data {
        return hashData(.md5)
    }
    /// 取得sha1格式的字节数据
    var sha1: Data {
        return hashData(.sha1)
    }
    /// 取得sha224格式的字节数据
    var sha224: Data {
        return hashData(.sha224)
    }
    /// 取得sha256格式的字节数据
    var sha256: Data {
        return hashData(.sha256)
    }
    /// 取得sha384格式的字节数据
    var sha384: Data {
        return hashData(.sha384)
    }
    
    /// 取得sha512格式的字节数据
    var sha512: Data {
        return hashData(.sha512)
    }
    
    fileprivate enum HashType {
        case md2
        case md4
        case md5
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512
    }
    
    fileprivate func allocDigestData(_ type: HashType) -> Data {
        var digestData: Data
        switch type {
        case .md2:
            digestData = Data(count: Int(CC_MD2_DIGEST_LENGTH))
        case .md4:
            digestData = Data(count: Int(CC_MD4_DIGEST_LENGTH))
        case .md5:
            digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        case .sha1:
            digestData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        case .sha224:
            digestData = Data(count: Int(CC_SHA224_DIGEST_LENGTH))
        case .sha256:
            digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        case .sha384:
            digestData = Data(count: Int(CC_SHA384_DIGEST_LENGTH))
        case .sha512:
            digestData = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
        }
        return digestData
    }
    
    private func hashData(_ type: HashType) -> Data {
        var digestData = allocDigestData(type)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UnsafeMutablePointer<UInt8>? in
            _ = self.withUnsafeBytes { messageBytes -> UnsafeBufferPointer<UInt8>? in
                hashMethod(type, data: messageBytes.baseAddress, len: CC_LONG(messageBytes.count),
                           md: digestBytes.baseAddress?.assumingMemoryBound(to: UInt8.self))
                return nil
            }
            return nil
        }
        return digestData
    }
    
    private func hashMethod(_ type: HashType, data: UnsafeRawPointer!, len: CC_LONG, md: UnsafeMutablePointer<UInt8>!) {
        switch type {
        case .md2:
            CC_MD2(data, len, md)
        case .md4:
            CC_MD4(data, len, md)
        case .md5:
            CC_MD5(data, len, md)
        case .sha1:
            CC_SHA1(data, len, md)
        case .sha224:
            CC_SHA224(data, len, md)
        case .sha256:
            CC_SHA256(data, len, md)
        case .sha384:
            CC_SHA384(data, len, md)
        case .sha512:
            CC_SHA512(data, len, md)
        }
    }
}


// MARK: - HMAC相关
///密钥散列消息认证码，又称散列消息认证码，是一种通过特别计算方式之后产生的消息认证码，使用密码散列函数，同时结合一个加密密钥。它可以用来保证数据的完整性，同时可以用来作某个消息的身份验证。
public extension Data {
    
    /// 返回 32位小写 HMAC MD5 签名字符串
    ///
    /// 1.输入任意长度的信息，经过摘要处理，输出为128位的信息。（数字指纹）
    ///
    /// 2.不同输入产生不同的结果，（唯一性）
    ///
    /// 3.根据128位的输出结果不可能反推出输入的信息(不可逆)
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacMD5String(key: String) -> String {
        return hmacMD5Data(key: key).dataToString()
    }
    
    
    /// 返回 40位小写 HMAC SHA1 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA1String(key: String) -> String {
        return hmacSHA1Data(key: key).dataToString()
    }
    
    /// 返回 56位小写 HMAC SHA224 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA224String(key: String) -> String {
        return hmacSHA224Data(key: key).dataToString()
    }
    
    
    /// 返回 64位小写 HMAC SHA256 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA256String(key: String) -> String {
        return hmacSHA256Data(key: key).dataToString()
    }
    
    /// 返回 96位小写 HMAC SHA384 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA384String(key: String) -> String {
        return hmacSHA384Data(key: key).dataToString()
    }
    
    /// 返回 128位小写 HMAC SHA512 签名字符串
    ///
    /// - Parameter key: 密码
    /// - Returns: 签名字符串
    func hmacSHA512String(key: String) -> String {
        return hmacSHA512Data(key: key).dataToString()
    }
    
    /// HMAC MD5 签名算法
    ///
    /// 1.输入任意长度的信息，经过摘要处理，输出为128位的信息。（数字指纹）
    ///
    /// 2.不同输入产生不同的结果，（唯一性）
    ///
    /// 3.根据128位的输出结果不可能反推出输入的信息(不可逆)
    ///
    /// - Parameter key: 密码
    /// - Returns: 加密数据
    func hmacMD5Data(key: String) -> Data {
        return hmacData(.md5, key: key)
    }
    
    /// HMAC SHA1 签名算法
    func hmacSHA1Data(key: String) -> Data {
        return hmacData(.sha1, key: key)
    }
    
    /// HMAC SHA224 签名算法
    func hmacSHA224Data(key: String) -> Data {
        return hmacData(.sha224, key: key)
    }
    
    /// HMAC SHA256 签名算法
    func hmacSHA256Data(key: String) -> Data {
        return hmacData(.sha256, key: key)
    }
    
    /// HMAC SHA384 签名算法
    func hmacSHA384Data(key: String) -> Data {
        return hmacData(.sha384, key: key)
    }
    
    /// HMAC SHA512 签名算法
    func hmacSHA512Data(key: String) -> Data {
        return hmacData(.sha512, key: key)
    }
    
    private func hmacData(_ type: HashType, key: String) -> Data {
        var digestData = allocDigestData(type)
        let cKey = key.cString(using: .utf8)!
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UnsafeMutablePointer<UInt8>? in
            _ = self.withUnsafeBytes { messageBytes -> UnsafeBufferPointer<UInt8>? in
                CCHmac(hmacAlgorithm(type), cKey, cKey.count, messageBytes.baseAddress, messageBytes.count, digestBytes.baseAddress)
                return nil
            }
            return nil
        }
        return digestData
    }
    
    private func hmacAlgorithm(_ type: HashType) -> CCHmacAlgorithm {
        switch type {
        case .md5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .sha224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .sha256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        default:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        }
    }
    
    
    /// 转换为字符串
    ///
    /// - Returns: 字符串
    func dataToString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}


// MARK: - 循环冗余校验
public extension Data {
    
    /// 返回循CRC32字符串
    var crc32String: String {
        var result: uLong = 0
        _ = withUnsafeBytes { bytes -> UnsafeBufferPointer<Bytef>? in
            let b = UnsafeBufferPointer(start: bytes.baseAddress?.assumingMemoryBound(to: Bytef.self), count: bytes.count)
            result = crc32(0, b.baseAddress, uInt(bytes.count))
            return nil
        }
        return String(format: "%08x", result)
    }
}


public extension Data {
    
    /// 解析Json数据
    ///
    /// - Returns: 返回解析后的对象
    func jsonValueDecoded() -> Any? {
        do {
            let result = try JSONSerialization.jsonObject(with: self, options: [])
            return result
        } catch {
            print("jsonValueDecoded error:\(error)")
        }
        return nil
    }
    
}
