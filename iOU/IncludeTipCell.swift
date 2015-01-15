//
//  IncludeTipCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/9/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class IncludeTipCell: UITableViewCell
{
  @IBOutlet weak var tipPercentage: UILabel!
  
  
  func loadData()
  {
    let tip = iOUData.sharedInstance.temporaryData.tip
    tipPercentage.text = String(tip)
  }
  
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
