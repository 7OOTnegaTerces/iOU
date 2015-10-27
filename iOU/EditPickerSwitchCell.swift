//
//  EditPickerSwitchCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/15/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditPickerSwitchCell: EditPickerCell, UIPickerViewDelegate, UIPickerViewDataSource, PickerSwitchCell
{
  internal weak var switchLabel: UILabel!
  @IBOutlet weak var toggle: UISwitch!
  
  
  @IBAction func flipToggle(sender: UISwitch)
  {
    EditContractLogic.flipToggle(toggle: sender)
  }
}
