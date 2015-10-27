//
//  EditContractorPercentageCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorPercentageCell: EditContractorCell, UIPickerViewDelegate, UIPickerViewDataSource, EditPercentagesCell
{
  @IBOutlet weak var monetaryLabel: UILabel!
  @IBOutlet weak var pickerPreLabel: UILabel!
  @IBOutlet weak var pickerPostLabel: UILabel!
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var pickerWidthConstraint: NSLayoutConstraint!
  internal var saved: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  internal var current: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!)
  
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> (Int)
  {
    return EditContractLogic.pickerCellComponentCount()
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> (Int)
  {
    return EditContractLogic.pickerCell(rowCountForComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> (String!)
  {
    return EditContractLogic.pickerCell(titleForRow: row, inComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    EditContractLogic.pickerCell(didSelectRow: row, inComponent: component, fromPicker: self)
  }
}
