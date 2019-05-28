//
//  MemoryCache.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/24.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

///enum简单的单向链表
//indirect enum LinkedList<Element: Comparable> {
//    case Empty
//    case Node(Element, LinkedList<Element>)
//}
//let linkedList = LinkedList.Node(1, .Node(2, .Node(3, .Node(4, .Empty))))

//func linkedListByRemovingElement(element: Element)
//    -> LinkedList<Element> {
//        guard case let .Node(value, next) = self else {
//            return .Empty
//        }
//        return value == element ?
//            next : LinkedList.Node(value, next.linkedListByRemovingElement(element))
//}
//
//let result = linkedList.linkedListByRemovingElement(2)
//print(result)
// 1 -> 3 -> 4

struct ImageNode: Equatable {
    var key: NSString
    var image: Image
    
    static func == (lhs: ImageNode, rhs: ImageNode) -> Bool {
        return lhs.key == rhs.key && lhs.image == rhs.image
    }
}

class CacheNode: NSObject {
    var imageNode: ListNode?
    var isInLRUQueue:Bool = false
}

protocol ListNodeProtocol: AnyObject {
    associatedtype Value
    var val: Value { get set }
    var next: Self? { get set }
}

final class ListNode:ListNodeProtocol, Equatable {
    typealias Value = ImageNode
    
    var val: Value
    var next: ListNode?
    var prev: ListNode?
    
    required init(_ val: Value) {
        self.val = val
    }
    
    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.val == rhs.val
    }
}

class MemoryList<Element> where Element: ListNode {
    var head: ListNode?
    var tail: ListNode?
    
    var size: UInt = 0
    
    // 尾插法
    func appendToTail(_ val: ListNode.Value) -> ListNode {
        let node = ListNode(val)
        if tail == nil {
            tail = node
            head = tail
        } else {
            node.prev = tail
            tail!.next = node
            tail = tail!.next
        }
        size += 1
        return node
    }
    
    // 头插法
    func appendToHead(_ val: ListNode.Value) -> ListNode {
        let node = ListNode(val)
        if head == nil {
            head = node
            tail = head
        } else {
            node.next = head
            head?.prev = node
            head = node
        }
        size += 1
        return node
    }
    
    func remove(node: ListNode) {
        size -= 1
        if let next = node.next {
            next.prev = node.prev
        }
        if let prev = node.prev {
            prev.next = node.next
        }
        if let head = head, head == node { self.head = node.next }
        if let tail = tail, tail == node { self.tail = node.prev }
    }
    
    func popHeadNode() -> ListNode? {
        guard let head = head else { return nil }
        size -= 1
        if head == tail {
            self.head = nil
            self.tail = nil
        } else {
            self.head = head.next
            self.head?.prev = nil
        }
        return head
    }
    
    // 清空链表
    func clear() {
        while tail != nil {
            let node = tail!.prev
            node?.next = nil
            tail = node
        }
    }
}

public class MemoryCache: NSObject {
    private var imageMap: NSMapTable<NSString, CacheNode>
    private var fifoQueue: MemoryList<ListNode>
    private var LRUQueue: MemoryList<ListNode>
    
    public static let `default` = MemoryCache()
    
    public var cacheSizeLimit = 8 * 1024 * 1024 * 100
    public var maxLengthForLRU = 400
    public var maxLengthForFIFO = 400
    
    public private(set) var cacheSize: Int64 = 0
    
    override init() {
        fifoQueue = MemoryList()
        LRUQueue = MemoryList()
        imageMap = NSMapTable(keyOptions: .strongMemory, valueOptions: .strongMemory, capacity: 0)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveLowMemoryNotification), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    func contain(for key: String) -> Bool {
        let key = key as NSString
        visit(key: key)
        guard let _ = imageMap.object(forKey: key) else { return false }
        return true
    }
    
    func image(with url: String) -> Image? {
        guard url.isNotBlank else { return nil }
        let key = url as NSString
        visit(key: key)
        guard let cacheNode = imageMap.object(forKey: key) else { return nil }
        return cacheNode.imageNode?.val.image
    }
    
    func cache(image: Image, url: String) {
        guard url.isNotBlank else { return }
        cacheSize += image.memorySize
        let key = url as NSString
        if let cacheNode = imageMap.object(forKey: key) {
            if let imageNode = cacheNode.imageNode {
                imageNode.val.image = image
            }
            visit(key: key)
        } else {
            let imageNode = ImageNode(key: key, image: image)
            let cacheNode = CacheNode()
            cacheNode.imageNode = fifoQueue.appendToTail(imageNode)
            imageMap.setObject(cacheNode, forKey: imageNode.key)
            if fifoQueue.size > self.maxLengthForFIFO {
                let node = fifoQueue.popHeadNode()
                imageMap.removeObject(forKey: node?.val.key)
            }
        }
        limitCacheSize()
    }
    
    func visit(key: NSString) {
        guard let cacheNode = imageMap.object(forKey: key) else { return }
        if cacheNode.isInLRUQueue {
            LRUQueue.remove(node: cacheNode.imageNode!)
            cacheNode.imageNode = LRUQueue.appendToTail(cacheNode.imageNode!.val)
        } else {
            cacheNode.isInLRUQueue = true
            fifoQueue.remove(node: cacheNode.imageNode!)
            cacheNode.imageNode = LRUQueue.appendToTail(cacheNode.imageNode!.val)
        }
        
        if LRUQueue.size > self.maxLengthForLRU {
            clearLastOneInLRU()
        }
    }

    
    func limitCacheSize() {
        while cacheSize > cacheSizeLimit {
            clearLastOne()
        }
    }
    
    func clearLastOne() {
        if LRUQueue.size > 0 {
            clearLastOneInLRU()
        } else {
            clearLastOneInFIFO()
        }
    }
    
    func clearLastOneInLRU() {
        if LRUQueue.size > 0 {
            let node = LRUQueue.popHeadNode()
            cacheSize -= node?.val.image.memorySize ?? 0
            imageMap.removeObject(forKey: node?.val.key)
        }
    }
    
    func clearLastOneInFIFO() {
        if fifoQueue.size > 0 {
            let node = fifoQueue.popHeadNode()
            cacheSize -= node?.val.image.memorySize ?? 0
            imageMap.removeObject(forKey: node?.val.key)
        }
    }
    
    func clear() {
        imageMap.removeAllObjects()
        fifoQueue.clear()
        LRUQueue.clear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didReceiveLowMemoryNotification() {
        clear()
    }
}
