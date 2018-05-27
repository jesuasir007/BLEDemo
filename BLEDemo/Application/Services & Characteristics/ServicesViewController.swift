//
//  ServicesViewController.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 27/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import UIKit

protocol ServicesViewControllerDelegate: class {

    /// Called when user selects characteristic from the list without responce
    func didSend(data: Data, to device: Device, characteristic: Characteristic)
}

class ServicesViewController: UITableViewController {
    
    // MARK: - Properties

    private let device: Device
    private var loadingIndicator: UIActivityIndicatorView?
    public weak var delegate: ServicesViewControllerDelegate?

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
        self.configureLoadingIndicator()
    }

    // MARK: - Public methods

    /// Updating all content
    public func updateContent() {
        self.tableView.reloadData()
        self.loadingIndicator?.stopAnimating()
    }

    // MARK: - Private methods

    /// Configuring loading indicator
    private func configureLoadingIndicator() {
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.loadingIndicator?.hidesWhenStopped = true
        self.loadingIndicator?.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator!)
    }
}

// MARK: - UITableViewDataSource

extension ServicesViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characteristic = self.device.services[indexPath.section].characteristic[indexPath.row]
        self.delegate?.didSend(data: Constants.testData, to: self.device, characteristic: characteristic)
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
        return self.device.services[section].uuid
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) else {
                return UITableViewCell(style: .value1, reuseIdentifier: Constants.cellIdentifier)
            }
            return cell
        }()

        cell.textLabel?.text = self.device.services[indexPath.section].characteristic[indexPath.row].uuid
        return cell
    }
}
