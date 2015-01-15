//
//  EditMonetaryValueWithCalculatorCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/9/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditMonetaryValueWithCalculatorCell: UITableViewCell, MonetaryValue
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
    iOUData.sharedInstance.temporaryData.displayCalculator = false
    iOULogic.calculateValue()
    NSNotificationCenter.defaultCenter().postNotificationName("Refresh", object: nil)
  }
  
  @IBAction func addValue(sender: UIButton)
  {
    monetaryValue.text = iOULogic.performOperation(Operation.Add)
  }
  
  @IBAction func subtractValue(sender: UIButton)
  {
    monetaryValue.text = iOULogic.performOperation(Operation.Subtract)
  }
  
  @IBAction func multiplyValue(sender: UIButton)
  {
    monetaryValue.text = iOULogic.performOperation(Operation.Multiply)
  }
  
  @IBAction func divideValue(sender: UIButton)
  {
    monetaryValue.text = iOULogic.performOperation(Operation.Divide)
  }
  
  @IBAction func calculateValue(sender: UIButton)
  {
    monetaryValue.text = iOULogic.calculateValue()
  }
  
  @IBAction func clearValue(sender: UIButton)
  {
    monetaryValue.text = "0.00"
    iOUData.sharedInstance.temporaryData.contract.monetaryValue = Double(0)
  }
  
  @IBAction func clearAllValues(sender: UIButton)
  {
    monetaryValue.text = "0.00"
    iOUData.sharedInstance.temporaryData.calculatorValue = nil
    iOUData.sharedInstance.temporaryData.contract.monetaryValue = Double(0)
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
