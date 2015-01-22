//
//  EditContractorNameAndPercentageCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorNameAndPercentageCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, PercentagePicker
{
  @IBOutlet weak var contractorName: UITextField!
  @IBOutlet weak var percentage: UIPickerView!
  @IBOutlet weak var takeUpSlack: UIButton!
  internal var shouldTakeUpSlack: Bool!
  internal var saved: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  internal var current: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  
  
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
  
  @IBAction func changeContractorName(sender: UITextField)
  {
    //Whenever the user changes the Contractor's name, update Contractor.
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.key = contractorName.text
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> (Int)
  {
    return iOUData.sharedInstance.digits.count
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> (Int)
  {
    let loopRadius = iOUData.sharedInstance.loopRadius
    let loop = loopRadius * 2 + 1
    return iOUData.sharedInstance.digits[component].count * loop
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> (String!)
  {
    let data = iOUData.sharedInstance.digits
    return iOULogic.loopedPickerRowTitle(sourceData: data, titleForRow: row, forComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    let id = iOUData.sharedInstance.temporaryData.dynamicEdit.id
    var ContractorPercentageUnused: Int
    
    if (id == "Lender")
    {
      ContractorPercentageUnused = 100 - iOUData.sharedInstance.totalLenderPercentageUsed()
    }
    else
    {
      ContractorPercentageUnused = 100 - iOUData.sharedInstance.totalBorrowerPercentageUsed()
    }
    
    let monetaryPercentage = iOULogic.updateLoopedPercentagePicker(picker: self, didSelectRow: row, inComponent: component, percentageCap: ContractorPercentageUnused)
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.value = Double(monetaryPercentage)
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
