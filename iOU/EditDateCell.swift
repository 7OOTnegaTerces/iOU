//
//  EditDateCell.swift
//  iOU
//
//  Created by Tateni Urio on 4/5/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditDateCell: UITableViewCell
{
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  
  @IBAction func updateDueDate(sender: UIDatePicker)
  {
    EditContractLogic.updateDynamicDate(self)
  }
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool)
  {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
