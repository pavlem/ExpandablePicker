//
//  ExpandablePickerVC.swift
//  ExpandablePicker
//
//  Created by Pavle Mijatovic on 10/11/17.
//  Copyright © 2017 Pavle Mijatovic. All rights reserved.
//

import UIKit

protocol ExpandablePickerVCDelegate: class {
    func pickerToggle(pickerCellHeight: CGFloat, titleCellHeight: CGFloat, isPickerOpen: Bool, isSameTitleCellTapped: Bool, toggleDuration: Double)
    func selectedPickerItem(_ selectedItem: String)
}

class ExpandablePickerVC: UITableViewController, ExpandablePickerCellDelegate {
    
    weak var delegate: ExpandablePickerVCDelegate?
    
    fileprivate var lastTappedTitleCell: UITableViewCell?
    
    let kInfoPickerTag = 99   // view tag identifiying the date picker view
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kPickerItemsKey  = "pickerItems"  // key for obtaining the data source item's date value
    let kInfoCellID       = "infoCell";       // the cells with the start or end date
    let kInfoPickerCellID = "infoPickerCell"; // the cell containing the date picker
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    let pickerCellRowHeight: CGFloat = 170
    let titleCellRowHeight: CGFloat = 60
    
    let togleAnimationDuration = Double(0.25)
    
    var dataArray: [[String: AnyObject]] = []
    var selectedPickerValues = [String]()
    
    
    //MARK: - API
    func closeOpenedCell() {
        guard datePickerIndexPath != nil else { //Checks if Picker is expanded
            return
        }
        
        if let cell = lastTappedTitleCell {
            tap(cell: cell)
        }
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewUI()
        setDefaultDataSourceValues()
    }
    
    fileprivate func tap(cell: UITableViewCell) {
        
        if let rowToSelect = tableView.indexPath(for: cell) {
            tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: rowToSelect)
        }
    }
    
    //MARK: - UI
    fileprivate func setTableViewUI() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView!.isHidden = true
        tableView.backgroundColor = UIColor.lightGray
    }
    
    //MARK: - Helper
    fileprivate func setDefaultDataSourceValues() {
        if dataArray.count == 0 {
            let item1 = [kTitleKey : "First", kPickerItemsKey : ["One", "Two", "Three", "Four", "Five", "Six"]] as [String : Any]
            let item2 = [kTitleKey : "Second", kPickerItemsKey : ["2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7"]] as [String : Any]
            let item3 = [kTitleKey : "Third", kPickerItemsKey : ["3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7"]] as [String : Any]
            
            dataArray = [item1 as Dictionary<String, AnyObject>,
                         item2 as Dictionary<String, AnyObject>,
                         item3 as Dictionary<String, AnyObject>]
        }
        
        selectedPickerValues = ["Three", "2-7", "3-3"]
    }
    
    
    //MARK: - Picker Helper
    fileprivate func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kInfoPickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    fileprivate func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRow(at: indexPath as IndexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kInfoPickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate((itemData[kPickerItemsKey] as! NSDate) as Date, animated: false)
            }
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
     */
    fileprivate func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
     @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
     */
    fileprivate func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    fileprivate func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath: indexPath as NSIndexPath) ? pickerCellRowHeight : titleCellRowHeight)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            return dataArray.count + 1;
        }
        
        return dataArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        var cellID = String()
        
        if indexPathHasPicker(indexPath: indexPath as NSIndexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kInfoPickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath: indexPath as NSIndexPath) {
            // the indexPath is one that contains the date information
            cellID = kInfoCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && (datePickerIndexPath?.row)! <= indexPath.row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kInfoPickerCellID {
            let pickerCell = cell as! ExpandablePickerCell
            pickerCell.pickerViewTitles = itemData[kPickerItemsKey] as! [String]
            pickerCell.delegate = self
            pickerCell.picker.reloadAllComponents()
            
            if let index = pickerCell.pickerViewTitles.index(of: selectedPickerValues[modelRow]) {
                pickerCell.picker.selectRow(index, inComponent:0, animated:false)
                
            } else {
                pickerCell.picker.selectRow(0, inComponent:0, animated:false)
            }
        }
        
        if cellID == kInfoCellID {
            // we have either start or end date cells, populate their date field
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = selectedPickerValues[modelRow]
        }
        
        return cell!
    }
    
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath: indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths as [IndexPath], with: .fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths as [IndexPath], with: .fade)
        }
        
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row)! < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            
            tableView.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 0)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal =  IndexPath(row: rowToReveal, section: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPath: indexPathToReveal as NSIndexPath)
            datePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: 0) as NSIndexPath
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRow(at: indexPath as IndexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        
        delegate?.pickerToggle(pickerCellHeight: pickerCellRowHeight, titleCellHeight: titleCellRowHeight, isPickerOpen: hasInlineDatePicker(), isSameTitleCellTapped: lastTappedTitleCell == cell ? true : false, toggleDuration: togleAnimationDuration)
        
        lastTappedTitleCell = cell!
        
        if cell?.reuseIdentifier == kInfoCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath: indexPath as NSIndexPath)
        } else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    //MARK: - Expandable Picker Cell Delegate
    func selectedPickerItem(_ selectedItem: String, sender: UIPickerView) {
        print(selectedItem)
        
        let targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 0) as NSIndexPath
        let cell = tableView.cellForRow(at: targetedCellIndexPath as IndexPath)
        
        selectedPickerValues[targetedCellIndexPath.row] = selectedItem
        cell?.detailTextLabel?.text = selectedItem
        
        delegate?.selectedPickerItem(selectedItem)
    }
}

