//
//  LenderCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/7/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class LenderCell: UITableViewCell, MonetaryValueAdjustableWidth
{
  @IBOutlet weak var lenderName: UILabel!
  @IBOutlet weak var monetaryValue: UILabel!
  @IBOutlet weak var takeUpSlack: UIButton!
  @IBOutlet var monetaryValueWidthConstraint: NSLayoutConstraint!
  private var shouldTakeUpSlack: Bool!
  
  
  func loadData(#lenderName: String, lenderValue: Double, shouldTakeUpSlack: Bool)
  {
    self.lenderName.text = lenderName
    let currency = iOUData.sharedInstance.currency.rawValue
    let lenderShares = iOUData.sharedInstance.temporaryData.contract.lenderShares
    
    if (lenderShares == Shares.Fixed)
    {
      monetaryValue.text = String(format: currency + " %.2f", lenderValue)
    }
    else
    {
      monetaryValue.text = "\(Int(lenderValue))%"
    }
    
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
