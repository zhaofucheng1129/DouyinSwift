//
//  Decoder.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/15.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import Accelerate

class Decoder {
    
    public private(set) var data: Data?
    public private(set) var type: ImageFormat = .UnKnown
    public private(set) var scale: CGFloat = 1
    public private(set) var frameCount = 0
    public private(set) var loopCount = 0
    public private(set) var width = 0
    public private(set) var height = 0
    public private(set) var orientation: UIImage.Orientation = .up
    @objc(isFinalized)
    public private(set) var finalized = false
    
    private let lock = Lock.recursive
    private var source: CGImageSource?
    private var webpSource: OpaquePointer?
    private var frames = [ImageDecoderFrame]()
    private let framesLock = DispatchSemaphore(value: 1)
    private var sourceTypeDetected = false
    private var needBlend = false
    private var blendFrameIndex: Int?
    private var blendCanvas: CGContext?
    
    static func decode(for data: Data, scale: CGFloat) -> Decoder? {
        let decoder = Decoder(scale: scale)
        decoder.update(data: data, final: true)
        if decoder.frameCount == 0 { return nil }
        return decoder
    }
    
    init(scale: CGFloat) {
        self.scale = scale
    }
    
    @discardableResult
    func update(data: Data, final: Bool) -> Bool {
        var result = false
        pthread_mutex_lock(lock)
        result = _update(data: data, final: final)
        pthread_mutex_unlock(lock)
        return result
    }
    
    func frame(at index: Int, decodeForDisplay: Bool) -> CGImage? {
        var result: CGImage? = nil
        pthread_mutex_lock(lock)
        result = _frame(at: index, decodeForDisplay: decodeForDisplay)
        pthread_mutex_unlock(lock)
        return result
    }
    
    func duration(at index: Int) -> TimeInterval {
        var result: TimeInterval = 0
        framesLock.wait()
        if let frame = frames[safe: index] { result = frame.duration }
        framesLock.signal()
        return result
    }
    
    private func _update(data: Data, final: Bool) -> Bool {
        if finalized { return false }
        if data.count < self.data?.count ?? 0 { return false }
        finalized = final
        self.data = data
        let type = data.load.imageFormat
        if sourceTypeDetected {
            if self.type != type {
                return false
            } else {
                _updateSource()
            }
        } else {
            if self.data?.count ?? 0 > 16 {
                self.type = type
                sourceTypeDetected = true
                _updateSource()
            } else {
                return false
            }
        }
        return true
    }
    
    private func _updateSource() {
        switch type {
        case .WEBP:
            _updateSourceWebP()
        default:
            _updateSourceImageIO()
        }
    }
    
    private func _updateSourceWebP() {
        guard let data = data else { return }
        
        self.width = 0
        self.height = 0
        self.loopCount = 0
        if let webpSource = self.webpSource { WebPDemuxDelete(webpSource) }
        self.webpSource = nil
        
        frames = []
        
        let webpData = UnsafeMutablePointer<WebPData>.allocate(capacity: 1)
        WebPDataInit(webpData)
        webpData.pointee.bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        webpData.pointee.size = data.count
        guard let demuxer = WebPDemux(webpData) else { return }
        let webpFrameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT)
        let webpLoopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT)
        let canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH)
        let canvalHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT)
        guard webpFrameCount != 0 && canvasWidth > 0 && canvalHeight > 0 else {
            WebPDemuxDelete(demuxer)
            return
        }
        
        var frames = [ImageDecoderFrame]()
        var needBlend = false
        var iterIndex = 0
        var lastBlendIndex = 0
        let iter = UnsafeMutablePointer<WebPIterator>.allocate(capacity: 1)
        if WebPDemuxGetFrame(demuxer, 1, iter) != 0 {
            repeat {
                var frame = ImageDecoderFrame()
                if iter.pointee.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND {
                    frame.dispose = .background
                }
                if iter.pointee.blend_method == WEBP_MUX_BLEND {
                    frame.blend = .over
                }
                
                let canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH)
                let canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT)
                frame.index = iterIndex
                frame.duration = Double(iter.pointee.duration) / 1000.0
                frame.width = Int(iter.pointee.width)
                frame.height = Int(iter.pointee.height)
                frame.hasAlpha = iter.pointee.has_alpha != 0
                frame.blend = iter.pointee.blend_method == WEBP_MUX_BLEND ? ImageBlendMode.over : ImageBlendMode.none
                frame.offsetX = Int(iter.pointee.x_offset)
                frame.offsetY = Int(canvasHeight) - Int(iter.pointee.y_offset) - Int(iter.pointee.height)
                
                let sizeEqualsToCanvas = (iter.pointee.width == canvasWidth) && (iter.pointee.height == canvalHeight)
                let offsetIsZero = (iter.pointee.x_offset == 0) && iter.pointee.y_offset == 0
                frame.isFullSize = sizeEqualsToCanvas && offsetIsZero
                
                if (frame.blend == .none || !frame.hasAlpha) && frame.isFullSize {
                    lastBlendIndex = iterIndex
                    frame.blendFromIndex = lastBlendIndex
                } else {
                    if frame.dispose != .none && frame.isFullSize {
                        frame.blendFromIndex = lastBlendIndex
                        lastBlendIndex = iterIndex + 1
                    } else {
                        frame.blendFromIndex = lastBlendIndex
                    }
                }
                
                if frame.index != frame.blendFromIndex { needBlend = true }
                iterIndex += 1
                frames.append(frame)
            } while (WebPDemuxNextFrame(iter) != 0)
            WebPDemuxReleaseIterator(iter)
        }
        
        if frames.count != webpFrameCount {
            WebPDemuxDelete(demuxer)
            return
        }
        
        self.width = Int(canvasWidth)
        self.height = Int(canvalHeight)
        self.frameCount = frames.count
        self.loopCount = Int(webpLoopCount)
        self.needBlend = needBlend
        self.webpSource = demuxer
        self.frames = frames
    }
    
    private func _updateSourceImageIO() {
        guard let data = data else { return }
        self.width = 0
        self.height = 0
        self.orientation = UIImage.Orientation.up
        self.loopCount = 0
        frames = []
        
        if source == nil {
            if finalized {
                source = CGImageSourceCreateWithData(data as CFData, nil)
            } else {
                source = CGImageSourceCreateIncremental(nil)
                if let source = source { CGImageSourceUpdateData(source, data as CFData, false) }
            }
        } else {
            CGImageSourceUpdateData(source!, data as CFData, finalized)
        }
        
        guard let source = source else { return }
        frameCount = CGImageSourceGetCount(source)
        
        guard frameCount != 0 else { return }
        
        if !finalized {
            frameCount = 1
        } else {
            if type == .PNG, frameCount > 1 {
                if let pngProperties = CGImageSourceCopyProperties(source, nil) as? [String: Any],
                    let pngInfo = pngProperties[kCGImagePropertyPNGDictionary as String] as? [String: Any],
                    let loopCount = pngInfo[kCGImagePropertyAPNGLoopCount as String] as? Int {
                    self.loopCount = loopCount
                }
            } else if type == .GIF {
                if let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any]
                    ,let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                    let loopCount = gifInfo[kCGImagePropertyGIFLoopCount as String] as? Int {
                    self.loopCount = loopCount
                }
            }
        }
        
        var frames = [ImageDecoderFrame]()
        (0..<frameCount).forEach { (index) in
            var frame = ImageDecoderFrame()
            frame.index = index
            frame.blendFromIndex = index
            
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any] {
                
                if let widthNum = properties[kCGImagePropertyPixelWidth as String] as? Int { frame.width = widthNum }
                if let heightNum = properties[kCGImagePropertyPixelHeight as String] as? Int { frame.height = heightNum }
                if type == .GIF {
                    if let gitInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                        if let unclampedTime = gitInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval {
                            frame.duration = unclampedTime
                        } else if let delayTime = gitInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                            frame.duration = delayTime
                        }
                    }
                } else if type == .PNG {
                    if let pngInfo = properties[kCGImagePropertyPNGDictionary as String] as? [String: Any] {
                        if let unclampedTime = pngInfo[kCGImagePropertyAPNGUnclampedDelayTime as String] as? TimeInterval {
                            frame.duration = unclampedTime
                        } else if let delayTime = pngInfo[kCGImagePropertyAPNGDelayTime as String] as? TimeInterval {
                            frame.duration = delayTime
                        }
                    }
                }
                
                if index == 0 && self.width + self.height == 0 {
                    self.width = frame.width
                    self.height = frame.height
                    if let orientation = properties[kCGImagePropertyOrientation as String] as? UIImage.Orientation {
                        self.orientation = orientation
                    }
                }
            }
            frames.append(frame)
        }
        self.frames = frames
    }
    
    private func _frame(at index: Int, decodeForDisplay: Bool) -> CGImage? {
        if index >= frames.count { return nil }
        var decoded = false
        let extendToCanvas = decodeForDisplay        
        if !needBlend {
            guard var imageRef = _newUnblendedImage(at: index, extendToCanvas: extendToCanvas, decoded: &decoded) else { return nil}
            if decodeForDisplay && !decoded {
                if let imageRefDecoded = _ImageCreateDecodedCopy(imageRef: imageRef, decodeForDisplay: true) {
                    imageRef = imageRefDecoded
                    decoded = true
                }
            }
            return imageRef
        }
        
        let frame = frames[index]
        var imageRef: CGImage?
        guard _createBlendContextIfNeeded() else { return nil }
        if let blendFrameIndex = blendFrameIndex, blendFrameIndex + 1 == frame.index {
            imageRef = _newBlendImage(with: frame)
            self.blendFrameIndex = index
        } else {
            blendFrameIndex = nil
            blendCanvas?.clear(CGRect(x: 0, y: 0, width: width, height: height))
            
            if frame.blendFromIndex == frame.index {
                if let unblendedImage = _newUnblendedImage(at: index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.draw(unblendedImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
                if frame.dispose == .background {
                    blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                blendFrameIndex = index
            } else {
                (frame.blendFromIndex ... frame.index).forEach { (i) in
                    if i == frame.index {
                        if imageRef == nil {
                            imageRef = _newBlendImage(with: frame)
                        }
                    } else {
                        _blendImage(with: frames[i])
                    }
                }
                blendFrameIndex = index
            }
        }
        return imageRef
    }
    
    private func _newUnblendedImage(at index: Int, extendToCanvas: Bool, decoded: UnsafeMutablePointer<Bool>?) -> CGImage? {
        if !finalized && index > 0 { return nil }
        if frames.count <= index { return nil }
        
        if let source = source {
            guard var imageRef = CGImageSourceCreateImageAtIndex(source, index, [kCGImageSourceShouldCache: true] as CFDictionary) else { return nil }
            if extendToCanvas {
                let width = imageRef.width
                let height = imageRef.height
                if width == self.width && height == self.height {
                    if let imageRefExtended = _ImageCreateDecodedCopy(imageRef: imageRef, decodeForDisplay: true) {
                        imageRef = imageRefExtended
                        if let decoded = decoded {
                            decoded.pointee = true
                        }
                    }
                } else {
                    if let context = CGContext(data: nil, width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) {
                        context.draw(imageRef, in: CGRect(x: 0, y: self.height - height, width: width, height: height))
                        if let imageRefExtended = context.makeImage() {
                            imageRef = imageRefExtended
                            if let decoded = decoded {
                                decoded.pointee = true
                            }
                        }
                    }
                }
            }
            return imageRef
        }
        
        if let webpSource = webpSource {
            let iter = UnsafeMutablePointer<WebPIterator>.allocate(capacity: 1)
            //WebP帧索引从1开始
            guard WebPDemuxGetFrame(webpSource, Int32(index + 1), iter) != 0 else  { return nil }
            
            let frameWidth = Int(iter.pointee.width)
            let frameHeight = Int(iter.pointee.height)
            guard frameWidth >= 1 && frameHeight >= 1 else { return nil }
            
            let width = extendToCanvas ? self.width : frameWidth
            let height = extendToCanvas ? self.height : frameHeight
            guard width <= self.width && height <= self.height else { return nil }
            
            let payload = iter.pointee.fragment.bytes
            let payloadSize = iter.pointee.fragment.size
            
            let config = UnsafeMutablePointer<WebPDecoderConfig>.allocate(capacity: 1)
            guard WebPInitDecoderConfig(config) != 0 else {
                WebPDemuxReleaseIterator(iter)
                return nil
            }
            
            guard WebPGetFeatures(payload, payloadSize, &config.pointee.input) == VP8_STATUS_OK else {
                WebPDemuxReleaseIterator(iter)
                return nil
            }
            
            let bitsPerComponent = 8
            let bitsPerPixel = 32
            //字节对齐
            // 块的大小跟CPU 的缓存有关，ARMv7是32byte，A9是64byte，在A9下CoreAnimation应该是按64byte作为一块数据去读取和渲染，让图像数据对齐64byte就可以避免CoreAnimation再拷贝一份数据。能节约内存和进行copy的时间。
            let bytesPerRow = ((bitsPerPixel / 8 * width + (64 - 1)) / 64) * 64;
            let length = bytesPerRow * height
            //iphone是小端模式
            let bitmapInfo = CGBitmapInfo.byteOrder32Little
            let alphaInfo = CGImageAlphaInfo.premultipliedFirst
            
            let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            pixels.initialize(repeating: 1, count: length)
            
            config.pointee.output.colorspace = MODE_bgrA
            config.pointee.output.is_external_memory = 1
            config.pointee.output.u.RGBA.rgba = pixels
            config.pointee.output.u.RGBA.stride = Int32(bytesPerRow)
            config.pointee.output.u.RGBA.size = length
            let result = WebPDecode(payload, payloadSize, config)
            guard result == VP8_STATUS_OK || result == VP8_STATUS_NOT_ENOUGH_DATA else {
                WebPDemuxReleaseIterator(iter)
                pixels.deinitialize(count: length)
                pixels.deallocate()
                return nil
            }
            WebPDemuxReleaseIterator(iter)
            
            if extendToCanvas && (iter.pointee.x_offset != 0 || iter.pointee.y_offset != 0) {
                let tmp = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 1)
                var src = vImage_Buffer(data: pixels, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
                var dest = vImage_Buffer(data: tmp, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
                var transform = vImage_CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: Double(iter.pointee.x_offset), ty: Double(-iter.pointee.y_offset))
                var backColor: [UInt8] = [0, 0, 0, 0]
                let error = vImageAffineWarpCG_ARGB8888(&src, &dest, nil, &transform, &backColor, vImage_Flags(kvImageBackgroundColorFill))
                if error == kvImageNoError {
                    memcpy(pixels, tmp, length)
                }
                tmp.deallocate()
            }
            
            guard let provider = CGDataProvider(dataInfo: pixels, data: pixels, size: length, releaseData: { info, _, _ in if let info = info { info.deallocate() } }) else {
                pixels.deinitialize(count: length)
                pixels.deallocate()
                return nil
            }
            
            let image = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel,
                                bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo.rawValue | alphaInfo.rawValue),
                                provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
            if let decoded = decoded {
                decoded.pointee = true
            }
            return image
        }
        
        return nil
    }
    
    func _createBlendContextIfNeeded() -> Bool {
        if blendCanvas == nil {
            blendFrameIndex = nil
            blendCanvas = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
        return blendCanvas != nil
    }
    
    func _blendImage(with frame: ImageDecoderFrame) {
        if frame.dispose == .previous {
        } else if frame.dispose == .background {
            blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
        } else {
            if frame.blend == .over {
                guard let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) else { return }
                blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
            } else {
                blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                guard let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) else { return }
                blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
            }
        }
    }
    
    func _newBlendImage(with frame: ImageDecoderFrame) -> CGImage? {
        var imageRef: CGImage?
        
        if frame.dispose == .previous {
            if frame.blend == .over {
                let previousImage = blendCanvas?.makeImage()
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
                blendCanvas?.clear(CGRect(x: 0, y: 0, width: width, height: height))
                if let p = previousImage {
                    blendCanvas?.draw(p, in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            } else {
                let previousImage = blendCanvas?.makeImage()
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
                blendCanvas?.clear(CGRect(x: 0, y: 0, width: width, height: height))
                if let p = previousImage {
                    blendCanvas?.draw(p, in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            }
        } else if frame.dispose == .background {
            if frame.blend == .over {
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
                blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
            } else {
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
                blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
            }
        } else {
            if frame.blend == .over {
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
            } else {
                if let unblendImage = _newUnblendedImage(at: frame.index, extendToCanvas: false, decoded: nil) {
                    blendCanvas?.clear(CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                    blendCanvas?.draw(unblendImage, in: CGRect(x: frame.offsetX, y: frame.offsetY, width: frame.width, height: frame.height))
                }
                imageRef = blendCanvas?.makeImage()
            }
        }
        return imageRef
    }
    
    
    private func _ImageCreateDecodedCopy(imageRef: CGImage, decodeForDisplay: Bool) -> CGImage? {        
        let width = imageRef.width
        let height = imageRef.height
        guard width != 0 && height != 0 else { return nil }
        if decodeForDisplay {
            var hasAlpha = false
            if let alphaInfo = CGImageAlphaInfo(rawValue: imageRef.alphaInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue) {
                if alphaInfo == .premultipliedLast || alphaInfo == .premultipliedFirst || alphaInfo == .last || alphaInfo == .first {
                    hasAlpha = true
                }
            }
            let bitmapInfo = CGBitmapInfo.byteOrder32Little
            let mask = hasAlpha ? CGImageAlphaInfo.premultipliedFirst : CGImageAlphaInfo.noneSkipFirst
            guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue | mask.rawValue) else { return nil }
            context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
            return context.makeImage()
        } else {
            let colorSpace = imageRef.colorSpace
            let bitsPerComponent = imageRef.bitsPerComponent
            let bitsPerPixel = imageRef.bitsPerPixel
            let bytesPerRow = imageRef.bytesPerRow
            let bitmapInfo = imageRef.bitmapInfo
            guard let space = colorSpace, bytesPerRow != 0 && width != 0 && height != 0 else { return nil }
            guard let dataProvider = imageRef.dataProvider, let data = dataProvider.data else { return nil }
            guard let newProvider = CGDataProvider(data: data) else { return nil }
            return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo, provider: newProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        }
    }
}
