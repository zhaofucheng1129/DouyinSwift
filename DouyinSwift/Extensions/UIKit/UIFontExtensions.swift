//
//  UIFontExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/10.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension UIFont {
    
    /// 是否为粗体
    var isBold: Bool {
        return fontDescriptor.symbolicTraits == .traitBold
    }
    
    /// 是否为斜体
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits == .traitItalic
    }
    
    /// 是否为等宽字体
    var isMonoSpace: Bool {
        return fontDescriptor.symbolicTraits == .traitMonoSpace
    }
    
    /// 是否为图形字体
    var isColorGlyphs: Bool {
        return CTFontGetSymbolicTraits(self) == .traitColorGlyphs
    }
    
    /// 字体权重
    var fontWeight: UIFont.Weight {
        if let traits = fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any],let weight = traits[.weight] as? CGFloat {
            return UIFont.Weight(weight)
        }
        return UIFont.Weight(0)
    }
    
    /// 返回当前字体的粗体版本
    var bold: UIFont {
        guard let boldDesc = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: boldDesc, size: pointSize)
    }
    
    /// 返回当前字体的斜体版本
    var italic: UIFont {
        guard let italicDesc = fontDescriptor.withSymbolicTraits(.traitItalic) else { return self }
        return UIFont(descriptor: italicDesc, size: pointSize)
    }
    
    /// 返回当前字体的既粗体又斜体的版本
    var boldItalic: UIFont {
        guard let boldItalizDesc = fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) else { return self }
        return UIFont(descriptor: boldItalizDesc, size: pointSize)
    }
    
    /// 返回当前字体的普通版本
    var normal: UIFont {
        guard let normalDesc = fontDescriptor.withSymbolicTraits(.init()) else { return self }
        return UIFont(descriptor: normalDesc, size: pointSize)
    }
    
    var CGFontRef: CGFont? {
        return CGFont(fontName as CFString)
    }
    
    var CTFontRef: CTFont {
        return CTFontCreateWithName(fontName as CFString, pointSize, nil)
    }
}

public extension UIFont {
    
    
    /// 加载自定义字体
    @discardableResult
    static func loadFont(path: String) -> Bool {
        guard let url = URL(string: path) else { return false }
        return loadFont(url: url)
    }
    
    /// 加载自定义字体
    @discardableResult
    static func loadFont(url: URL) -> Bool {
        var error:Unmanaged<CFError>? = nil
        defer { error?.release() }
        let ret = CTFontManagerRegisterFontsForURL(url as CFURL, .none, &error)
        if !ret {
            print("Load font error: \(error, optStyle: .stripped)")
        }
        return ret
    }
    
    /// 卸载自定义字体
    @discardableResult
    static func unloadFont(url: URL) -> Bool {
        return CTFontManagerUnregisterFontsForURL(url as CFURL, .none, nil)
    }
    
    /// 加载自定义字体数据
    @discardableResult
    static func loadFont(data: Data) -> Bool {
        guard let provider = CGDataProvider(data: data as CFData), let cgFont = CGFont(provider) else { return false }
        var error:Unmanaged<CFError>? = nil
        defer { error?.release() }
        guard CTFontManagerRegisterGraphicsFont(cgFont, &error) else {
            print("Load font error: \(error, optStyle: .stripped)")
            return false
        }
        return true
    }
    
    /// 加载自定义字体数据
    ///
    /// - Parameter data: 字体数据
    /// - Returns: 系统字号的字体对象
    static func loadFont(data: Data) -> UIFont? {
        guard let provider = CGDataProvider(data: data as CFData), let cgFont = CGFont(provider) else { return nil }
        var error:Unmanaged<CFError>? = nil
        defer { error?.release() }
        guard CTFontManagerRegisterGraphicsFont(cgFont, &error) else {
            print("Load font error: \(error, optStyle: .stripped)")
            return nil
        }
        guard let fontName = cgFont.postScriptName else { return nil }
        return UIFont(name: fontName as String, size: systemFontSize)
    }
    
    
    /// 卸载自定义字体
    static func unloadFont(font: UIFont) -> Bool {
        guard let cgFont = CGFont(font.fontName as CFString) else { return false }
        var error:Unmanaged<CFError>? = nil
        defer { error?.release() }
        guard CTFontManagerUnregisterGraphicsFont(cgFont, &error) else {
            print("Load font error: \(error, optStyle: .stripped)")
            return false
        }
        return true
    }
    
    private struct FontHeader {
        var fVersion: Int32
        var fNumTables: UInt16
        var fSearchRange: UInt16
        var fEntrySelector: UInt16
        var fRangeShift: UInt16
    }
    
    private struct TableEntry {
        var fTag: UInt32
        var fCheckSum: UInt32
        var fOffset: UInt32
        var fLength: UInt32
    }
    
    private static func calcTableCheckSum(table: UnsafePointer<TableEntry>, numberOfBytesInTable: UInt32) -> UInt32 {
        var sum: UInt32 = 0
        var nLongs = (numberOfBytesInTable + 3) / 4
        while nLongs > 0 {
            sum += CFSwapInt32HostToBig(table.pointee.fCheckSum)
            nLongs -= 1
        }
        return sum
    }
    
    // FIXME: - 参考YYCategories但是测试发现swift下UIFont的tableTags方法返回的总是空指针
    /// 将制定字体对象转换为二进制数据
    static func data(font: UIFont) -> Data? {
        guard let cgFont = font.CGFontRef else { return nil }
        guard let tags = cgFont.tableTags else { return nil }
        let tableCount = CFArrayGetCount(tags)
        var tableSizes: [size_t] = Array(repeating: 0, count: tableCount)
        var containsCFFTable = false
        var totalSize: size_t = MemoryLayout<FontHeader>.size + MemoryLayout<TableEntry>.size * tableCount
        (0..<tableCount).forEach { (index) in
            var tableSize: size_t = 0
            if let aTag = CFArrayGetValueAtIndex(tags, index)?.bindMemory(to: UInt32.self, capacity: 1),
                aTag.pointee == kCTFontTableCFF, !containsCFFTable {
                containsCFFTable = true

                if let cfTableData = cgFont.table(for: aTag.pointee) {
                    tableSize = CFDataGetLength(cfTableData)
                }
            }
            totalSize += (totalSize + 3) & ~3
            tableSizes[index] = tableSize
        }

        var stream: [UInt8] = Array(repeating: 0, count: totalSize)
        let dataStart = UnsafeMutablePointer<UInt8>(&stream)
        var dataPtr = UnsafeMutablePointer<UInt8>(dataStart)

        var entrySelector: UInt16 = 0
        var searchRange: UInt16 = 1
        while searchRange < tableCount >> 1 {
            entrySelector += 1
            searchRange <<= 1
        }
        searchRange <<= 4
        let rangeShift = (UInt16(tableCount) << 4) - searchRange
        var offsetTable: FontHeader = dataPtr.withMemoryRebound(to: FontHeader.self, capacity: 1) { $0.pointee }
        var cStr = "OTTO".cString(using: .utf8)!
        let otto = UnsafeMutablePointer<CChar>(&cStr).withMemoryRebound(to: Int32.self, capacity: 1) { $0.pointee }
        offsetTable.fVersion = containsCFFTable ? otto : Int32(1)
        offsetTable.fNumTables = UInt16(tableCount)
        offsetTable.fSearchRange = searchRange
        offsetTable.fEntrySelector = entrySelector
        offsetTable.fRangeShift = rangeShift

        dataPtr += MemoryLayout<FontHeader>.size

        var entryPtr = dataPtr.withMemoryRebound(to: TableEntry.self, capacity: 1) { $0 }
        dataPtr += MemoryLayout<TableEntry>.size * tableCount

        (0..<tableCount).forEach { (index) in
            if let aTag: UInt32 = CFArrayGetValueAtIndex(tags, index)?.assumingMemoryBound(to: UInt32.self).pointee,let tableData = cgFont.table(for: aTag) {
                let tableSize = CFDataGetLength(tableData)
                dataPtr.initialize(from: CFDataGetBytePtr(tableData), count: tableSize)
                var entry = entryPtr.pointee
                entry.fTag = aTag
                let table = dataPtr.withMemoryRebound(to: TableEntry.self, capacity: 1) { $0 }
                entry.fCheckSum = calcTableCheckSum(table: table, numberOfBytesInTable: UInt32(tableSize))
                let offset = dataPtr - dataStart
                entry.fOffset = UInt32(offset)
                entry.fLength = UInt32(tableSize)

                dataPtr += (tableSize + 3) & -3
                entryPtr += 1
            }
        }
        return Data(bytes: dataStart, count: totalSize)
    }
}
