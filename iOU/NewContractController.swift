//
//  NewContractController.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractController: UITableViewController, UITableViewDelegate, UITableViewDataSource, Segueable, Refreshable
{
  @IBOutlet weak var newContractTitle: UILabel!
  @IBOutlet weak var newContractType: UILabel!
  @IBOutlet weak var newContractValue: UILabel!
  @IBOutlet weak var tipPercentage: UILabel!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView:",name:"Refresh", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView:",name:"RefreshNewContractOnly", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contractorNameWarning",name:"ContractorNameWarning", object: nil)
    
    //Register Table.
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    //Initialzie the Table.
    var nib = UINib(nibName: "EditMonetaryValueCell", bundle: nil)
    self.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueCell")
    nib = UINib(nibName: "EditMonetaryValueWithCalculatorCell", bundle: nil)
    self.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueWithCalculatorCell")
    nib = UINib(nibName: "EditTitleCell", bundle: nil)
    self.tableView.registerNib(nib, forCellReuseIdentifier: "EditTitleCell")
    nib = UINib(nibName: "EditTipPercentageCell", bundle: nil)
    self.tableView.registerNib(nib, forCellReuseIdentifier: "EditTipPercentageCell")
    reloadData()
  }
  
  func reloadData()
  {
    newContractTitle.text = iOUData.sharedInstance.temporaryData.contract.title
    newContractType.text = iOUData.sharedInstance.temporaryData.contract.type.toString()
    let currency = iOUData.sharedInstance.currency.rawValue
    var monetaryValue = iOUData.sharedInstance.temporaryData.contract.monetaryValue
    var tip = Double(iOUData.sharedInstance.temporaryData.tip)
    tipPercentage.text = String(Int(tip)) + "%"
    
    if (iOUData.sharedInstance.temporaryData.includeTip)
    {
      tip /= 100
      monetaryValue = monetaryValue * Double(1 + tip)
    }
    
    newContractValue.text = String(format: "\(currency) %.2f", monetaryValue)
  }
  
  func refreshView(notification: NSNotification)
  {
    reloadData()
    tableView.reloadData()
  }
  
  @IBAction func doneActivated(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(sender: self, save: true)
  }
  
  @IBAction func cancelActivated(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(sender: self, save: false)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    var count: Int
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        count = iOULogic.newContractMoneyRowCount(section)
      case Type.Item:
        count = iOULogic.newContractItemRowCount(section)
      case Type.Service:
        count = iOULogic.newContractServiceRowCount(section)
    }
    
    return count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> (CGFloat)
  {
    return iOULogic.newContractMoneyRowHeight(indexPath)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    var cell: UITableViewCell?
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        cell = iOULogic.newContractMoneyCell(tableView: tableView, indexPath: indexPath)
      case Type.Item:
        cell = iOULogic.newContractItemCell(tableView: tableView, indexPath: indexPath)
      case Type.Service:
        cell = iOULogic.newContractServiceCell(tableView: tableView, indexPath: indexPath)
    }
    
    if (cell == nil)
    {
      cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    return cell!
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        iOULogic.newContractMoneyRowSelection(indexPath)
      case Type.Item:
        iOULogic.newContractItemRowSelection(indexPath)
      case Type.Service:
        iOULogic.newContractServiceRowSelection(indexPath)
    }
  }
  
  func contractorNameWarning()
  {
    performSegue(segueFrom: "NewContract", segueTo: "ContractorNameWarning")
  }
  
  func performSegue(#segueFrom: String, segueTo: String)
  {
    performSegueWithIdentifier(segueFrom + "->" + segueTo, sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
