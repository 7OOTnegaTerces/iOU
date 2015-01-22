//
//  EditContractorNameAndValueCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/4/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractorNameAndValueCell: UITableViewCell, MonetaryValue, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var contractorName: UITextField!
  @IBOutlet weak var monetaryValue: UITextField!
  @IBOutlet weak var takeUpSlack: UIButton!
  @IBOutlet weak var monetaryValueWidthConstraint: NSLayoutConstraint!
  internal var shouldTakeUpSlack: Bool!
  
  
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
  
  @IBAction func updateContractorName(sender: UITextField)
  {
    //Whenever the user changes the Contractor's name, update Contractor.
    iOUData.sharedInstance.temporaryData.dynamicEditContractor.key = contractorName.text
  }
  
  @IBAction func updateMonetaryPercentage(sender: UITextField)
  {
    iOULogic.updateMonetaryValueText(sender: self, includeDecimal: true)
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
