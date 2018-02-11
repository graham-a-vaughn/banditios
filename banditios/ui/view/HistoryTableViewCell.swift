//
//  HistoryTableViewCell.swift
//  banditios
//
//  Created by Graham Vaughn on 2/9/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet var createdLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
    private var viewModel: HistoryCellViewModel?
    
    func configure(_ viewModel: HistoryCellViewModel) {
        configureUI(viewModel)
        self.viewModel = viewModel
    }
    
    private func configureUI(_ viewModel: HistoryCellViewModel) {
        let createdDis = viewModel.createdObs.bind(to: createdLabel.rx.text)
        disposeOnReuse(createdDis)
        let detailsDis = viewModel.detailsObs.bind(to: detailsLabel.rx.text)
        disposeOnReuse(detailsDis)
    }
}
