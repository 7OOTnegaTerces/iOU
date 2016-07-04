//
//  EditMonetaryValueCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditMonetaryValueCell: UITableViewCell, MonetaryValue, Focus
{
  @IBOutlet weak var contractCurrency: UIButton!
  @IBOutlet weak var monetaryValue: UITextField!
  
  @IBAction func updateContractMonetaryValue(sender: UITextField)
  {
    EditContractLogic.updateMonetaryValue(sender)
  }
  
  @IBAction func updateCurrency(sender: UIButton)
  {
    //TODO: Implement Different Currencies.
  }

  @IBAction func displayCalculator(sender: UIButton)
  {
    EditContractLogic.displayCalculator(true)
  }
  
  func setFocus()
  {
    monetaryValue.becomeFirstResponder()
  }
  
  func clearFocus()
  {
    monetaryValue.resignFirstResponder()
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
