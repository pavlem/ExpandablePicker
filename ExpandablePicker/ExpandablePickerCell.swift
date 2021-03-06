//
//  ExpandablePickerCell.swift
//  ExpandablePicker
//
//  Created by Pavle Mijatovic on 10/11/17.
//  Copyright © 2017 Pavle Mijatovic. All rights reserved.
//

import UIKit

protocol ExpandablePickerCellDelegate {
    func selectedPickerItem(_ selectedItem: String)
}

class ExpandablePickerCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var picker: UIPickerView!
    
    var delegate: ExpandablePickerCellDelegate?

    
    let pickerViewTitles = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        picker.delegate = self
        picker.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewTitles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerViewTitles[row])
        delegate?.selectedPickerItem(pickerViewTitles[row])
        //TODO: Delegate back to vc
    }

}
