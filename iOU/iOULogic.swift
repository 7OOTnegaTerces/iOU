//
//  iOULogic.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import Foundation
import UIKit

class iOULogic
{
  class func segueToMainInterface(sender: UIViewController, save: Bool)
  {
    if (save)
    {
      //TODO - Finish Save condition.
      println("TODO - Finish Save condition.")
    }
    
    //Reset New Contract variables
    iOUData.sharedInstance.resetNewContractData()
    
    switch sender
    {
      case is NewContractMoneyController:
        sender.performSegueWithIdentifier("NewContractMoney->MainInterface", sender: sender)
      case is NewContractItemController:
        sender.performSegueWithIdentifier("NewContractItem->MainInterface", sender: sender)
      case is NewContractServiceController:
        sender.performSegueWithIdentifier("NewContractService->MainInterface", sender: sender)
      default:
        println("Error: unknown sender \(sender) atempting to segue to Main Interface")
    }
  }
  
  class func segueToNewContractTitle(sender: MainInterfaceController)
  {
    iOUData.sharedInstance.temporaryData = []
    iOUData.sharedInstance.temporaryData.append("NewContractTitle FirstTime")
    iOUData.sharedInstance.temporaryData.append("")
    
    //If the user was viewing the Starred contract list when they touched the new contract button, set the contract type and this view's segmented control to the most popular contract type (the type with the most stars).  Otherwise, set the new contract type and this view's segmented control to the type of contract the user was viewing when they hit the new contract button.
    if (iOUData.sharedInstance.listType == Type.Starred)
    {
      iOUData.sharedInstance.temporaryData.append(iOUData.sharedInstance.mostPopularContractType())
    }
    else
    {
      iOUData.sharedInstance.temporaryData.append(iOUData.sharedInstance.listType)
    }
    
    sender.performSegueWithIdentifier("MainInterface->NewContractTitle", sender: sender)
  }
  
  class func newContractInputSegue(sender: UIViewController, save: Bool)
  {
    //iOUData.sharedInstance.temporaryData[0] should contain the name of the last New Contract Input view segued to, and thus the one currently being segued from.
    if let segueFrom = iOUData.sharedInstance.temporaryData[0] as? String
    {
      if (save)
      {
        switch segueFrom
        {
          case "NewContractTitle FirstTime", "NewContractTitle":
            var title = iOUData.sharedInstance.temporaryData[1] as String
            
            if (title == "")
            {
              iOUData.sharedInstance.newContractTitle = "Monetary iOU"
            }
            else
            {
              iOUData.sharedInstance.newContractTitle = title
            }
            
            iOUData.sharedInstance.newContractType = iOUData.sharedInstance.temporaryData[2] as Type
          case "NewContractMonetaryValue":
            iOUData.sharedInstance.newContractMonetaryValue = iOUData.sharedInstance.temporaryData[1] as Float
          default:
            println("Error: \(segueFrom) is not a valid New Contract Input view.")
        }
      }
      
      //If the user just reuqested a new contract, only to change their mind and hit cancel, forget about the new contract and return to the Main Interface view.  Otherwise, procede to the relevent New Contract From view.
      let type = iOUData.sharedInstance.newContractType.toString()
      
      if (segueFrom == "NewContractTitle FirstTime")
      {
        if (save)
        {
          sender.performSegueWithIdentifier("NewContractTitle->NewContract\(type)", sender: sender)
        }
        else
        {
          sender.performSegueWithIdentifier("NewContractTitle->MainInterface", sender: sender)
        }
      }
      else
      {
        //Segue to appropriate new contract form using iOUData.sharedInstance.newContractType to determine which form to segue to.
        if (iOUData.sharedInstance.newContractType == Type.Starred)
        {
          println("Error: iOUData.sharedInstance.newContractType set to Type.Starred")
        }
        else
        {
          let segueTo = segueFrom + "->NewContract" + type
          sender.performSegueWithIdentifier(segueTo, sender: sender)
        }
      }
    }
    else
    {
      println("Error: iOUData.sharedInstance.temporaryData[0] does not contain the name of the view last segued to. \(iOUData.sharedInstance.temporaryData[0])")
    }
  }
  
  class func newContractMoneyRowSegue(sender: UITableViewController, indexPath: NSIndexPath)
  {
    iOUData.sharedInstance.temporaryData = []
    var segueTo: String = ""
    
    switch indexPath.section
    {
      case 0:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContractTitle"
            iOUData.sharedInstance.temporaryData.append(segueTo)
            let title = iOUData.sharedInstance.newContractTitle
            iOUData.sharedInstance.temporaryData.append(title)
            iOUData.sharedInstance.temporaryData.append(Type.Money)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Money's form.")
        }
      case 1:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContractMonetaryValue"
            iOUData.sharedInstance.temporaryData.append(segueTo)
            let monetaryValue = iOUData.sharedInstance.newContractMonetaryValue
            iOUData.sharedInstance.temporaryData.append(monetaryValue)
          case 1:
            segueTo = "NewContractLenders"
            iOUData.sharedInstance.temporaryData.append(segueTo)
            let lenders = iOUData.sharedInstance.newContractLenders
            iOUData.sharedInstance.temporaryData.append(lenders)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Money's form.")
        }
      case 2:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Money's form.")
        }
      default:
        println("Error: there are not \(indexPath.section) sections in New Contract Money's form.")
    }
    
    let segueIdentifier = "NewContractMoney->" + segueTo
    sender.performSegueWithIdentifier(segueIdentifier, sender: sender)
  }
  
  class func newContractItemRowSegue(sender: UITableViewController, indexPath: NSIndexPath)
  {
    iOUData.sharedInstance.temporaryData = []
    var segueTo: String = ""
    
    switch indexPath.section
    {
      case 0:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContractTitle"
            iOUData.sharedInstance.temporaryData.append(segueTo)
            let title = iOUData.sharedInstance.newContractTitle
            iOUData.sharedInstance.temporaryData.append(title)
            iOUData.sharedInstance.temporaryData.append(Type.Item)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      case 1:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      case 2:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      default:
        println("Error: there are not \(indexPath.section) sections in New Contract Item's form.")
    }
    
    let segueIdentifier = "NewContractItem->" + segueTo
    sender.performSegueWithIdentifier(segueIdentifier, sender: sender)
  }
  
  class func newContractServiceRowSegue(sender: UITableViewController, indexPath: NSIndexPath)
  {
    iOUData.sharedInstance.temporaryData = []
    var segueTo: String = ""
    
    switch indexPath.section
    {
      case 0:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContractTitle"
            iOUData.sharedInstance.temporaryData.append(segueTo)
            let title = iOUData.sharedInstance.newContractTitle
            iOUData.sharedInstance.temporaryData.append(title)
            iOUData.sharedInstance.temporaryData.append(Type.Service)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      case 1:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      case 2:
        switch indexPath.row
        {
          case 0:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 1:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          case 2:
            segueTo = "NewContract"
            iOUData.sharedInstance.temporaryData.append(segueTo)
          default:
            println("Error: there are not \(indexPath.row) rows in \(indexPath.section) in New Contract Item's form.")
        }
      default:
        println("Error: there are not \(indexPath.section) sections in New Contract Item's form.")
    }
    
    let segueIdentifier = "NewContractService->" + segueTo
    sender.performSegueWithIdentifier(segueIdentifier, sender: sender)
  }
}