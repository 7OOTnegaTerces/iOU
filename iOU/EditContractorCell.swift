//
//  EditContractorCell.swift
//  iOU
//
//  Created by Tateni Urio on 2/10/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorCell: ContractorCell, Focus
{
  @IBOutlet weak var contractorName: UITextField!
  internal var focusContractorName: Bool = true
  
  
  @IBAction func updateContractorName(sender: UITextField)
  {
    //Whenever the user changes the Contractor's name, update Contractor.
    var dynamicEditValue = iOUData.sharedInstance.contractTemporaryData.dynamicEditValues
    var contractor = dynamicEditValue["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
    contractor.key = contractorName.text!
    dynamicEditValue["DynamicEditContractor"] = contractor
    focusContractorName = true
  }
  
  func setFocus()
  {
    contractorName.becomeFirstResponder()
  }
  
  func clearFocus()
  {
    contractorName.resignFirstResponder()
  }
}
