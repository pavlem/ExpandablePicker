//
//  ExpandablePickerVC.swift
//  ExpandablePicker
//
//  Created by Pavle Mijatovic on 10/11/17.
//  Copyright © 2017 Pavle Mijatovic. All rights reserved.
//

import UIKit

class ExpandablePickerVC: UITableViewController, ExpandablePickerCellDelegate {
    
    let kInfoPickerTag = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kPickerItemsKey  = "pickerItems"  // key for obtaining the data source item's date value
    
    let kInfoCellID       = "infoCell";       // the cells with the start or end date
    let kInfoPickerCellID = "infoPickerCell"; // the cell containing the date picker
    
    var dataArray: [[String: AnyObject]] = []

    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    var pickerCellRowHeight: CGFloat = 216
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewUI()

        // setup our data source
        let item1 = [kTitleKey : "Prvi", kPickerItemsKey : ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]] as [String : Any]
        let item2 = [kTitleKey : "Drugi", kPickerItemsKey : ["1", "2", "3", "4", "5", "6"]] as [String : Any]
        
        dataArray = [item1 as Dictionary<String, AnyObject>, item2 as Dictionary<String, AnyObject>]
    }
    
    private func setTableViewUI() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView!.isHidden = true
        tableView.backgroundColor = UIColor.lightGray
    }

    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kInfoPickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func updateDatePicker() {
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
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
     
     @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
     */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath: indexPath as NSIndexPath) ? pickerCellRowHeight : tableView.rowHeight)
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

        }
        
        if cellID == kInfoCellID {
            // we have either start or end date cells, populate their date field
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            
            if let arr = itemData[kPickerItemsKey] as? [String] {
                cell?.detailTextLabel?.text = arr.first
            }
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
        if cell?.reuseIdentifier == kInfoCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath: indexPath as NSIndexPath)
        } else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    //MARK: - Exp Cell Delegate
    func selectedPickerItem(_ selectedItem: String) {
        print(selectedItem)
    }
}
