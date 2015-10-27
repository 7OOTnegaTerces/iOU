//
//  EditDatePickerCell.swift
//  iOU
//
//  Created by Tateni Urio on 4/5/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditDatePickerCell: EditDateCell
{
  @IBAction func toggleCalender(sender: UIButton)
  {
    EditContractLogic.toggleCalender()
  }
}
