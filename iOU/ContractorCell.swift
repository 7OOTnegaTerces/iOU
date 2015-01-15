//
//  ContractorCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/12/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ContractorCell: UITableViewCell
{
  @IBOutlet weak var contractorName: UILabel!
  @IBOutlet weak var contractorValue: UILabel!
  
  
  func loadData(#contractorName: String, contractorValue: Double, isLender: Bool)
  {
    self.contractorName.text = contractorName
    let currency = iOUData.sharedInstance.currency.rawValue
    var shares: Shares
    
    if (isLender)
    {
      shares = iOUData.sharedInstance.temporaryData.contract.lenderShares
    }
    else
    {
      shares = iOUData.sharedInstance.temporaryData.contract.borrowerShares
    }
    
    if (shares == Shares.Equal || shares == Shares.Fixed)
    {
      self.contractorValue.text = String(format: currency + " %.2f", contractorValue)
    }
    else if (shares == Shares.Percentage)
    {
      self.contractorValue.text = "\(Int(contractorValue))%"
    }
    else
    {
      self.contractorValue.text = String(Int(contractorValue))
    }
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
