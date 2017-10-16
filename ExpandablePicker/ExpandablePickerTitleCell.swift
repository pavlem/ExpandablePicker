//
//  ExpandablePickerTitleCell.swift
//  ExpandablePicker
//
//  Created by Pavle Mijatovic on 10/16/17.
//  Copyright © 2017 Pavle Mijatovic. All rights reserved.
//

import UIKit

class ExpandablePickerTitleCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    
    var isOpen = false
    
    func toggleDisclosure(_ open: Bool) {
        
        UIView.animate(withDuration: 0.2) {
            self.disclosureIndicator.transform = self.disclosureIndicator.transform.rotated(by: open ? .pi/2 : -.pi/2)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
