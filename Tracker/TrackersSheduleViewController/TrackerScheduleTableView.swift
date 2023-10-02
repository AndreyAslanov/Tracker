//
//  TrackerScheduleTableView.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol TrackersScheduleTableViewDelegate: AnyObject {
    func switchValueChanged(_ isOn: Bool, at row: Int)
}

final class TrackerScheduleTableView: UITableViewCell {
    
    weak var delegate: TrackersScheduleTableViewDelegate?
    private var row: Int!
    
    private let switchTap: UISwitch = {
        let switchTap = UISwitch()
        switchTap.onTintColor = UIColor(named: "Blue")
        switchTap.addTarget(self, action: #selector(switchTapped), for: .touchUpInside)
        return switchTap
    }()
    
    func configure(at row: Int, isOn: Bool) {
        self.row = row
        switchTap.isOn = isOn
        self.accessoryView = switchTap
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel?.textColor = .black
        backgroundColor = UIColor(named: "Background [day]")
        if row == 6 {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @objc private func switchTapped() {
        delegate?.switchValueChanged(switchTap.isOn, at: row)
    }
}

