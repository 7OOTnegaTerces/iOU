//
//  ContractorCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/7/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ContractorCell: UITableViewCell, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var contractorName: UILabel!
  @IBOutlet weak var monetaryValue: UILabel!
  @IBOutlet weak var takeUpSlack: UIButton!
  @IBOutlet var monetaryValueWidthConstraint: NSLayoutConstraint!
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
