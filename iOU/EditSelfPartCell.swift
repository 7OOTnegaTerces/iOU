//
//  EditSelfPartCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/21/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditSelfPartCell: ContractorCell, EditPartCell
{
  @IBOutlet weak var monetaryShare: UITextField!
  @IBOutlet weak var monetaryLabel: UILabel!
  
  
  @IBAction func updateMonetaryParts(sender: UITextField)
  {
    EditContractLogic.updateMonetaryParts(self)
  }
  
  func setFocus()
  {
    monetaryShare.becomeFirstResponder()
  }
  
  func clearFocus()
  {
    monetaryShare.resignFirstResponder()
  }
}
