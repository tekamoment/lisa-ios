//
//  BookingDateSelectionViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import JTAppleCalendar

class BookingDateSelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = self.view.frame
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

}


extension BookingDateSelectionViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = Date()
        
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = 3
        let endDate = Calendar(identifier: .gregorian).date(byAdding: dateComponents, to: startDate)
        return ConfigurationParameters(startDate: startDate, endDate: endDate!)
    }
}

extension BookingDateSelectionViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        
        cell.dateBackgroundView.layer.cornerRadius = cell.dateBackgroundView.bounds.width / 8
        cell.dateBackgroundView.layer.borderWidth = 1.5
        cell.dateBackgroundView.layer.borderColor = UIColor.white.cgColor
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.dateLabel.textColor = UIColor(named: "DarkLISA")
        } else {
            cell.dateLabel.textColor = UIColor.white
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.dateBackgroundView.layer.backgroundColor = UIColor.white.cgColor
        } else {
            cell.dateBackgroundView.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
}

