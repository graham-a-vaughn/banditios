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

class FirstViewController: UIViewController {
    static let cellHeight: CGFloat = 64.0
    
    @IBOutlet var activeView: ActiveGoTimeView!
    @IBOutlet var goButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var goTimesTable: UITableView!
    
    var viewModel = GoTimeViewModel()
    
    private let goTimeGroup = GoTimeGroup(goTimes: nil)
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<GoTimeSection>?
    
    private var goTimeButtonTappedObs: Observable<Void> = Observable.empty()
    private var stopButtonTappedObs: Observable<Void> = Observable.empty()
    private var goTimeGroupCollectionObs: Observable<[GoTimeSection]> = Observable.empty()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        goTimesTable.delegate = self
        configureObservables()
    }
    
    
    
    private func configureObservables() {
        goTimeButtonTappedObs = goButton.rx.tap.asObservable()
        goTimeButtonTappedObs
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
            
                let go = strongSelf.viewModel.nextGoTime()
                strongSelf.activeView.configure(go)
            })
            .disposed(by: disposeBag)
        
        stopButtonTappedObs = stopButton.rx.tap.asObservable()
        stopButtonTappedObs
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.viewModel.stop()
            })
            .disposed(by: disposeBag)
        
        goTimeGroupCollectionObs = viewModel.goTimeSectionObs
        let dataSource = RxTableViewSectionedAnimatedDataSource<GoTimeSection>(configureCell:
        { [weak self] _, tableView, _, item in
            guard let strongSelf = self else { return UITableViewCell() }
            return strongSelf.buildCell(tableView: tableView, row: item)
        })
        self.dataSource = dataSource
        
        goTimeGroupCollectionObs
            .bind(to: goTimesTable.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func buildCell(tableView: UITableView, row: GoTimeRow) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goTimeCell") as! GoTimesTableViewCell
        cell.configure(row.value)
        return cell
    }
}

extension FirstViewController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return FirstViewController.cellHeight
    }
    
}

