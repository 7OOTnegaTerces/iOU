//
//  EditLenderNameAndValuePercentageCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditLenderNameAndValuePercentageCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource
{
  @IBOutlet weak var lenderName: UITextField!
  @IBOutlet weak var percentage: UIPickerView!
  @IBOutlet weak var takeUpSlack: UIButton!
  private var shouldTakeUpSlack: Bool!
  private var digits = [[0, 1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]]
  private var setToHundred: Bool!
  private var onesDigit: Int!
  private var tensDigit: Int!
  
  
  func loadData(shouldTakeUpSlack: Bool)
  {
    let lender = iOUData.sharedInstance.temporaryData.dynamicEditContractor
    lenderName.text = lender.key
    
    //Initialize percentage picker.
    percentage.delegate = self
    percentage.dataSource = self
    
    let monetaryValue = Int(iOUData.sharedInstance.temporaryData.contract.monetaryValue)
    let hundredsDigit = (monetaryValue / 100) * 100
    tensDigit = (monetaryValue / 10) * 10 - hundredsDigit
    onesDigit = monetaryValue - hundredsDigit - tensDigit
    
    percentage.selectRow(hundredsDigit, inComponent: 0, animated: false)
    percentage.selectRow(tensDigit, inComponent: 1, animated: false)
    percentage.selectRow(onesDigit, inComponent: 2, animated: false)
    
    if (hundredsDigit > 0)
    {
      setToHundred = false
    }
    else
    {
      setToHundred = true
    }
    
    //Initialize takeUpSlack button image.
    self.shouldTakeUpSlack = shouldTakeUpSlack
    
    if (shouldTakeUpSlack)
    {
      takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button On")
    }
    else
    {
      takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button Off")
    }
  }
  
  @IBAction func toggleSlack(button: UIButton)
  {
    shouldTakeUpSlack = !shouldTakeUpSlack
    
    if (shouldTakeUpSlack!)
    {
      takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button On")
      iOUData.sharedInstance.temporaryData.takeUpSlackRow = iOUData.sharedInstance.temporaryData.dynamicEdit.cell.row
    }
    else
    {
      takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button Off")
      iOUData.sharedInstance.temporaryData.takeUpSlackRow = 0
    }
    
    iOULogic.refreshViews()
  }
  
  @IBAction func changeLenderName(sender: UITextField)
  {
    //Whenever the user changes the lender's name, update lender.
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.key = lenderName.text
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
  {
    return digits.count
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return digits[component].count
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    let hundredsDigit = percentage.selectedRowInComponent(0)
    var monetaryValue: Double
    
    if (hundredsDigit > 0)
    {
      if (setToHundred!)
      {
        tensDigit = percentage.selectedRowInComponent(1)
        onesDigit = percentage.selectedRowInComponent(2)
        percentage.selectRow(0, inComponent: 1, animated: true)
        percentage.selectRow(0, inComponent: 2, animated: true)
        monetaryValue = Double(100)
        setToHundred = false
      }
      else
      {
        percentage.selectRow(0, inComponent: 0, animated: true)
        tensDigit = percentage.selectedRowInComponent(1)
        onesDigit = percentage.selectedRowInComponent(2)
        monetaryValue = Double(tensDigit * 10) + Double(onesDigit)
        setToHundred = true
      }
    }
    else
    {
      if (setToHundred!)
      {
        tensDigit = percentage.selectedRowInComponent(1)
        onesDigit = percentage.selectedRowInComponent(2)
      }
      else
      {
        percentage.selectRow(0, inComponent: 0, animated: true)
        percentage.selectRow(tensDigit, inComponent: 1, animated: true)
        percentage.selectRow(onesDigit, inComponent: 2, animated: true)
        setToHundred = true
      }
      
      monetaryValue = Double(tensDigit * 10) + Double(onesDigit)
    }
    
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.value = monetaryValue
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
