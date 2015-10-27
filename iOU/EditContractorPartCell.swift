//
//  EditContractorPartCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/21/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorPartCell: EditContractorCell, EditPartCell
{
  @IBOutlet weak var monetaryShare: UITextField!
  @IBOutlet weak var monetaryLabel: UILabel!
  
  
  @IBAction func updateMonetaryParts(sender: UITextField)
  {
    EditContractLogic.updateMonetaryParts(self)
    
    if (focusContractorName)
    {
      focusContractorName = false
      monetaryShare.becomeFirstResponder()
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
      monetaryShare.becomeFirstResponder()
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
      monetaryShare.resignFirstResponder()
    }
  }
}
