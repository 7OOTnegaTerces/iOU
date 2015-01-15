//
//  EditLenderNameAndValueCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditLenderNameAndValueCell: UITableViewCell, MonetaryValue, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var lenderName: UITextField!
  @IBOutlet weak var monetaryValue: UITextField!
  @IBOutlet weak var takeUpSlack: UIButton!
  @IBOutlet weak var monetaryValueWidthConstraint: NSLayoutConstraint!
  private var shouldTakeUpSlack: Bool!
  
  
  func loadData(shouldTakeUpSlack: Bool)
  {
    let lender = iOUData.sharedInstance.temporaryData.dynamicEditContractor
    lenderName.text = lender.key
    monetaryValue.text = String(format: "%.2f", lender.value)
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
  
  @IBAction func changeMonetaryPercentage(sender: UITextField)
  {
    iOULogic.changeMonetaryValueText(sender: self, includeDecimal: true)
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
