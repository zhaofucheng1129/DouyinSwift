//
//  CollectionViewCellContentView.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/3.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public protocol ContainScrollView: UIViewController {
    
    func scrollView() -> UIScrollView
    
    func scrollViewDidScroll(callBack: @escaping (UIScrollView)->())
}

@objc public protocol CollectionViewCellContentViewDataSource: AnyObject {
    func numberOfViewController() -> Int
    func viewController(itemAt indexPath: IndexPath) -> UIViewController
    func collectionViewScroll(progress: CGFloat, sourceIndex: Int, targetIndex: Int)
}

private let CellId: String = "CollectionViewCellContentViewCellId"
class CollectionViewCellContentView: UIView {

    public weak var delegate: CollectionViewCellContentViewDataSource?
    public weak var hostScrollView: UIScrollView!
    public var startScrollOffsetX: CGFloat = 0
    
    private var collectionView: UICollectionView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchPage(index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: false)
    }
    
    private func setUpUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = bounds.size
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellId)
        collectionView.isPagingEnabled = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension CollectionViewCellContentView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}

extension CollectionViewCellContentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfViewController() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId, for: indexPath)
        guard let viewController = delegate?.viewController(itemAt: indexPath) else { return cell }
        cell.contentView.removeSubviews()
        cell.contentView.addSubview(viewController.view)
        viewController.view.frame = cell.contentView.bounds
        return cell
    }
}

extension CollectionViewCellContentView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.hostScrollView.isScrollEnabled = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.hostScrollView.isScrollEnabled = true
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.hostScrollView.isScrollEnabled = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startScrollOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            self.hostScrollView.isScrollEnabled = false
        }
        
        var progress: CGFloat = 0
        var sourceIndex: Int = 0
        var targetIndex: Int = 0
        
        let currentOffsetX = scrollView.contentOffset.x
        
        if startScrollOffsetX > currentOffsetX {
            // 右
            progress = 1 - (currentOffsetX / width - floor(currentOffsetX / width))
            targetIndex = Int(currentOffsetX / width)
            sourceIndex = targetIndex + 1
            if sourceIndex >= delegate?.numberOfViewController() ?? 1 {
                sourceIndex = (delegate?.numberOfViewController() ?? 1) - 1
            }
            
        } else {
            // 左
            progress = currentOffsetX / width - floor(currentOffsetX / width)
            sourceIndex = Int(currentOffsetX / width)
            targetIndex = sourceIndex + 1
            if targetIndex >= delegate?.numberOfViewController() ?? 1 {
                targetIndex = (delegate?.numberOfViewController() ?? 1) - 1
            }
            if currentOffsetX - startScrollOffsetX == width {
                progress = 1
                targetIndex = sourceIndex
            }
        }
        
        delegate?.collectionViewScroll(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}
