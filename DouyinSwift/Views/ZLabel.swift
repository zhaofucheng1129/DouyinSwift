//
//  ZLabel.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

@objc protocol ZLabelDelegate: AnyObject {
    @objc optional func labelDidSelectedLinkText(label: ZLabel, text: String)
}

class ZLabel: UILabel {
    private lazy var textStorage: NSTextStorage = NSTextStorage()
    private lazy var layout: NSLayoutManager = NSLayoutManager()
    private lazy var container: NSTextContainer = NSTextContainer()
    private lazy var linkRanges = [NSRange]()
    private var selectedRange: NSRange?
    public weak var delegate: ZLabelDelegate?
    public var isAllSelected: Bool = false
    
    public var linkTextColor: UIColor = UIColor.white {
        didSet {
            updateTextStorage()
        }
    }
    public var linkTextFont: UIFont = .boldSystemFont(ofSize: 14) {
        didSet {
            updateTextStorage()
        }
    }
    
    public var linkTextSelectedColor: UIColor = UIColor(white: 1, alpha: 0.7)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareLabel()
    }
    
    func prepareLabel() {
        textStorage.addLayoutManager(layout)
        layout.addTextContainer(container)
        isUserInteractionEnabled = true
    }
    
    private func updateTextStorage() {
        var attrString = NSAttributedString(string: "")
        if let attrText = attributedText {
            attrString = attrText
        } else if let text = text {
            attrString = NSAttributedString(string: text)
        }
        
        let mutableStr = addLineBreak(attrString)
        regexLinkRanges(mutableStr)
        addLinkAttribute(mutableStr)

        textStorage.setAttributedString(mutableStr)
        
        setNeedsDisplay()
    }
    
    /// add line break mode
    private func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let attrStringM = NSMutableAttributedString(attributedString: attrString)
        
        if attrStringM.length == 0 {
            return attrStringM
        }
        
        var range = NSRange(location: 0, length: 0)
        var attributes = attrStringM.attributes(at: 0, effectiveRange: &range)
        var paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSMutableParagraphStyle
        
        if paragraphStyle != nil {
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
        } else {
            // iOS 8.0 can not get the paragraphStyle directly
            paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle!.lineBreakMode = NSLineBreakMode.byWordWrapping
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            
            attrStringM.setAttributes(attributes, range: range)
        }
        
        return attrStringM
    }
    
    private let patterns = ["#([^\\s|\\/|:]+)", "@([^\\s|\\/|:|@]+)"]
    private func regexLinkRanges(_ attrString: NSMutableAttributedString) {
        if isAllSelected {
            return
        }
        linkRanges.removeAll()
        let regexRange = NSRange(location: 0, length: (attrString.string as NSString).length)
        
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let results = regex.matches(in: attrString.string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: regexRange)
            
            for r in results {
                linkRanges.append(r.range(at: 0))
            }
        }
    }
    
    private func addLinkAttribute(_ attrString: NSMutableAttributedString) {
        if attrString.length == 0 {
            return
        }
        
        var range = NSRange(location: 0, length: 0)
        var attributes = attrString.attributes(at: 0, effectiveRange: &range)
        
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.foregroundColor] = textColor
        attrString.addAttributes(attributes, range: range)
        
        attributes[NSAttributedString.Key.font] = linkTextFont
        attributes[NSAttributedString.Key.foregroundColor] = linkTextColor
        
        for r in linkRanges {
            attrString.setAttributes(attributes, range: r)
        }
    }
    
    public override func drawText(in rect: CGRect) {
        let range = glyphsRange()
        let offset = glyphsOffset(range)

        layout.drawBackground(forGlyphRange: range, at: offset)
        layout.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)
    }
    
    private func glyphsRange() -> NSRange {
        return NSRange(location: 0, length: textStorage.length)
    }
    
    private func glyphsOffset(_ range: NSRange) -> CGPoint {
        let rect = layout.boundingRect(forGlyphRange: range, in: container)
        let height = (bounds.height - rect.height) * 0.5
        
        return CGPoint(x: 0, y: height)
    }
    
}


// MARK: - 触碰相关
extension ZLabel {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        selectedRange = linkRangeAtLocation(location)
        modifySelectedAttribute(true)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        if let range = linkRangeAtLocation(location) {
            if !(range.location == selectedRange?.location && range.length == selectedRange?.length) {
                modifySelectedAttribute(false)
                selectedRange = range
                modifySelectedAttribute(true)
            }
        } else {
            modifySelectedAttribute(false)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedRange != nil {
            let text = (textStorage.string as NSString).substring(with: selectedRange!)
            delegate?.labelDidSelectedLinkText?(label: self, text: text)
            
            let when = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.modifySelectedAttribute(false)
            }
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        modifySelectedAttribute(false)
    }
    
    private func modifySelectedAttribute(_ isSet: Bool) {
        if selectedRange == nil {
            return
        }
        
        var attributes = textStorage.attributes(at: 0, effectiveRange: nil)
        attributes[NSAttributedString.Key.foregroundColor] = linkTextColor
        attributes[NSAttributedString.Key.font] = linkTextFont
        
        let range = selectedRange!
        
        if isSet {
            attributes[NSAttributedString.Key.foregroundColor] = linkTextSelectedColor
        } else {
            attributes[NSAttributedString.Key.foregroundColor] = linkTextColor
            selectedRange = nil
        }
        
        textStorage.addAttributes(attributes, range: range)
        
        setNeedsDisplay()
    }
    
    private func linkRangeAtLocation(_ location: CGPoint) -> NSRange? {
        if textStorage.length == 0 {
            return nil
        }
        
        if isAllSelected {
            return NSRange(location: 0, length: (textStorage.string as NSString).length)
        }
        
        let offset = glyphsOffset(glyphsRange())
        let point = CGPoint(x: offset.x + location.x, y: offset.y + location.y)
        let index = layout.glyphIndex(for: point, in: container)
        
        for r in linkRanges {
            if index >= r.location && index <= r.location + r.length {
                return r
            }
        }
        
        return nil
    }
}

// MARK: - 重写方法
extension ZLabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.size = bounds.size
    }
    
    override var text: String? {
        didSet {
            let mutableStr = addLineBreak(NSAttributedString(string: text ?? ""))
            regexLinkRanges(mutableStr)
            addLinkAttribute(mutableStr)
            attributedText = mutableStr
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            updateTextStorage()
        }
    }
    
    override var font: UIFont! {
        didSet {
            updateTextStorage()
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            updateTextStorage()
        }
    }
}
