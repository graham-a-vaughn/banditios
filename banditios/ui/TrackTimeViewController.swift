//
//  FirstViewController.swift
//  banditios
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TrackTimeViewController: UIViewController {
    static let cellHeight: CGFloat = 64.0
    
    @IBOutlet var activeView: ActiveGoTimeView!
    @IBOutlet var goTimesTable: UITableView!
    
    @IBOutlet var buttonView: TimeTrackingButtonView!
    var viewModel = GoTimeViewModel()
    
    private let sectionRelay = BehaviorRelay<[GoTimeSection]?>(value: nil)
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<GoTimeSection>?
    
    private var goTimeGroupCollectionObs: Observable<[GoTimeSection]> = Observable.empty()
    
    private let cxnDisposable = SerialDisposable()
    private let stateDisposable = SerialDisposable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goTimesTable.delegate = self
        disposeBag.insert(cxnDisposable)
        disposeBag.insert(stateDisposable)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //activeView.ready()
    }
    
    private func configure() {
        
        activeView.configure(viewModel.trackingStateObs)
        buttonView.configure(viewModel)
        configureObservables()
    }
    
    func stateChanged(_ new: TrackingStateModel) {
        switch new.state {
        case .tracking:
            guard let goTimeGroup = new.goTimeGroup else { return }
            sectionRelay.accept([GoTimeSection(goTimeGroup: goTimeGroup)])
        case .stopped:
            guard let goTimeGroup = new.goTimeGroup else { return }
            sectionRelay.accept([GoTimeSection(goTimeGroup: goTimeGroup)])
        case .saved:
            viewModel = GoTimeViewModel()
            stateDisposable.disposable = viewModel.trackingStateObs.subscribeNext(weak: self) { strongSelf, state in
                strongSelf.stateChanged(state)
            }
            sectionRelay.accept([GoTimeSection(goTimeGroup: viewModel.goTimeGroup)])
            activeView.observe(viewModel.trackingStateObs)
            buttonView.configure(viewModel)
        default:
            return
        }
    }
    
    
    
    private func configureObservables() {
        
        goTimeGroupCollectionObs = sectionRelay.asObservable().unwrap()
        let dataSource = RxTableViewSectionedAnimatedDataSource<GoTimeSection>(configureCell:
        { [weak self] _, tableView, _, item in
            guard let strongSelf = self else { return UITableViewCell() }
            return strongSelf.buildCell(tableView: tableView, row: item)
        })
        self.dataSource = dataSource
        
        cxnDisposable.disposable = goTimeGroupCollectionObs
            .bind(to: goTimesTable.rx.items(dataSource: dataSource))
        
        
        stateDisposable.disposable = viewModel.trackingStateObs.subscribeNext(weak: self) { strongSelf, state in
            strongSelf.stateChanged(state)
        }
        
    }
    
    private func buildCell(tableView: UITableView, row: GoTimeRow) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goTimeCell") as! GoTimesTableViewCell
        cell.configure(row.value)
        return cell
    }
}

extension TrackTimeViewController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return TrackTimeViewController.cellHeight
    }
    
}

