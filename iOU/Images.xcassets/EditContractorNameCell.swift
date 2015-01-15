//
//  EditContractorNameCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/8/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorNameCell: UITableViewCell, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var contractorName: UITextField!
  @IBOutlet weak var monetaryValue: UILabel!
  @IBOutlet var monetaryValueWidthConstraint: NSLayoutConstraint!
  
  
  func loadData()
  {
    let contractor = iOUData.sharedInstance.temporaryData.dynamicEditContractor
    contractorName.text = contractor.key
    monetaryValue.text = String(format: "%.2f", contractor.value)
  }
  
  @IBAction func changeContractorName(sender: UITextField)
  {
    //Whenever the user changes the contractor's name, update contractor.
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.key = contractorName.text
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
