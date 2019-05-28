//
//  ImageView.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/14.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

open class ImageView: UIImageView {
    /// 帧缓存模式
    public var frameCacheMode:FrameCacheMode = .cpuPreferred {
        didSet {
            if oldValue != frameCacheMode, let animator = animator {
                animator.updateFrameCacheMode(mode: frameCacheMode)
            }
        }
    }
    /// 是否自动播放
    public var autoPlayAnimatedImage = true
    /// 只加载最近10帧 节省内存
    public var framePreloadCount = 10
    /// 是否允许自动缩放图像尺寸
    public var needsPrescaling = true
    /// 循环播放次数
    public var repeatCount = 0 {
        didSet {
            if oldValue != repeatCount {
                reset()
                setNeedsDisplay()
                layer.setNeedsDisplay()
            }
        }
    }
    
    public var runloopMode = RunLoop.Mode.common {
        willSet {
            guard newValue == runloopMode else { return }
            stopAnimating()
            displayLink.remove(from: .main, forMode: runloopMode)
            displayLink.add(to: .main, forMode: newValue)
            startAnimating()
        }
    }

    private let lock = DispatchSemaphore(value: 1)
    
    private var isDisplayLinkInitFlag: Bool = false
    private lazy var displayLink: CADisplayLink = {
        isDisplayLinkInitFlag = true
        let link = CADisplayLink(target: TargetProxy(target: self), selector: #selector(TargetProxy.onScreenUpdate))
        link.add(to: .main, forMode: runloopMode)
        link.isPaused = true
        return link
    }()
    
    private var animator: Animator?
    
    override init(frame: CGRect) {
        runloopMode = RunLoop.Mode.common
        super.init(frame: frame)
    }
    
    override init(image: UIImage?) {
        runloopMode = RunLoop.Mode.common
        super.init(image: image)
        self.frame = CGRect(origin: CGPoint.zero, size: image?.size ?? CGSize.zero)
        self.image = image
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        runloopMode = RunLoop.Mode.common
        super.init(image: image, highlightedImage: highlightedImage)
        var size = CGSize.zero
        if let image = image {
            size = image.size
        } else if let highImage = highlightedImage {
            size = highImage.size
        }
        self.frame = CGRect(origin: CGPoint.zero, size: size)
        self.image = image
        self.highlightedImage = highlightedImage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if isDisplayLinkInitFlag {
            displayLink.invalidate()
        }
    }
}


// MARK: - Override
extension ImageView {
    open override var contentMode: UIView.ContentMode {
        didSet {
            if let animator = animator {
                animator.updateContentMode(mode: contentMode)
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if let animator = animator {
                animator.updateSize(size: frame.size)
            }
        }
    }
    
    override open var image: UIImage? {
        didSet {
            if image != oldValue {
                reset()
            }
            setNeedsDisplay()
            layer.setNeedsDisplay()
        }
    }
    
    override open var isAnimating: Bool {
        if isDisplayLinkInitFlag {
            return !displayLink.isPaused
        } else {
            return super.isAnimating
        }
    }
    
    override open func startAnimating() {
        guard !isAnimating else { return }
        if animator?.isRepeatFinished ?? false {
            return
        }
        
        displayLink.isPaused = false
    }
    
    override open func stopAnimating() {
        super.stopAnimating()
        if isDisplayLinkInitFlag {
            displayLink.isPaused = true
        }
    }
    
    override open func display(_ layer: CALayer) {
        if let currentFrame = animator?.currentFrameImage {
            layer.contents = currentFrame
        } else {
            layer.contents = image?.cgImage
        }
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        didMove()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        didMove()
    }
}


extension ImageView {
    private func reset() {
        animator = nil
        if let animImage = image as? Image {
            let size = CGSize(width: width * UIScreen.main.scale, height: height * UIScreen.main.scale)
            if let animator = Animator(image: animImage, size: size, frameCacheMode: frameCacheMode, contentMode: contentMode, framePreloadCount: framePreloadCount, repeatCount: repeatCount) {
                animator.needsPrescaling = needsPrescaling
                animator.prepareFramesAsync()
                self.animator = animator
            }
        }
        didMove()
    }
    
    private func didMove() {
        if autoPlayAnimatedImage && animator != nil {
            if let _ = superview, let _ = window {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    
    private func updateFrameIfNeeded() {
        guard let animator = animator else { return }
        guard !animator.isFinished else {
            stopAnimating()
            return
        }
        
        let duration: CFTimeInterval
        
        if #available(iOS 10.0, *) {
            // https://github.com/onevcat/Kingfisher/issues/718
            // By setting CADisableMinimumFrameDuration to YES in Info.plist may
            // cause the preferredFramesPerSecond being 0
            if displayLink.preferredFramesPerSecond == 0 {
                duration = displayLink.duration
            } else {
                // Some devices (like iPad Pro 10.5) will have a different FPS.
                duration = 1.0 / Double(displayLink.preferredFramesPerSecond)
            }
        } else {
            duration = displayLink.duration
        }
        
        animator.shouldChangeFrame(with: duration) { [weak self] (hasNewFrame) in
            if hasNewFrame {
                self?.layer.setNeedsDisplay()
            }
        }
    }
}


extension ImageView {
    class TargetProxy {
        private weak var target: ImageView?
        
        init(target: ImageView) {
            self.target = target
        }
        
        @objc func onScreenUpdate() {
            target?.updateFrameIfNeeded()
        }
    }
    
    /// 处理帧缓存的模式
    ///
    /// - memoryPreferred: 内存优先模式 总是维护framePreloadCount指定数量的帧图像在队列中 其余的清除
    /// - cpuPreferred: CPU优先模式 增量缓存所有帧图像
    public enum FrameCacheMode {
        case memoryPreferred
        case cpuPreferred
    }
}

extension ImageView {
    class Animator {
        private let animationImage: AnimationImage
        private var size: CGSize // 尺寸
        private var contentMode: ContentMode // 显示模式
        private let framePreloadCount: Int // 控制缓存帧数量
        private let repeatCount: Int // 控制循环次数
        private var frameCacheMode: FrameCacheMode // 缓存模式
        
        private let maxTimeStep: TimeInterval = 1.0 //每帧间隔最长时间
        private var frames = [AnimationFrame]() // 缓存的帧序列
        private var frameCount = 0 // 总帧数
        private var timeSinceLastFrameChange: TimeInterval = 0 // 控制帧切换
        private var currentRepeatCount = 0 //当前循环次数
        
        /// 是否播放完成
        var isFinished: Bool = false
        // 控制缓存帧数量
        var needsPrescaling = true
        
        /// 当前帧序号
        var currentFrameIndex = 0 {
            didSet {
                previousFrameIndex = oldValue
            }
        }
        
        /// 上一帧的序号
        var previousFrameIndex = 0 {
            didSet {
                if self.frameCacheMode == .memoryPreferred {
                    preloadQueue.async { [weak self] in
                        self?.updatePreloadedFrames()
                    }
                }
            }
        }
        
        /// 取得当前帧的图片对象
        var currentFrameImage: CGImage? {
            return frame(at: currentFrameIndex)
        }
        
        /// 取得当前帧显示时间
        var currentFrameDuration: TimeInterval {
            return duration(at: currentFrameIndex)
        }
        
        var isRepeatFinished: Bool {
            if repeatCount == 0 {
                return false
            } else {
                return currentRepeatCount >= repeatCount
            }
        }
        
        var isLastFrame: Bool {
            return currentFrameIndex == frameCount - 1
        }
        
        /// 是否需要更新缓存帧序列
        var preloadingIsNeeded: Bool {
            return framePreloadCount < frameCount - 1 && self.frameCacheMode == .memoryPreferred
        }
        
        init?(image: AnimationImage,
             size: CGSize,
             frameCacheMode: FrameCacheMode,
             contentMode: ContentMode,
             framePreloadCount: Int,
             repeatCount: Int) {
            if image.frameCount <= 1 { return nil }
            self.animationImage = image
            self.size = size
            self.frameCacheMode = frameCacheMode
            self.contentMode = contentMode
            self.framePreloadCount = framePreloadCount
            self.repeatCount = repeatCount
        }
        
        /// 异步串行队列 用于更新缓存帧序列
        private lazy var preloadQueue: DispatchQueue = {
            return DispatchQueue(label: "com.zhaofucheng.GreatApp.Animator.preloadQueue")
        }()
        
        func updateSize(size: CGSize) {
            self.size = size
        }
        
        func updateContentMode(mode: ContentMode) {
            self.contentMode = mode
        }
        
        func updateFrameCacheMode(mode: FrameCacheMode) {
            self.frameCacheMode = mode
        }
        
        func frame(at index: Int) -> CGImage? {
            return frames[safe: index]?.image
        }
        
        func duration(at index: Int) -> TimeInterval {
            return frames[safe: index]?.duration ?? .infinity
        }
        
        func prepareFramesAsync() {
            frameCount = animationImage.frameCount
            frames.reserveCapacity(frameCount) // 指定需要的空间
            preloadQueue.async { [weak self] in
                self?.setupAnimatedFrames()
            }
        }
        
        private func setupAnimatedFrames() {
            resetAnimatedFrames()
            (0..<frameCount).forEach { (index) in
                let frameDuration = animationImage.duration(at: index)
                frames.append(AnimationFrame(image: nil, duration: frameDuration))
                
                if self.frameCacheMode == .memoryPreferred, index > framePreloadCount { return }
                frames[index] = frames[index].makeAnimationFrame(image: loadFrame(at: index))
            }
        }
        
        private func loadFrame(at index: Int) -> CGImage? {
            let imageSize = animationImage.imageSize
            if needsPrescaling, size != .zero, imageSize.width > size.width || imageSize.height > size.height {
                guard let imageRef = animationImage.frame(at: index, decodeForDisplay: false) else { return nil }
                return UIImage(cgImage: imageRef).resize(to: size, contentMode: contentMode, opaque: false)?.cgImage
            } else {
                return animationImage.frame(at: index, decodeForDisplay: true)
            }
        }
        
        private func resetAnimatedFrames() {
            frames = []
        }
        
        private func updatePreloadedFrames() {
            guard preloadingIsNeeded else { return }
            frames[previousFrameIndex] = frames[previousFrameIndex].placeholderFrame //将上一帧清空
            
            preloadIndexes(start: currentFrameIndex).forEach { (index) in
                let currentFrame = frames[index]
                if !currentFrame.isPlaceholder { return }
                frames[index] = currentFrame.makeAnimationFrame(image: loadFrame(at: index))
            }
        }
        
        private func increment(frameIndex: Int, by value: Int = 1) -> Int {
            return (frameIndex + value) % frameCount //防止越界
        }
        
        //取得要更新的下标数组
        private func preloadIndexes(start index: Int) -> [Int] {
            let nextIndex = increment(frameIndex: index)
            let lastIndex = increment(frameIndex: index, by: framePreloadCount)
            
            if lastIndex >= nextIndex {
                return [Int](nextIndex...lastIndex)
            } else {
                return [Int](nextIndex..<frameCount) + [Int](0...lastIndex)
            }
        }
        
        func shouldChangeFrame(with duration: CFTimeInterval, handler: (Bool) -> Void) {
            incrementTimeSinceLastFrameChange(with: duration)
            
            if currentFrameDuration > timeSinceLastFrameChange {
                handler(false)
            } else {
                resetTimeSinceLastFrameChange()
                incrementCurrentFrameIndex()
                handler(true)
            }
        }
        
        private func incrementCurrentFrameIndex() {
            currentFrameIndex = increment(frameIndex: currentFrameIndex)
            if isRepeatFinished && isLastFrame {
                isFinished = true
            } else if currentFrameIndex == 0 {
                currentRepeatCount += 1
            }
        }
        
        private func incrementTimeSinceLastFrameChange(with duration: TimeInterval) {
            timeSinceLastFrameChange += min(maxTimeStep, duration)
        }
        
        private func resetTimeSinceLastFrameChange() {
            timeSinceLastFrameChange -= currentFrameDuration
        }
    }
}

