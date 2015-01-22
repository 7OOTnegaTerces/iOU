//
//  EditTipPercentageCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/15/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditTipPercentageCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, PercentagePicker
{
  @IBOutlet weak var percentage: UIPickerView!
  @IBOutlet weak var tipSwitch: UISwitch!
  internal var saved: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  internal var current: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  
  
  @IBAction func toggleTip(sender: UISwitch)
  {
    if (iOULogic.saveDynamicChanges())
    {
      sender.setOn(!sender.on, animated: true)
      return
    }
    
    iOUData.sharedInstance.temporaryData.includeTip = sender.on
    iOULogic.resetDynamicEditing()
    iOULogic.refreshViews()
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
    let tip = iOULogic.updateLoopedPercentagePicker(picker: self, didSelectRow: row, inComponent: component, percentageCap: -1)
    iOUData.sharedInstance.temporaryData.tip = tip
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
