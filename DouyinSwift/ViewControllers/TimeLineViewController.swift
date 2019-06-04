//
//  TimeLineViewController.swift
//  DouyinSwift
//
//  Created by 赵福成 on 2019/6/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController {
    private let TimeLineCellId: String = "TimeLineCellId"
    
    private var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate var didScroll: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor("171823")
        
        tableView.backgroundColor = UIColor("171823")
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TimeLineCellId)
        tableView.estimatedRowHeight = 95
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.separatorStyle = .none
    }
}

extension TimeLineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

extension TimeLineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: TimeLineCellId, for: indexPath)
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
