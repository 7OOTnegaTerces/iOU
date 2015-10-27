//
//  EditAlertRepeatSimpleCell.swift
//  iOU
//
//  Created by Tateni Urio on 5/11/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditAlertRepeatSimpleCell: EditAlertRepeatCell
{
  @IBOutlet weak var fromCompleation: UISwitch!
  
  
  @IBAction func toggleFromCompleation(sender: UISwitch)
  {
    EditContractLogic.toggleFromCompleation(sender)
  }
}
