//
//  EditContractorNameAndValueCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorNameAndValueCell: UITableViewCell, MonetaryValue, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var contractorName: UITextField!
  @IBOutlet weak var monetaryValue: UITextField!
  @IBOutlet var monetaryValueWidthConstraint: NSLayoutConstraint!
  private var includeDecimal: Bool!
  
  
  func loadData()
  {
    let contractor = iOUData.sharedInstance.temporaryData.dynamicEditContractor
    contractorName.text = contractor.key
    
    //If this cell is a lender or a borrower with fixed value shares, set includeDecimal to true and format monetaryValue.text approiately.
    let id = iOUData.sharedInstance.temporaryData.dynamicEdit.id
    let lenderShares = iOUData.sharedInstance.temporaryData.contract.lenderShares
    let borrowerShares = iOUData.sharedInstance.temporaryData.contract.borrowerShares
    
    if ((id == "Lender" && lenderShares == Shares.Fixed) || (id == "Borrower" && borrowerShares == Shares.Fixed))
    {
      monetaryValue.text = String(format: "%.2f", contractor.value)
      includeDecimal = true
    }
    else
    {
      monetaryValue.text = String(Int(contractor.value))
      includeDecimal = false
    }
  }
  
  @IBAction func changeContractorName(sender: UITextField)
  {
    //Whenever the user changes the contractor's name, update contractor.
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.key = contractorName.text
  }
  
  @IBAction func changeMonetaryValue(sender: UITextField)
  {
    iOULogic.changeMonetaryValueText(sender: self, includeDecimal: includeDecimal)
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
