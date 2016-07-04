//
//  EditMonetaryValueWithCalculatorCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/9/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditMonetaryValueWithCalculatorCell: EditMonetaryValueCell
{
  @IBAction override func displayCalculator(sender: UIButton)
  {
    EditContractLogic.displayCalculator(false)
  }
  
  @IBAction func addValue(sender: UIButton)
  {
    monetaryValue.text = EditContractLogic.performOperation(Operation.Add)
  }
  
  @IBAction func subtractValue(sender: UIButton)
  {
    monetaryValue.text = EditContractLogic.performOperation(Operation.Subtract)
  }
  
  @IBAction func multiplyValue(sender: UIButton)
  {
    monetaryValue.text = EditContractLogic.performOperation(Operation.Multiply)
  }
  
  @IBAction func divideValue(sender: UIButton)
  {
    monetaryValue.text = EditContractLogic.performOperation(Operation.Divide)
  }
  
  @IBAction func calculateValue(sender: UIButton)
  {
    monetaryValue.text = EditContractLogic.calculateValue()
  }
  
  @IBAction func clearValue(sender: UIButton)
  {
    monetaryValue.text = "0.00"
    iOUData.sharedInstance.contractTemporaryData.contract.monetaryValue = Double(0)
  }
  
  @IBAction func clearAllValues(sender: UIButton)
  {
    monetaryValue.text = "0.00"
    iOUData.sharedInstance.contractTemporaryData.dynamicEditValues["CalculatorValue"] = nil
    iOUData.sharedInstance.contractTemporaryData.contract.monetaryValue = Double(0)
  }
}
