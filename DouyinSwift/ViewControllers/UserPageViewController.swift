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

open class UserPageHostScrollView: UICollectionView {
    
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = otherGestureRecognizer.view else { return false }
        if view is UIScrollView {
            return true
        }
        return false
    }
}

class UserPageViewController: UIViewController {
    private var isHostScrollViewEnable = true
    private var isContainScrollViewEnable = false

    let bag: DisposeBag = DisposeBag()
    var childVCs: [ContainScrollView] = []
    private var collectionView: UserPageHostScrollView!
    private var contentView: CollectionViewCellContentView!
    private var headerView: UserPageHeaderView?
    private var navigationView: UIView!
    private var navigationViewHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.statusBarFrame.height + 54
        } else {
            return 74
        }
    }
    
    private var headerViewHeight: CGFloat {
        return 980.0 / 750.0 * view.width
    }
    
    private var stopScrollOffset: CGFloat {
        return headerViewHeight - navigationViewHeight - segmentViewHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("1D1621")
        
        
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UserPageHostScrollView(frame: CGRect.zero, collectionViewLayout: flowLayout)
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
        collectionView.showsVerticalScrollIndicator = false
        
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
        
        navigationView = UIView()
        navigationView.backgroundColor = UIColor("171823")
        navigationView.isHidden = true
        view.insertSubview(navigationView, belowSubview: returnBtn)
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: navigationViewHeight).isActive = true
        
        let titleLabel = UILabel(text: "我叫Abbily", font: .systemFont(ofSize: 18))
        titleLabel.textColor = UIColor.white
        navigationView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: returnBtn.centerYAnchor).isActive = true
        
        contentView = CollectionViewCellContentView()
        contentView.hostScrollView = collectionView
        
        initSubViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func initSubViewController() {
        let music = MusicListViewController()
        childVCs.append(music)
        
        let postVideoViewModel = VideoListViewModel(style: .post)
        let postVideo = VideoListViewController(viewModel: postVideoViewModel)
        childVCs.append(postVideo)
        
        let timeLineVC = TimeLineViewController()
        childVCs.append(timeLineVC)
        
        let favoriteViewModel = VideoListViewModel(style: .favorite)
        let favoriteVC = VideoListViewController(viewModel: favoriteViewModel)
        childVCs.append(favoriteVC)
        
        childVCs.forEach { (vc) in
            addChild(vc)
            vc.scrollViewDidScroll(callBack: { [weak self] (scrollview) in
                self?.containScrollViewDidScroll(scrollview)
            })
        }
    }
}

extension UserPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: headerViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: view.height - navigationViewHeight - segmentViewHeight - view.safeAreaInsets.bottom)
    }
}

extension UserPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath)
        contentView.delegate = self
        cell.contentView.addSubview(contentView)
        contentView.frame = cell.contentView.bounds
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserPageHeaderView.self.description(), for: indexPath) as? UserPageHeaderView
        headerView?.segmentView.delegate = self
        return headerView!
    }
    
}

extension UserPageViewController: CollectionViewCellContentViewDataSource {
    func collectionViewScroll(progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        headerView?.segmentView.setTitle(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
    
    
    func numberOfViewController() -> Int {
        return childVCs.count
    }
    
    func viewController(itemAt indexPath: IndexPath) -> UIViewController {
        return childVCs[indexPath.item]
    }
}

extension UserPageViewController {
    func containScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        // 向上滑动时
        if offsetY > 0 {
            if isContainScrollViewEnable {
                scrollView.showsVerticalScrollIndicator = true
                
                if collectionView.contentOffset.y == 0 {
                    self.isHostScrollViewEnable = true
                    self.isContainScrollViewEnable = false
                    
                    scrollView.contentOffset = .zero
                    scrollView.showsVerticalScrollIndicator = false
                }else {
                    self.collectionView.contentOffset = CGPoint(x: 0, y: stopScrollOffset)
                }
                
            } else {
                scrollView.contentOffset = CGPoint.zero
                scrollView.showsVerticalScrollIndicator = false
            }
        } else { //向下滑动时
            isContainScrollViewEnable = false
            isHostScrollViewEnable = true
            scrollView.contentOffset = CGPoint.zero
            scrollView.showsVerticalScrollIndicator = false
        }
    }
}

extension UserPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // 判断是否可以继续向上滑动
        if offsetY >= stopScrollOffset {
            scrollView.contentOffset.y = stopScrollOffset
            if isHostScrollViewEnable {
                isHostScrollViewEnable = false
                isContainScrollViewEnable = true
            }
        } else {
            if isContainScrollViewEnable {
                scrollView.contentOffset.y = stopScrollOffset
            }
        }
        // 导航栏相关逻辑
        if scrollView.contentOffset.y < 0 {
            headerView?.backgroundImageAnimation(offset: scrollView.contentOffset.y)
            navigationView.isHidden = true
        } else {
            navigationView.isHidden = false
            navigationView.alpha = scrollView.contentOffset.y / stopScrollOffset
        }
    }
}

extension UserPageViewController: UserPageSegmentViewDelegate {
    func pageSegment(selectedIndex index: Int) {
        contentView.switchPage(index: index)
    }
}
