//
//  EditAlertRepeatCell.swift
//  iOU
//
//  Created by Tateni Urio on 5/11/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditAlertRepeatCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, PickerCell
{
  @IBOutlet weak var repeatPattern: UIButton!
  @IBOutlet weak var repeatRate: UIButton!
  @IBOutlet weak var repeatType: UISegmentedControl!
  internal weak var pickerPreLabel: UILabel!
  internal weak var pickerPostLabel: UILabel!
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var pickerWidthConstraint: NSLayoutConstraint!
  
  
  @IBAction func changeRepeatType(sender: UISegmentedControl)
  {
    EditContractLogic.changeRepeatType(sender)
  }
  
  @IBAction func editRepeatPattern(sender: UIButton)
  {
    EditContractLogic.editRepeatPattern()
  }
  
  @IBAction func editRepeatRate(sender: UIButton)
  {
    EditContractLogic.editRepeatRate()
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> (Int)
  {
    return EditContractLogic.pickerCellComponentCount()
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> (Int)
  {
    return EditContractLogic.pickerCell(rowCountForComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> (String?)
  {
    return EditContractLogic.pickerCell(titleForRow: row, inComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    EditContractLogic.pickerCell(didSelectRow: row, inComponent: component, fromPicker: self)
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
