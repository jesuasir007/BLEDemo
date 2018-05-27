//
//  RSSIChartView.swift
//  BLEDemo
//
//  Created by Roman Baitaliuk on 26/05/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit
import Charts

// MARK: - ChartViewDelegate

extension RSSIChartView: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else {
            return
        }
        let currentIndex = dataSet.entryIndex(entry: entry)
        let rssi = rssiYValues[currentIndex]
        self.selectedRSSILabel.attributedText = self.setAttributedString(rssi)
        let signalStrength = RSSISignalStrength.calculateSignalStrength(rssi: rssi)
        self.selectedRSSIStrength.text = signalStrength.rawValue
    }
}

final class RSSIChartView: UIView {

    // MARK: - Properties

    private var lineChartView: LineChartView!

    // RSSI values for 'ChartViewDelegate'
    private var rssiYValues: [Double] = [Double]()

    // Charts UI elements
    private let selectedRSSILabel = UILabel()
    private let selectedRSSIStrength = UILabel()
    private let averageRSSILabel = UILabel()
    private let minLabel = UILabel()
    private let maxLabel = UILabel()
    private let separator = UIView()
    private let leftStackView = UIStackView()
    private let rightStackView = UIStackView()
    private let roundedCornerView = UIView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        // Constraints for 'leftStackView'
        self.leftStackView.topAnchor.constraint(equalTo: self.lineChartView.topAnchor, constant: 4).isActive = true
        self.leftStackView.leftAnchor.constraint(equalTo: self.lineChartView.leftAnchor, constant: 12).isActive = true

        // Constraints for 'rightStackView'
        self.rightStackView.topAnchor.constraint(equalTo: self.roundedCornerView.topAnchor, constant: 4).isActive = true
        self.rightStackView.rightAnchor.constraint(equalTo: self.roundedCornerView.rightAnchor, constant: -8).isActive = true

        // Constraints for 'separator'
        self.separator.topAnchor.constraint(equalTo: self.leftStackView.bottomAnchor, constant: 3).isActive = true
        self.separator.leftAnchor.constraint(equalTo: self.lineChartView.leftAnchor, constant: 10).isActive = true
        self.separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.separator.widthAnchor.constraint(equalToConstant: self.frame.width-26).isActive = true

        // Constraints for 'roundedCornerView'
        self.roundedCornerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.roundedCornerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4).isActive = true
        self.roundedCornerView.widthAnchor.constraint(equalToConstant: self.frame.width - 8).isActive = true
        self.roundedCornerView.heightAnchor.constraint(equalToConstant: self.frame.height - 5).isActive = true

        // Constraints 'maxLabel'
        self.maxLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 2).isActive = true
        self.maxLabel.trailingAnchor.constraint(equalTo: separator.trailingAnchor).isActive = true

        // Constraints 'minLabel'
        self.minLabel.trailingAnchor.constraint(equalTo: maxLabel.trailingAnchor).isActive = true
        self.minLabel.topAnchor.constraint(equalTo: maxLabel.bottomAnchor, constant: 98).isActive = true
    }

    // MARK: - Public methods

    /// Setting chart with data
    public func set(timeIntervals: [String], rssiValues: [Double]) {
        if !timeIntervals.isEmpty && !rssiValues.isEmpty {

            var copiedTimeIntervals = timeIntervals
            copiedTimeIntervals[0].append(" \(Constants.timeIntervals)")
            self.rssiYValues = rssiValues

            self.averageRSSILabel.text = Constants.averageRSSIText + "\(rssiValues.average.roundTo(places: 1))"

            guard let maxValue = rssiYValues.min(), let minValue = rssiYValues.max() else {
                return
            }

            if minValue == maxValue {
                self.maxLabel.text = String(maxValue)
                self.minLabel.text = "\(Constants.minRSSI)"
            } else {
                self.minLabel.text = String(minValue)
                self.maxLabel.text = String(maxValue)
            }

            self.configureDataSet(timeIntervalsXLabels: copiedTimeIntervals, rssiYValues: rssiValues)
        } else {
            self.lineChartView.noDataText = Constants.chartEmptyDataText
            self.lineChartView.setNeedsDisplay()
        }
    }

    // MARK: - Private methods

    // Configuring view
    private func configureView() {
        self.backgroundColor = .clear
        self.setGradientBackground()
        self.configureLineChart()
        self.setHeaderElements()
        self.setNeedsUpdateConstraints()
    }

    // Configuring line chart
    private func configureLineChart() {
        self.lineChartView = LineChartView(frame: self.frame)
        self.lineChartView.delegate = self
        self.lineChartView.legend.enabled = false
        self.lineChartView.chartDescription?.text = ""
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.leftAxis.enabled = false
        self.lineChartView.xAxis.axisLineColor = UIColor.white
        self.lineChartView.drawGridBackgroundEnabled = false
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.isUserInteractionEnabled = true
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.xAxis.spaceMax = 0.4
        self.lineChartView.xAxis.spaceMin = 0.4
        self.lineChartView.xAxis.yOffset = 8
        self.lineChartView.isOpaque = false
        self.lineChartView.setScaleEnabled(false)
        self.lineChartView.backgroundColor = .clear
        self.lineChartView.xAxis.labelTextColor = UIColor.white
        self.lineChartView.borderLineWidth = 2.0
        self.lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 8)
        self.lineChartView.extraLeftOffset = 12.0
        self.lineChartView.extraBottomOffset = 10.0
        self.lineChartView.extraRightOffset = 16.0
        self.lineChartView.extraTopOffset = 45.0
        self.lineChartView.noDataTextColor = UIColor.white
        self.lineChartView.noDataText = ""
        self.lineChartView.leftAxis.inverted = true
        self.lineChartView.xAxis.granularity = 1.0

        self.roundedCornerView.addSubview(self.lineChartView)
    }

    // Configuring chart data set
    private func configureDataSet(timeIntervalsXLabels: [String], rssiYValues: [Double]) {
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<timeIntervalsXLabels.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: rssiYValues[i])
            dataEntries.append(dataEntry)
        }

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)

        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.circleColors = [UIColor.white]
        lineChartDataSet.circleHoleColor = UIColor(red: 103.0/255.0, green: 160.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.setColor(UIColor.white)
        lineChartDataSet.circleRadius = 3.0
        lineChartDataSet.circleHoleRadius = 1.0
        lineChartDataSet.highlightEnabled = true
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)

        let gradient = self.getGradientFilling()
        // Setting the Gradient
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        // Draw the Gradient
        lineChartDataSet.drawFilledEnabled = true

        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        self.lineChartView.data = lineChartData

        self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeIntervalsXLabels)
    }

    // Setting header elements
    private func setHeaderElements() {

        // Setting 'leftStackView'
        self.leftStackView.axis = .vertical
        self.leftStackView.distribution = .equalSpacing
        self.leftStackView.alignment = .leading
        self.leftStackView.spacing = 0
        self.leftStackView.translatesAutoresizingMaskIntoConstraints = false

        // Setting 'rssiLabel'
        let rssiLabel = UILabel(frame: .zero)
        rssiLabel.font = UIFont.boldSystemFont(ofSize: 17)
        rssiLabel.textColor = .white
        rssiLabel.text = "RSSI"
        self.leftStackView.addArrangedSubview(rssiLabel)

        // Setting 'averageRSSILabel'
        self.averageRSSILabel.text = Constants.averageRSSIText + "--"
        self.averageRSSILabel.font = UIFont.boldSystemFont(ofSize: 10)
        self.averageRSSILabel.textColor = .white
        self.averageRSSILabel.alpha = 0.85
        leftStackView.addArrangedSubview(self.averageRSSILabel)

        // Setting 'separator'
        self.separator.backgroundColor = .white
        self.separator.alpha = 0.6
        self.separator.translatesAutoresizingMaskIntoConstraints = false

        // Setting 'minLabel'
        self.minLabel.translatesAutoresizingMaskIntoConstraints = false
        self.minLabel.font = UIFont.boldSystemFont(ofSize: 8)
        self.minLabel.textColor = .white
        self.minLabel.alpha = 0.85
        self.lineChartView.addSubview(self.minLabel)

        // Setting 'maxLabel'
        self.maxLabel.translatesAutoresizingMaskIntoConstraints = false
        self.maxLabel.font = UIFont.boldSystemFont(ofSize: 8)
        self.maxLabel.textColor = .white
        self.maxLabel.alpha = 0.85
        self.lineChartView.addSubview(self.maxLabel)

        // Setting 'roundedCornerView'
        self.roundedCornerView.layer.cornerRadius = 5.0
        self.roundedCornerView.clipsToBounds = true
        self.roundedCornerView.translatesAutoresizingMaskIntoConstraints = false

        // Setting 'rightStackView'
        self.rightStackView.axis = .vertical
        self.rightStackView.distribution = .equalSpacing
        self.rightStackView.alignment = .trailing
        self.rightStackView.spacing = 0
        self.rightStackView.translatesAutoresizingMaskIntoConstraints = false

        // Setting 'selectedRSSILabel'
        self.selectedRSSILabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.selectedRSSILabel.textColor = .white
        self.rightStackView.addArrangedSubview(self.selectedRSSILabel)

        // setting 'selectedRSSIStrength'
        self.selectedRSSIStrength.font = UIFont.boldSystemFont(ofSize: 10)
        self.selectedRSSIStrength.textColor = .white
        self.selectedRSSIStrength.alpha = 0.85
        self.rightStackView.addArrangedSubview(self.selectedRSSIStrength)

        self.lineChartView.addSubview(self.rightStackView)
        self.lineChartView.addSubview(self.leftStackView)
        self.lineChartView.addSubview(self.separator)
    }

    // Setting attributed string for selected RSSI value
    private func setAttributedString(_ rssiValue: Double) -> NSMutableAttributedString {
        let numbersAttr = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        let hoursMinAttr = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)
        ]

        let combination = NSMutableAttributedString()

        let partOne = NSMutableAttributedString(string: String(Int(rssiValue)), attributes: numbersAttr)
        let partTwo = NSMutableAttributedString(string: Constants.RSSIMeasurement, attributes: hoursMinAttr)

        combination.append(partOne)
        combination.append(partTwo)

        return combination
    }

    // Setting gradient color for background
    private func setGradientBackground() {
        let colorTop = UIColor(red: 231.0/255.0, green: 148.0/255.0, blue: 85.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 221.0/255.0, green: 63.0/255.0, blue: 53.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.bounds

        self.roundedCornerView.layer.addSublayer(gradientLayer)
        self.addSubview(self.roundedCornerView)
    }

    /// Creating gradient for filling space under the line chart
    private func getGradientFilling() -> CGGradient {
        // Setting fill gradient color
        let coloTop = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor
        let colorBottom = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1).cgColor
        // Colors of the gradient
        let gradientColors = [coloTop, colorBottom] as CFArray
        // Positioning of the gradient
        let colorLocations: [CGFloat] = [0.7, 0.0]
        // Gradient Object
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
    }
}
