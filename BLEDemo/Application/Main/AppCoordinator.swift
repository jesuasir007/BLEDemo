//
//  AppCoordinator.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator {
    
    // MARK: - Properties
    
    private var rootViewController: UIViewController {
        return self.navigationController
    }
    
    private lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }()
    
    private let window: UIWindow
    
    /// Handles all interactions with CoreBluetooth
    private let bluetoothService: BluetoothService = {
        return BluetoothService()
    }()
    
    // MARK: - Init
    
    public init(window: UIWindow) {
        self.window = window

        self.bluetoothService.delegate = self
        self.window.rootViewController = self.rootViewController
        self.window.makeKeyAndVisible()
    }
    
    // MARK: - Public methods
    
    /// Starting flow
    public func start() {
        self.showDevicesScreen()
    }
    
    // MARK: - Private methods

    /// Showing screen with all devices
    private func showDevicesScreen() {
        let devicesViewController = DevicesViewController(bluetoothService: self.bluetoothService)
        devicesViewController.delegate = self
        self.navigationController.pushViewController(devicesViewController, animated: true)
        devicesViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        devicesViewController.title = "Devices"
    }

    /// Showing device details
    private func showDeviceDetailsScreen(_ device: Device) {
        let deviceDetailsViewController = DeviceDetailsViewController(device: device, bluetoothService: self.bluetoothService)
        deviceDetailsViewController.delegate = self
        deviceDetailsViewController.title = device.name
        self.navigationController.pushViewController(deviceDetailsViewController, animated: true)
    }

    public func showServicesScreen(for device: Device) {
        let servicesViewController = ServicesViewController(device: device)
        servicesViewController.title = "Services"
        self.navigationController.pushViewController(servicesViewController, animated: true)
    }

    /// Getting 'DevicesViewController' which always in navigation stack
    private func getDevicesViewController() -> DevicesViewController? {
        for controller in self.navigationController.viewControllers {
            if let devicesViewController = controller as? DevicesViewController {
                return devicesViewController
            }
        }
        return nil
    }

    /// Getting 'DeviceDetailsViewController' from navigation stack
    private func getDeviceDetailsViewController() -> DeviceDetailsViewController? {
        for controller in self.navigationController.viewControllers {
            if let deviceDetailsViewController = controller as? DeviceDetailsViewController {
                return deviceDetailsViewController
            }
        }
        return nil
    }

    /// Getting 'ServicesViewController' from navigation stack
    private func getServicesViewController() -> ServicesViewController? {
        for controller in self.navigationController.viewControllers {
            if let servicesViewController = controller as? ServicesViewController {
                return servicesViewController
            }
        }
        return nil
    }

    /// Showing error alert
    private func showError(_ error: AppError) {
        var alertController: UIAlertController!
        switch error {
        case .bluetoothIsOff, .notConnected:
            alertController = self.createAlertController(title: error.title, message: error.message, buttonTitle: error.buttonTitle)
        default:
            alertController = self.createAlertController()
        }
        self.rootViewController.present(alertController, animated: true, completion: nil)
    }

    /// Constructing alert with required fields
    private func createAlertController(title: String? = nil, message: String? = nil, buttonTitle: String? = nil, action: ErrorAction? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title ?? AppError.unknown.title,
                                      message: message ?? AppError.unknown.message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle ?? AppError.unknown.buttonTitle, style: .default, handler: { _ in
            action?()
        }))
        return alert
    }

    private func isDeviceDetailsScreenPresenting() -> Bool {
        return self.navigationController.viewControllers.count > 1
    }
}

// MARK: - DevicesViewControllerDelegate

extension AppCoordinator: DevicesViewControllerDelegate {

    func didSelectDevice(_ device: Device) {
        self.showDeviceDetailsScreen(device)

        // We want to pause scanning when we're transfering to device details screen
        self.bluetoothService.stopScanning()
    }
}

// MARK: - DeviceDetailsViewControllerDelegate

extension AppCoordinator: DeviceDetailsViewControllerDelegate {

    func didSelect(interaction: DeviceInteraction, for device: Device) {
        switch interaction {
        case .connect:
            self.bluetoothService.connect(to: device)
        case .send:
            break
        case .services:
            self.showServicesScreen(for: device)
            self.bluetoothService.searchServices(for: device)
        }
    }
}

// MARK: - BluetoothServiceDelegate

extension AppCoordinator: BluetoothServiceDelegate {

    func didDeviceCharacteristicsUpdate() {
        if let controller = self.getServicesViewController() {
            controller.updateContent()
        }
    }

    func didFail(with error: AppError) {
        self.showError(error)
    }

    func didDeviceConnectionUpdate() {
        if let controller = self.getDeviceDetailsViewController() {
            controller.updateConnectionStatus()
        }
    }

    func didDeviceUpdate() {
        self.getDevicesViewController()?.updateContent()
    }

    func didPowerStateUpdate(isPowerOn: Bool) {
        if let devicesViewController = self.getDevicesViewController() {
            if !isPowerOn {
                devicesViewController.stopRefreshing()
                self.showError(AppError.bluetoothIsOff)
            } else {
                // we don't want to start scanning if power become on in device details Screen
                if !self.isDeviceDetailsScreenPresenting() {
                    self.bluetoothService.startScanning()
                }
                devicesViewController.startRefreshing()
            }
        }
    }
}
