//
//  ContractorTableCell.swift
//  iOU
//
//  Created by Tateni Urio on 1/13/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ContractorTableCell: UITableViewCell, Refreshable
{
  private var contractorList: SortableDictionary<String, Double>!
  
  
  func loadData(contractors: SortableDictionary<String, Double>)
  {
    contractorList = contractors
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView:",name:"refresh", object: nil)
  }
  
  func reloadData()
  {
    //TODO - Finish?
  }
  
  func refreshView(notification: NSNotification)
  {
    reloadData()
    sizeToFit()
  }
  
  override func sizeThatFits(size: CGSize) -> CGSize
  {
    let currentSize = super.sizeThatFits(size)
    let width = currentSize.width
    var height = CGFloat(72)
    height += CGFloat(contractorList.count * 44)
    return CGSizeMake(width, height)
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
