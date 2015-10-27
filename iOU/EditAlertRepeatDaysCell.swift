//
//  EditAlertRepeatDaysCell.swift
//  iOU
//
//  Created by Tateni Urio on 5/11/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditAlertRepeatDaysCell: EditAlertRepeatCell
{
  @IBOutlet weak var monday: UIButton!
  @IBOutlet weak var tuesday: UIButton!
  @IBOutlet weak var wednesday: UIButton!
  @IBOutlet weak var thursday: UIButton!
  @IBOutlet weak var friday: UIButton!
  @IBOutlet weak var saturday: UIButton!
  @IBOutlet weak var sunday: UIButton!
  
  
  @IBAction func toggleWeekdays(sender: UIButton)
  {
    EditContractLogic.toggleWeekdays(self)
  }
  
  @IBAction func toggleWeekends(sender: UIButton)
  {
    EditContractLogic.toggleWeekends(self)
  }
  
  @IBAction func toggleMonday(sender: UIButton)
  {
    EditContractLogic.toggleMonday(sender)
  }
  
  @IBAction func toggleTuesday(sender: UIButton)
  {
    EditContractLogic.toggleTuesday(sender)
  }
  
  @IBAction func toggleWednesday(sender: UIButton)
  {
    EditContractLogic.toggleWednesday(sender)
  }
  
  @IBAction func toggleThursday(sender: UIButton)
  {
    EditContractLogic.toggleThursday(sender)
  }
  
  @IBAction func toggleFriday(sender: UIButton)
  {
    EditContractLogic.toggleFriday(sender)
  }
  
  @IBAction func toggleSaturday(sender: UIButton)
  {
    EditContractLogic.toggleSaturday(sender)
  }
  
  @IBAction func toggleSunday(sender: UIButton)
  {
    EditContractLogic.toggleSunday(sender)
  }
}
