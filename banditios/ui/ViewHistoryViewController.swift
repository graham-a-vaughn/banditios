//
//  SecondViewController.swift
//  banditios
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class ViewHistoryViewController: UIViewController {
    static let cellHeight: CGFloat = 64.0
    
    private var goTimeGroupsCollectionObs: Observable<[HistorySection]> = Observable.empty()
    private var dataSource: RxTableViewSectionedAnimatedDataSource<HistorySection>?
    
    @IBOutlet var historyTable: UITableView!
    
    var viewModel: HistoryViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func configure() {
        let viewModel = HistoryViewModel()
        historyTable.delegate = self
        
        goTimeGroupsCollectionObs = viewModel.historyChangeObs
        let dataSource = RxTableViewSectionedAnimatedDataSource<HistorySection>(configureCell:
        { [weak self] _, tableView, _, item in
            guard let strongSelf = self else { return UITableViewCell() }
            return strongSelf.buildCell(tableView: tableView, row: item)
        })
        self.dataSource = dataSource
        
        goTimeGroupsCollectionObs
            .bind(to: historyTable.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        self.viewModel = viewModel
    }
    
    private func buildCell(tableView: UITableView, row: HistoryRow) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryTableViewCell
        let viewModel = HistoryCellViewModel(row.value)
        cell.configure(viewModel)
        return cell
    }

}

extension ViewHistoryViewController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return ViewHistoryViewController.cellHeight
    }
    
}
