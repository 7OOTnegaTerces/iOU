//
//  EditMonetaryValueCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditMonetaryValueCell: UITableViewCell, MonetaryValue
{
  @IBOutlet weak var contractCurrency: UIButton!
  @IBOutlet weak var monetaryValue: UITextField!
  
  @IBAction func updateContractMonetaryValue(sender: UITextField)
  {
    iOULogic.updateMonetaryValueText(sender: self, includeDecimal: true)
  }
  
  @IBAction func updateCurrency(sender: UIButton)
  {
    //TODO - Implement Different Currencies.
  }

  @IBAction func displayCalculator(sender: UIButton)
  {
    iOUData.sharedInstance.temporaryData.displayCalculator = true
    NSNotificationCenter.defaultCenter().postNotificationName("Refresh", object: nil)
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
