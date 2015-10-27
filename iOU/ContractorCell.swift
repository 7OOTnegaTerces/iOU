//
//  ContractorCell.swift
//  iOU
//
//  Created by Tateni Urio on 2/2/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ContractorCell: UITableViewCell
{
  @IBOutlet weak var currency: UIButton!
  @IBOutlet weak var takeUpSlack: UIButton!
  internal var isLenderCell: Bool!
  internal var row: Int!
  internal var cell: UITableViewCell
    {
    get
    {
      return self
    }
  }
  
  
  @IBAction func toggleSlack(button: UIButton)
  {
    EditContractLogic.toggleContractorSlackButton(self)
  }
  
  @IBAction func updateCurrency(sender: UIButton)
  {
    //TODO - Implement Different Currencies.
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
