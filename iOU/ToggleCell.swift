//
//  ToggleCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/15/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ToggleCell: UITableViewCell, SwitchCell
{
  @IBOutlet weak var switchLabel: UILabel!
  @IBOutlet weak var toggle: UISwitch!
  var toggleID: String
  {
    get
    {
      return id
    }
    set
    {
      if (id == nil)
      {
        id = newValue
      }
    }
  }
  private var id: String!
  
  @IBAction func flipToggle(sender: UISwitch)
  {
    EditContractLogic.flipToggle(toggle: sender, toggleID: toggleID)
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
