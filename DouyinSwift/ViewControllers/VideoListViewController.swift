//
//  VideoListViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/4.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit



class VideoListViewController: UIViewController {
    private let LINE_SPACE: CGFloat = 2
    private let ITEM_SPACE: CGFloat = 1
    private var itemWidth: CGFloat {
        return view.width / 3 - ITEM_SPACE * 2
    }
    
    private var itemHeight: CGFloat {
        return itemWidth * (330.0 / 248.0)
    }
    
    private let VideoListCellId = "VideoListCellId"
    private var didScroll:((UIScrollView) -> ())?
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("171823")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LINE_SPACE
        layout.minimumInteritemSpacing = ITEM_SPACE
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor("171823")
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoViewCell.self, forCellWithReuseIdentifier: VideoListCellId)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    
}

extension VideoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: VideoListCellId, for: indexPath)
    }
}

extension VideoListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView)
    }
}

extension VideoListViewController: ContainScrollView {
    func scrollView() -> UIScrollView {
        return collectionView
    }
    
    func scrollViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        didScroll = callBack
    }
}
