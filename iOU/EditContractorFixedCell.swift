//
//  EditContractorFixedCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorFixedCell: EditContractorCell, MonetaryValue, EditMonetaryCell
{
  @IBOutlet weak var monetaryValue: UITextField!
  
  
  @IBAction func updateMonetaryValue(sender: UITextField)
  {
    let contractorType = isLenderCell! ? "Lender" : "Borrower"
    EditContractLogic.updateFixedMonetaryValue(sender: sender, contractorType: contractorType)
    
    if (focusContractorName)
    {
      focusContractorName = false
      self.monetaryValue.becomeFirstResponder()
    }
  }
  
  override func setFocus()
  {
    if (focusContractorName)
    {
      super.setFocus()
    }
    else
    {
      monetaryValue.becomeFirstResponder()
    }
  }
  
  override func clearFocus()
  {
    if (focusContractorName)
    {
      super.clearFocus()
    }
    else
    {
      monetaryValue.resignFirstResponder()
    }
  }
}
