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
  
  func loadData()
  {
    let currency = iOUData.sharedInstance.currency.rawValue
    contractCurrency.setTitle(currency, forState: UIControlState.Normal)
    let monetaryValue = iOUData.sharedInstance.temporaryData.contract.monetaryValue
    self.monetaryValue.text = String(format: "%.2f", monetaryValue)
  }
  
  @IBAction func changeContractMonetaryValue(sender: UITextField)
  {
    iOULogic.changeMonetaryValueText(sender: self, includeDecimal: true)
  }
  
  @IBAction func changeCurrency(sender: UIButton)
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
