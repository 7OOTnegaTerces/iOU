//
//  EditSelfFixedCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditSelfFixedCell: ContractorCell, MonetaryValue, EditMonetaryCell
{
  @IBOutlet weak var monetaryValue: UITextField!
  
  
  @IBAction func updateMonetaryValue(sender: UITextField)
  {
    let contractorType = isLenderCell! ? "Lender" : "Borrower"
    EditContractLogic.updateFixedMonetaryValue(sender: sender, contractorType: contractorType)
  }
  
  func setFocus()
  {
    monetaryValue.becomeFirstResponder()
  }
  
  func clearFocus()
  {
    monetaryValue.resignFirstResponder()
  }
}
