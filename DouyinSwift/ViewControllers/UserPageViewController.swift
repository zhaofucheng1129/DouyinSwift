//
//  UserPageViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/1.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserPageViewController: UIViewController {

    let bag: DisposeBag = DisposeBag()
    var childVCs: [UIViewController] = []
    private var collectionView: UICollectionView!
    private var headerView: UserPageHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("1D1621")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.register(UserPageHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserPageHeaderView.self.description())
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        
        let returnBtn = UIButton(type: .system)
        returnBtn.setImage(UIImage(named: "return_icon40x40")?.withRenderingMode(.alwaysOriginal), for: .normal)
        view.addSubview(returnBtn)
        returnBtn.translatesAutoresizingMaskIntoConstraints = false
        returnBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        returnBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        returnBtn.rx.tap.subscribe(onNext: { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        (0..<4).forEach { _ in
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor(red: Int(arc4random_uniform(255)), green: Int(arc4random_uniform(255)), blue: Int(arc4random_uniform(255)))
            addChild(vc)
            childVCs.append(vc)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension UserPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 975.0 / 750.0 * view.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.size
    }
}

extension UserPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath)
        let contentView = CollectionViewCellContentView()
        contentView.delegate = self
        cell.contentView.addSubview(contentView)
        contentView.frame = cell.contentView.bounds
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserPageHeaderView.self.description(), for: indexPath) as! UserPageHeaderView
        return headerView!
    }
    
}

extension UserPageViewController: CollectionViewCellContentViewDataSource {
    func numberOfViewController() -> Int {
        return childVCs.count
    }
    
    func viewController(itemAt indexPath: IndexPath) -> UIViewController {
        return childVCs[indexPath.row]
    }
}

extension UserPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            print(scrollView.contentOffset.y)
            print(headerView?.segmentView.frame)
//            if scrollView.contentOffset.y view.safeAreaInsets.top
        }
    }
}
