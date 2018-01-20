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
    static let chill = GoTimeType(name: "Not Work", primary: false)
    static let work = GoTimeType(name: "Work", primary: true)

    @IBOutlet var goButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var goTimesTable: UITableView!
    
    private let goTimeGroup = GoTimeGroup(goTimes: nil)
    private let typeConfig = GoTimeTypeConfig(FirstViewController.chill)
    private var dataSource: RxTableViewSectionedAnimatedDataSource<GoTimeGroup>?
    
    private var goTimeButtonTappedObs: Observable<Void> = Observable.empty()
    private var goTimeGroupCollectionObs: Observable<[GoTimeGroup]> = Observable.empty()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        configureTypes()
        configureObservables()
    }
    
    private func configureTypes() {
        typeConfig.typeMap[FirstViewController.chill] = FirstViewController.work
        typeConfig.typeMap[FirstViewController.work] = FirstViewController.chill
    }
    
    private func configureObservables() {
        goTimeButtonTappedObs = goButton.rx.tap.asObservable()
        goTimeButtonTappedObs.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.nextGoTime()
        })
            .disposed(by: disposeBag)
        
        goTimeGroupCollectionObs = goTimeGroup.valueChangedObs.map { [$0] }
        let dataSource = RxTableViewSectionedAnimatedDataSource<GoTimeGroup>(configureCell:
        { [weak self] _, tableView, _, item in
            guard let strongSelf = self else { return UITableViewCell() }
            return strongSelf.buildCell(tableView: tableView, row: item)
        })
        self.dataSource = dataSource
        
        goTimeGroupCollectionObs
            .bind(to: goTimesTable.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func buildCell(tableView: UITableView, row: GoTime) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goTimeCell") as! GoTimesTableViewCell
        cell.configure(row)
        return cell
    }
    
    private func nextGoTime() {
        let now = Date.now
        let nextType = typeConfig.nextType(goTimeGroup.current()?.type)
        
        let goTime = GoTime(start: now, type: nextType)
        goTimeGroup.add(goTime)
    }
    
    private func stop() {
        goTimeGroup.stop()
    }
}

