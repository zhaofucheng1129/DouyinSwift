//
//  Image.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/14.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

protocol AnimationImage {
    var frameCount: Int { get }
    var loopCount: Int { get }
    var bytesPerFrame: Int { get }
    var imageSize: CGSize { get }
    func frame(at index: Int, decodeForDisplay: Bool) -> CGImage?
    func duration(at index: Int) -> TimeInterval
    
}

extension Image: AnimationImage {
    var frameCount: Int {
        return decoder.frameCount
    }
    
    var loopCount: Int {
        return decoder.loopCount
    }
    
    var imageSize: CGSize {
        return CGSize(width: decoder.width, height: decoder.height)
    }
    
    var bytesPerFrame: Int {
        return _bytesPerFrame
    }
    
    func frame(at index: Int, decodeForDisplay: Bool) -> CGImage? {
        if index >= decoder.frameCount { return nil }
        if let imageRef = decoder.frame(at: index, decodeForDisplay: decodeForDisplay) {
            return imageRef
        }
        return nil
    }
    
    func duration(at index: Int) -> TimeInterval {
        let duration = decoder.duration(at: index)
        if duration < 0.011 { return 0.1 }
        return duration
    }
}

public class Image: UIImage {
    private let animatedImageType: ImageFormat = .UnKnown
    private var decoder: Decoder
    private var _bytesPerFrame: Int = 0
    public var memorySize: Int64 {
        return Int64(_bytesPerFrame * decoder.frameCount)
    }
    
    convenience init?(named name: String) {
        guard name.isNotBlank, !name.hasPrefix("/") else { return nil }
        let res = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        /// 后缀名的加载优先级
        let exts = ext.isNotBlank ? [ext] : ["", "png", "jpeg", "jpg", "gif","webp"]
        let scales = Bundle.preferredScales
        var path: String = ""
        var scale: CGFloat = 1
        
        outer: for s in scales {
            scale = s
            let imgName = res.append(scale: scale)
            for ext in exts {
                guard let p = Bundle.main.path(forResource: imgName, ofType: ext) else { continue }
                path = p
                break outer
            }
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        self.init(data:data, scale: scale)
    }

    convenience override init?(data: Data) {
        self.init(data: data, scale: 1)
    }
    
    override init?(data: Data, scale: CGFloat) {
        guard let decoder = Decoder.decode(for: data, scale: scale),
            let image = decoder.frame(at: 0, decodeForDisplay: true) else { return nil }
        self.decoder = decoder
        self._bytesPerFrame = image.bytesPerRow * image.height
        super.init(cgImage: image, scale: scale, orientation: decoder.orientation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIImage Extension
public typealias _ImageLiteralType = UIImage
public extension UIImage {
    private convenience init!(failableImageLiteral name: String) {
        self.init(named: name)
    }
    
    convenience init(imageLiteralResourceName name: String) {
        self.init(failableImageLiteral: name)
    }
}
