//
//  TimeLineViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeLineViewController: UIViewController {
    private let TimeLineCellId: String = "TimeLineCellId"
    
    private var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate var didScroll: ((UIScrollView) -> ())?
    private var bag: DisposeBag = DisposeBag()
    
    private let viewModel = TimeLineListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "关注"
        
        tableView.backgroundColor = UIColor("171823")
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimeLineViewCell.self, forCellReuseIdentifier: TimeLineCellId)
        tableView.estimatedRowHeight = 95
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.separatorStyle = .none
        
        viewModel.requestData()
        viewModel.dataSourceDriver.drive(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        }).disposed(by: bag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ZPlayerManager.shared.pause(owner: self)
    }
}

extension TimeLineViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 700
    }
}

extension TimeLineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeLineCellId, for: indexPath) as! TimeLineViewCell
        let cellViewModel = viewModel.dataSource[indexPath.row]
        cell.bind(viewModel: cellViewModel)
        return cell
    }
}

extension TimeLineViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView)
    }
}

extension TimeLineViewController: ContainScrollView {
    func scrollView() -> UIScrollView {
        return tableView
    }
    
    func scrollViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        didScroll = callBack
    }
}
