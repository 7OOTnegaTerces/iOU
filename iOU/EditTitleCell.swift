//
//  EditTitleCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/14/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class EditTitleCell: UITableViewCell
{
  @IBOutlet weak var contractTitle: UITextField!
  @IBOutlet weak var contractType: UISegmentedControl!
  
  
  @IBAction func changeTitle(sender: UITextField)
  {
    //Whenever the user changes the iOU contract's title, update it.
    iOUData.sharedInstance.temporaryData.contract.title = contractTitle.text
  }
  
  @IBAction func changeType(sender: UISegmentedControl)
  {
    //TODO - Finish!!!
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
