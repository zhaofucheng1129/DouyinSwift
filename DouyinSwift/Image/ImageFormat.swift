//
//  ImageFormat.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/15.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public enum ImageFormat {
    case PNG
    case JPEG
    case GIF
    case WEBP
    case UnKnown
    
    struct HeaderData {
        static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A] //0x89PNG\r\n0x1A\n
        static var JPEG_SOI: [UInt8] = [0xFF, 0xD8] //
        static var JPEG_IF: [UInt8] = [0xFF] //
        static var GIF: [UInt8] = [0x47, 0x49, 0x46] //GIF
        static var WEBP_H: [UInt8] = [0x52, 0x49,0x46,0x46] //RIFF
        static var WEBP_8: [UInt8] = [0x57, 0x45, 0x42, 0x50] // WEBP
    }
}

extension Data: WrapperValue { }

extension Wrapper where Base == Data {
    
    public var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (base as NSData).getBytes(&buffer, length: 8)
        if buffer == ImageFormat.HeaderData.PNG {
            return .PNG
        } else if buffer[0] == ImageFormat.HeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageFormat.HeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageFormat.HeaderData.JPEG_IF[0] {
            return .JPEG
        } else if buffer[0] == ImageFormat.HeaderData.GIF[0] &&
            buffer[1] == ImageFormat.HeaderData.GIF[1] &&
            buffer[2] == ImageFormat.HeaderData.GIF[2] {
            return .GIF
        } else if buffer[0] == ImageFormat.HeaderData.WEBP_H[0] &&
            buffer[1] == ImageFormat.HeaderData.WEBP_H[1] &&
            buffer[2] == ImageFormat.HeaderData.WEBP_H[2] &&
            buffer[3] == ImageFormat.HeaderData.WEBP_H[3] {
            (base as NSData).getBytes(&buffer, range: NSRange(location: 8, length: 4))
            if buffer[0] == ImageFormat.HeaderData.WEBP_8[0] &&
                buffer[1] == ImageFormat.HeaderData.WEBP_8[1] &&
                buffer[2] == ImageFormat.HeaderData.WEBP_8[2] &&
                buffer[3] == ImageFormat.HeaderData.WEBP_8[3] {
                return .WEBP
            }
        }
        return .UnKnown
    }
}
