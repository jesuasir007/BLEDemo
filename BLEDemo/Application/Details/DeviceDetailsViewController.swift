//
//  DeviceDetailsViewController.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit

protocol DeviceDetailsViewControllerDelegate: class {

    func didSelect(interaction: DeviceInteraction, for device: Device)
}

class DeviceDetailsViewController: UITableViewController {

    // MARK: - Properties

    public weak var delegate: DeviceDetailsViewControllerDelegate?

    private let device: Device
    private let cellsButtonText: [String] = Constants.cellsButtonText

    private var chartView: RSSIChartView!
    private let bluetoothService: BluetoothService

    // MARK: - Init

    public init(device: Device, bluetoothService: BluetoothService) {
        self.device = device
        self.bluetoothService = bluetoothService
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("[DeviceDetailsViewController] is deinitializeed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.configureChart()
    }

    // MARK: - Public methods

    /// Updating connection status
    public func updateConnectionStatus() {
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = self.checkCurrentConnection()
    }

    // MARK: - Private methods

    /// Configuring chart
    private func configureChart() {
        self.chartView = RSSIChartView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 190))
        let rssi = self.device.rssiValues.map { $0.rssi }
        let timeIntervals = self.device.rssiValues.map { $0.date.seconds() }
        self.chartView.set(timeIntervals: timeIntervals, rssiValues: rssi)
    }

    private func checkCurrentConnection() -> String {
        return (self.device.isConnected == false) ? DeviceConnectionStatus.disconnected.rawValue : DeviceConnectionStatus.connected.rawValue
    }
}

// MARK: - UITableViewDataSource

extension DeviceDetailsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let interaction = DeviceInteraction.identifyInteraction(for: indexPath.row) {
            self.delegate?.didSelect(interaction: interaction, for: self.device)
        }
    }
}

// MARK: - UITableViewDelegate

extension DeviceDetailsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return (section == 0) ? 1 : self.cellsButtonText.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0) ? 190 : 44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) else {
                return UITableViewCell(style: .value1, reuseIdentifier: Constants.cellIdentifier)
            }
            return cell
        }()
        if indexPath.section == 0 {
            cell.addSubview(self.chartView)
            cell.selectionStyle = .none
            return cell
        } else {
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = self.checkCurrentConnection()
                cell.selectionStyle = .none
            default:
                cell.accessoryType = .disclosureIndicator
            }
            cell.textLabel?.text = self.cellsButtonText[indexPath.row]
            return cell
        }
    }
}
