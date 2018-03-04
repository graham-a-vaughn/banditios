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
    private let trackingStateReplay = ReplaySubject<TrackingStateModel>.createUnbounded()
    private let viewModelReplay = ReplaySubject<GoTimeViewModel>.createUnbounded()
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<GoTimeSection>?
    
    private var sectionObs: Observable<[GoTimeSection]> = Observable.empty()
    private var trackingStateObs: Observable<TrackingStateModel> = Observable.empty()
    private var viewModelObs: Observable<GoTimeViewModel> = Observable.empty()
    
    private let stateDisposable = SerialDisposable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goTimesTable.delegate = self
        disposeBag.insert(stateDisposable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    var stateObs: Observable<TrackingStateModel> {
        return trackingStateReplay.asObservable()
    }
    
    private func configure() {
        activeView.observeTrackingState(stateObs)
        buttonView.observeViewModel(viewModel)
        initializeDataSource()
        observeTrackingState()
    }
    
    private func initializeDataSource() {
        sectionObs = sectionRelay.asObservable().unwrap()
        let dataSource = RxTableViewSectionedAnimatedDataSource<GoTimeSection>(configureCell:
        { [weak self] _, tableView, _, item in
            guard let strongSelf = self else { return UITableViewCell() }
            return strongSelf.buildCell(tableView: tableView, row: item)
        })
        self.dataSource = dataSource
        
        sectionObs.bind(to: goTimesTable.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
    }
    
    private func buildCell(tableView: UITableView, row: GoTimeRow) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goTimeCell") as! GoTimesTableViewCell
        cell.configure(row.value)
        return cell
    }
    
    private func observeTrackingState() {
        stateDisposable.disposable = viewModel.trackingStateObs.subscribeNext(weak: self) { strongSelf, state in
            strongSelf.stateChanged(state)
        }
    }
    
    func stateChanged(_ new: TrackingStateModel) {
        switch new.state {
        case .tracking:
            guard let goTimeGroup = new.goTimeGroup else { return }
            sectionRelay.accept([GoTimeSection(goTimeGroup: goTimeGroup)])
            trackingStateReplay.onNext(new)
        case .stopped:
            guard let goTimeGroup = new.goTimeGroup else { return }
            sectionRelay.accept([GoTimeSection(goTimeGroup: goTimeGroup)])
            trackingStateReplay.onNext(new)
        case .saved:
            viewModel = GoTimeViewModel()
            observeTrackingState()
            sectionRelay.accept([GoTimeSection(goTimeGroup: viewModel.goTimeGroup)])
            buttonView.observeViewModel(viewModel)
        default:
            trackingStateReplay.onNext(new)
        }
        
    }
}

extension TrackTimeViewController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return TrackTimeViewController.cellHeight
    }
    
}

