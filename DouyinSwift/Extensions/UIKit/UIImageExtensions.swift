//
//  UIImageExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

// MARK: - 属性
public extension UIImage {
    
    /// 是否有Alpha通道
    var hasAlphaChannel: Bool {
        guard let cgImage = cgImage else { return false }
        guard let alpha = CGImageAlphaInfo(rawValue: cgImage.alphaInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue) else { return false }
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
    
    /// 返回图片jpeg格式的字节大小
    ///
    /// 如果图片的缓存数据被清空，将会重新加载图片数据到内存
    ///
    var jpegBytesSize: Int {
        return jpegData(compressionQuality: 1)?.count ?? 0
    }
    
    // 返回图片png格式的字节大小
    ///
    /// 如果图片的缓存数据被清空，将会重新加载图片数据到内存
    ///
    var pngBytesSize: Int {
        return pngData()?.count ?? 0
    }
    
    /// 返回图片jepg格式的千字节大小, 保留两位小数
    var jpegKbSize: Double {
        return Double(String(format:"%.2f",Double(jpegBytesSize) / 1024.0))!
    }
    
    /// 返回图片png格式的千字节大小
    var pngKbSize: Double {
        return Double(String(format: "%.2f", Double(pngBytesSize) / 1024.0))!
    }
    
    /// 图片的原始渲染模式
    var original: UIImage {
        return withRenderingMode(.alwaysOriginal)
    }
}


// MARK: - 方法
public extension UIImage {
    
    /// 输入原始图像返回压缩后的图像
    ///
    /// - Parameter quality: 代表jpeg图像的质量，取值范围从 0.0 to 1.0，0.0 表示最高压缩系数 (质量最低) 相反 1.0 表示最低压缩系数 (最高质量), (默认值 0.5).
    /// - Returns: 可选的图像对象
    func compressed(quality: CGFloat = 0.5) -> UIImage? {
        guard let data = compressedData(quality: quality) else { return nil }
        return UIImage(data: data)
    }
    
    /// 输入原始图像数据返回压缩后的图像数据
    ///
    /// - Parameter quality: 代表jpeg图像的质量，取值范围从 0.0 to 1.0，0.0 表示最高压缩系数 (质量最低) 相反 1.0 表示最低压缩系数 (最高质量), (默认值 0.5).
    /// - Returns: 可选的压缩数据
    func compressedData(quality: CGFloat = 0.5) -> Data? {
        return jpegData(compressionQuality: quality)
    }
    
    /// 返回指定尺寸的图像
    ///
    /// 当mode为nil时会使图像变形
    ///
    /// - Parameters:
    ///   - size: 指定图像大小
    ///   - contentMode: 图像显示模式
    ///   - opaque: 是否不透明，默认为false
    /// - Returns: 新尺寸的图像
    func resize(to size: CGSize, contentMode: UIView.ContentMode? = nil, opaque: Bool = false) -> UIImage? {
        guard size.width >= 0 && size.height >= 0 else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        defer { UIGraphicsEndImageContext() }
        if let contentMode = contentMode {
            draw(in: CGRect(origin: CGPoint.zero, size: size), mode: contentMode, clips: false)
        } else {
            draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 绘制指定大小、显示模式的图像到当前上下文
    ///
    /// - Parameters:
    ///   - rect: 绘制区域
    ///   - mode: 图像显示模式
    ///   - clips: 是否剪裁
    func draw(in rect: CGRect, mode: UIView.ContentMode, clips: Bool) {
        let r = rect.rectFit(size: size, mode: mode)
        guard r.size.width >= 0 && r.size.height >= 0 else { return }
        if clips {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.saveGState()
            context.addRect(rect)
            context.clip()
            draw(in: r)
            context.restoreGState()
        } else {
            draw(in: r)
        }
    }
    
    
    /// 挖取指定区域的图像
    ///
    /// - Parameter rect: 区域
    /// - Returns: 指定区域的图像
    func cropping(from rect: CGRect) -> UIImage? {
        var r = rect
        r.origin.x *= scale
        r.origin.y *= scale
        r.size.width *= scale
        r.size.height *= scale
        guard r.size.width > 0 && r.size.height > 0 else { return nil }
        if let cgImage = cgImage?.cropping(to: r) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    
    /// 根据指定路径挖取图像区域
    ///
    /// - Parameter path: 路径
    /// - Returns: 图像
    func cropping(from path: CGPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.addPath(path)
        context.closePath()
        context.clip()
        draw(at: CGPoint.zero)
        return UIGraphicsGetImageFromCurrentImageContext()?.cropping(from: path.boundingBox)
    }
    
    
    /// 返回挖去指定区域后的图片
    ///
    /// - Parameter rect: 区域
    /// - Returns: 图片对象
    func cropping(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        draw(at: CGPoint.zero)
        context.clear(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 返回挖去路径围起来的区域后的图片
    ///
    /// - Parameter path: 路径围起来的区域
    /// - Returns: 图片对象
    func cropping(path: CGPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        draw(at: CGPoint.zero)
        context.addPath(path)
        context.closePath()
        context.setBlendMode(.clear)
        context.fillPath()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 绘制带圆角的图像
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 圆角作用范围
    ///   - size: 图片尺寸
    ///   - mode: 图像模式
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    ///   - borderLineJoin: 边框线连接样式
    /// - Returns: 带圆角的图像
    func roundedCorner(radius: CGFloat, corners: UIRectCorner = [.allCorners], size: CGSize? = nil, mode: UIView.ContentMode? = nil,
                       borderWidth: CGFloat? = nil, borderColor: UIColor? = nil, borderLineJoin: CGLineJoin? = nil) -> UIImage? {
        var s = size ?? self.size
        UIGraphicsBeginImageContextWithOptions(s, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let r = CGRect(origin: CGPoint.zero, size: s)
        
        let minSize = min(s.width, s.height)
        let bW = borderWidth ?? 0
        
        if bW < minSize / 2 {
            let path = UIBezierPath(roundedRect: r.insetBy(dx: bW, dy: bW), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: bW))
            context.addPath(path.cgPath)
            context.saveGState()
            context.clip()
            if let mode = mode {
                draw(in: r, mode: mode, clips: true)
            } else {
                draw(in: r)
            }
            context.restoreGState()
        }
        
        if bW < minSize / 2 && bW > 0 {
            let strokeInsert = (floor(bW * scale) + 0.5) / scale
            let strokeRect = r.insetBy(dx: strokeInsert, dy: strokeInsert)
            let strokeRadius = radius > scale / 2 ? radius - scale / 2 : 0
            let path = UIBezierPath(roundedRect: strokeRect, byRoundingCorners: corners, cornerRadii: CGSize(width: strokeRadius, height: bW))
            path.close()
            
            path.lineWidth = bW
            
            if let borderColor = borderColor {
                borderColor.setStroke()
            } else {
                UIColor.clear.setStroke()
            }
            
            if let borderLineJoin = borderLineJoin {
                path.lineJoinStyle = borderLineJoin
            }
            
            path.stroke()
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    
    /// 返回一个旋转指定弧度的新图像
    ///
    /// - Parameter radians: 旋转弧度
    /// - Returns: 旋转指定弧度的图像
    func rotated(by radians: CGFloat) -> UIImage? {
        let destRect = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(), height: destRect.height.rounded())
        UIGraphicsBeginImageContext(roundedDestRect.size)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        context.rotate(by: radians)
        draw(in: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 将制定颜色通过指定混合模式混合到图像上
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - blendMode: 混合模式
    /// - Returns: 混合颜色后的图像
    func tint(by color: UIColor, blendMode: CGBlendMode) -> UIImage? {
        let drawRect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        color.setFill()
        context.fill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 图像顺时针旋转180度
    ///
    /// - Returns: 顺时针旋转180度的图像
    func rotate180() -> UIImage? {
        guard let cgImg = cgImage else { return nil }
        return UIImage(cgImage: cgImg, scale: scale, orientation: .down)
    }
    
    /// 图像逆时针旋转90度
    ///
    /// - Returns: 逆时针旋转90度的图像
    func rotateLeft90() -> UIImage? {
        guard let cgImg = cgImage else { return nil }
        return UIImage(cgImage: cgImg, scale: scale, orientation: .left)
    }
    
    /// 图像顺时针旋转90度
    ///
    /// - Returns: 顺时针旋转90度的图像
    func rotateRight90() -> UIImage? {
        guard let cgImg = cgImage else { return nil }
        return UIImage(cgImage: cgImg, scale: scale, orientation: .right)
    }
    
    /// 水平翻转图像
    ///
    /// - Returns: 翻转后的图像
    func flipHorizontal() -> UIImage? {
        guard let cgImg = cgImage else { return nil }
        return UIImage(cgImage: cgImg, scale: scale, orientation: .upMirrored)
    }
    
    
    /// 垂直翻转图像
    ///
    /// - Returns: 翻转后的图像
    func flipVertical() -> UIImage? {
        guard let cgImg = cgImage else { return nil }
        return UIImage(cgImage: cgImg, scale: scale, orientation: .downMirrored)
    }
}


// MARK: - 初始化方法
public extension UIImage {
    
    /// 使用颜色创建图像
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: aCgImage)
    }
}
