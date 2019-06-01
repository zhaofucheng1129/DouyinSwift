//
//  VideoFeedCellMusicAlbumNameBtn.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/5/30.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VideoFeedCellMusicAlbumNameBtn: UIControl {

    private var textLayer: CATextLayer!
    private var maskLayer: CAGradientLayer!
    private var textWidth: CGFloat = 0
    private var textHeight: CGFloat = 0
    private let kSeparateText: String = "   "
    private let kSeparateTextWidth: CGFloat
    private var textLayerFrame = CGRect.zero
    
    public var text: String = "" {
        didSet {
            calculateFrameAndUpdateUI()
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 15) {
        didSet {
            calculateFrameAndUpdateUI()
        }
    }
    
    public var textColor: UIColor = .white {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    
    private func calculateFrameAndUpdateUI() {
        let size = text.singleLineSize(font: font)
        textWidth = size.width
        textHeight = size.height
        textLayerFrame = CGRect(x: 0, y: 0, width: textWidth * 3 + kSeparateTextWidth * 2, height: textHeight)
        drawText()
    }
    
    required init() {
        kSeparateTextWidth = kSeparateText.width(for: font)
        super.init(frame: CGRect.zero)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        textLayer = CATextLayer()
        textLayer.alignmentMode = .natural
        textLayer.isWrapped = false
        textLayer.truncationMode = .none
        textLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(textLayer)
        
        maskLayer = CAGradientLayer()
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 1, y: 0)
        maskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.locations = [0.0, 0.05, 0.95, 1]
        layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        textLayer.frame = CGRect(x: 0, y: (bounds.height - textLayerFrame.height) / 2, width: textLayerFrame.width, height: textLayerFrame.height)
        maskLayer.frame = bounds
        CATransaction.commit()
    }
    
    private func drawText() {
        textLayer.foregroundColor = textColor.cgColor
        textLayer.font = CGFont(font.fontName as CFString)
        textLayer.fontSize = font.pointSize
        textLayer.string = "\(text)\(kSeparateText)\(text)\(kSeparateText)\(text)"
    }
    
    public func setUpAnimation() {
        if let _ = textLayer.animation(forKey: "scrollAnimation") {
            textLayer.removeAnimation(forKey: "scrollAnimation")
        }
        let scrollAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        scrollAnimation.duration = CFTimeInterval(textWidth / 35.0)
        scrollAnimation.fromValue = 0
        scrollAnimation.toValue = -(textWidth + kSeparateTextWidth)
        scrollAnimation.repeatCount = Float.infinity
        scrollAnimation.isRemovedOnCompletion = false
        scrollAnimation.fillMode = .forwards
        scrollAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        textLayer.add(scrollAnimation, forKey: "scrollAnimation")
    }
    
    public func pauseAnimation() {
        textLayer.pauseAnimation()
    }
    
    public func resumeAnimation() {
        textLayer.resumeAnimation()
    }
}

extension Reactive where Base: VideoFeedCellMusicAlbumNameBtn {
    var text: Binder<String> {
        return Binder(base) { albumName, text in
            albumName.text = text
        }
    }
}
