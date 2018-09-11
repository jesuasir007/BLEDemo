//
//  ServicesViewController.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 27/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import UIKit

class ServicesViewController: UITableViewController {
    
    // MARK: - Properties

    private let device: Device

    // MARK: - Init

    public init(device: Device) {
        self.device = device
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("[ServicesViewController] is deinitializeed")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Public methods

    /// Updating all content
    public func updateContent() {
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ServicesViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characteristic = self.device.services[indexPath.section].characteristic[indexPath.row]
        if characteristic.uuid == MiCharacteristicID.alert {
            self.device.vibrate(level: AlertMode.mild)
        }
    }
}

// MARK: - UITableViewDelegate

extension ServicesViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.device.services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.device.services[section].characteristic.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.device.services[section].uuid.serviceName()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) else {
                return UITableViewCell(style: .value1, reuseIdentifier: Constants.cellIdentifier)
            }
            return cell
        }()

        cell.textLabel?.text = self.device.services[indexPath.section].characteristic[indexPath.row].uuid.characteristicName()
        return cell
    }
}
