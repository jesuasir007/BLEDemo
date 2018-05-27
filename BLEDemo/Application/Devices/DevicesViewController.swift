//
//  DevicesViewController.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit

protocol DevicesViewControllerDelegate: class {
    
    /// Called when user selecting device in the list
    func didSelectDevice(_ device: Device)
}

class DevicesViewController: UITableViewController {
    
    // MARK: - Properties
    
    public weak var delegate: DevicesViewControllerDelegate?
    
    private var devices: [Device] = []
    private let bluetoothService: BluetoothService

    /// Updates table view with new data every 1 seconds
    private var loadingIndicator: UIActivityIndicatorView?
    
    // MARK: - Init
    
    public init(bluetoothService: BluetoothService) {
        self.bluetoothService = bluetoothService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLoadingIndicator()
        self.tableView.tableFooterView = UIView()

        if self.bluetoothService.isPowerOn() {
            self.startRefreshing()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !self.bluetoothService.isScanning() {
            self.bluetoothService.startScanning()
        }
    }

    // MARK: - Public methods

    /// Updating table view when contant have been updated
    public func updateContent() {
        self.devices = self.bluetoothService.getDevices()
        self.tableView.reloadData()
    }

    /// Start refreshing content
    public func startRefreshing() {
        self.loadingIndicator?.startAnimating()
    }

    /// Stop refreshing content
    public func stopRefreshing() {
        self.loadingIndicator?.stopAnimating()
    }

    // MARK: - Private methods

    /// Configuring oading indicator
    private func configureLoadingIndicator() {
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.loadingIndicator?.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator!)
    }
}

// MARK: - UITableViewDelegate

extension DevicesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) else {
                return UITableViewCell(style: .value1, reuseIdentifier: Constants.cellIdentifier)
            }
            return cell
        }()
        cell.textLabel?.text = self.devices[indexPath.row].name
        if let rssi = self.devices[indexPath.row].rssiValues.last?.rssi {
            cell.detailTextLabel?.text = String(rssi)
        }
        return cell
    }
}

// MARK: - UITableViewDataSource

extension DevicesViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectDevice(self.devices[indexPath.row])
    }
}
