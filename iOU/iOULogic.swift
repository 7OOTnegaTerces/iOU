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
  class var data: iOUData
  {
    get
    {
      return iOUData.sharedInstance
    }
  }
  class var temporaryData: TemporaryData
  {
    get
    {
      return data.temporaryData
    }
    set
    {
      data.temporaryData = newValue
    }
  }
  class var temporaryContract: Contract
  {
    get
    {
      return temporaryData.contract
    }
    set
    {
      temporaryData.contract = newValue
    }
  }
  class var newContract: Contract
  {
    get
    {
      return data.newContract
    }
    set
    {
      data.newContract = newValue
    }
  }
  
  
  //MARK: - New Contract Controller Logic
  class func segueToNewContract(sender: MainInterfaceController)
  {
    data.resetNewContractData()
    
    //If the user was viewing the Starred contract list when they touched the new contract button, set the contract type and this view's segmented control to the most popular contract type (the type with the most stars).  Otherwise, set the new contract type and this view's segmented control to the type of contract the user was viewing when they hit the new contract button.
    var type: Type
    
    if (data.listType == ListType.Starred)
    {
      type = data.mostPopularContractType()
    }
    else
    {
      type = data.listType.convert()
    }
    
    temporaryContract.type = type
    temporaryContract.title = "Title (" + type.toAlternateString() + " iOU)"
    newContract.overWrite(temporaryContract)
    
    sender.performSegue(segueFrom: "MainInterface", segueTo: "NewContract")
  }
  
  class func newContractEdited(#sender: NewContractController, save: Bool)
  {
    //This function controls what happens when the user clicks done or cancel when creating a new iOU contract.
    
    //First, either save the current temporary contract data (temporaryContract) to the new contract being formed (newContract), or not.  Also fill in those fields that need a default value so they're not blank.
    if (save) //If/else save block.
    {
      
      //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
      if (saveDynamicChanges())
      {
        return
      }
      
      newContract.overWrite(temporaryContract)
      
      //If not dynamically editing, include tip in monetaryValue now that the contract is finished, then save the new contract to the appropriate list.
      if (!temporaryData.dynamicallyEditing)
      {
        var monetaryValue = newContract.monetaryValue
        
        //If including a tip, add it to the final monetary value now.
        if (temporaryData.includeTip)
        {
          var tip = Double(temporaryData.tip)
          tip /= 100
          monetaryValue *= 1 + tip
          newContract.monetaryValue = monetaryValue
        }
        
        //If using equal shares, change the monetary value of each lender/borrower.
        if (newContract.lenderShares == Shares.Equal)
        {
          let lenderCount = newContract.lenders.count
          let splitEqually = monetaryValue / Double(lenderCount)
          
          for i in 0..<lenderCount
          {
            newContract.lenders.update(overwriteValueAtIndex: i, withNewValue: splitEqually)
          }
        }
        
        if (newContract.borrowerShares == Shares.Equal)
        {
          let borrowerCount = newContract.borrowers.count
          let splitEqually = monetaryValue / Double(borrowerCount)
          
          for i in 0..<borrowerCount
          {
            newContract.borrowers.update(overwriteValueAtIndex: i, withNewValue: splitEqually)
          }
        }
        
        switch newContract.type
        {
          case Type.Money:
            data.moneyContracts.append(newContract)
          case Type.Item:
            data.itemContracts.append(newContract)
          case Type.Service:
            data.serviceContracts.append(newContract)
        }
      }
    }
    else
    {
      temporaryContract.overWrite(newContract)
    }
    
    if (temporaryData.dynamicallyEditing)
    {
      //If dynamic cell editing was taking place, end it and reload the table to update the changes.
      resetDynamicEditing()
      iOULogic.refreshViews()
    }
    else
    {
      //Return to the Main Interface
      data.resetNewContractData()
      sender.performSegue(segueFrom: "NewContract", segueTo: "MainInterface")
    }
  }
  
  //MARK: New Money Contract Logic
  class func newContractMoneyRowCount(section: Int) -> (Int)
  {
    var count: Int
    
    switch section
    {
      case 0:
        count = 1
      case 1:
        count = 2
      case 2:
        if (temporaryData.displayLenders)
        {
          count = 2
        }
        else
        {
          count = 1
        }
      default:
        count = 0
    }
    
    return count
  }
  
  class func newContractMoneyRowHeight(indexPath: NSIndexPath) -> (CGFloat)
  {
    let location = (section: indexPath.section, row: indexPath.row)
    var height: CGFloat?
    
    switch location
    {
      case (0, 0):
        if (temporaryData.dynamicEdit.id == "Title")
        {
          height = 82
        }
      case (1, 0):
        if (temporaryData.dynamicEdit.id == "MonetaryValue" && temporaryData.displayCalculator)
        {
          height = 82
        }
      case (2, 1):
        height = 72 + CGFloat(temporaryContract.lenders.count * 44)
      default:
        break
    }
    
    if (height == nil)
    {
      height = 44
    }
    
    return height!
  }
  
  class func newContractMoneyCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    var cell: UITableViewCell?
    
    let dynamicEditCell = temporaryData.dynamicEdit.cell
    
    if (indexPath == dynamicEditCell)
    {
      switch indexPath.section
      {
        case 0:
          var tempCell = tableView.dequeueReusableCellWithIdentifier("EditTitleCell") as EditTitleCell
          tempCell.contractTitle.text = temporaryContract.title
          tempCell.contractType.selectedSegmentIndex = temporaryContract.type.rawValue
          cell = tempCell
        case 1:
          if (indexPath.row == 0)
          {
            if (temporaryData.displayCalculator)
            {
              var tempCell = tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueWithCalculatorCell") as EditMonetaryValueWithCalculatorCell
              let currency = data.currency.rawValue
              tempCell.contractCurrency.setTitle(currency, forState: UIControlState.Normal)
              let monetaryValue = temporaryContract.monetaryValue
              tempCell.monetaryValue.text = String(format: "%.2f", monetaryValue)
              cell = tempCell
            }
            else
            {
              var tempCell = tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueCell") as EditMonetaryValueCell
              let currency = data.currency.rawValue
              tempCell.contractCurrency.setTitle(currency, forState: UIControlState.Normal)
              let monetaryValue = iOUData.sharedInstance.temporaryData.contract.monetaryValue
              tempCell.monetaryValue.text = String(format: "%.2f", monetaryValue)
              cell = tempCell
            }
          }
          else
          {
            var tempCell = tableView.dequeueReusableCellWithIdentifier("EditTipPercentageCell") as EditTipPercentageCell
            //Initialize percentage picker.
            tempCell.percentage.delegate = tempCell
            tempCell.percentage.dataSource = tempCell
            
            let tip = temporaryData.tip
            tempCell.current.hundredsDigit = tip[2]
            tempCell.current.tensDigit = tip[1]
            tempCell.current.onesDigit = tip[0]
            
            tempCell.saved.hundredsDigit = tempCell.current.hundredsDigit
            tempCell.saved.tensDigit = tempCell.current.tensDigit
            tempCell.saved.onesDigit = tempCell.current.onesDigit
            
            let hundredsRow = tempCell.current.hundredsDigit + data.digits[0].count * data.loopRadius
            let tensRow = tempCell.current.tensDigit + data.digits[1].count * data.loopRadius
            let onesRow = tempCell.current.onesDigit + data.digits[2].count * data.loopRadius
            
            tempCell.percentage.selectRow(hundredsRow, inComponent: 0, animated: false)
            tempCell.percentage.selectRow(tensRow, inComponent: 1, animated: false)
            tempCell.percentage.selectRow(onesRow, inComponent: 2, animated: false)
            
            if (temporaryData.includeTip)
            {
              tempCell.tipSwitch.on = true
            }
            else
            {
              tempCell.tipSwitch.on = false
            }
            cell = tempCell
          }
        default:
          break
      }
    }
  
    return cell
  }
  
  class func newContractMoneyRowSelection(indexPath: NSIndexPath)
  {
    //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
    if (saveDynamicChanges())
    {
      return
    }
    resetDynamicEditing()
    
    let type = newContract.type.toString()
    
    switch indexPath.section
    {
      case 0:
        switch indexPath.row
        {
          case 0:
            temporaryData.dynamicEdit.id = "Title"
            temporaryData.dynamicEdit.cell = indexPath
            temporaryData.dynamicallyEditing = true
           default:
            fatalError("there is only 1 row, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
        }
      case 1:
        switch indexPath.row
        {
          case 0:
            temporaryData.dynamicEdit.id = "MonetaryValue"
            temporaryData.dynamicEdit.cell = indexPath
            temporaryData.dynamicallyEditing = true
          case 1:
            temporaryData.dynamicEdit.id = "TipPercentage"
            temporaryData.dynamicEdit.cell = indexPath
            temporaryData.dynamicallyEditing = true
          default:
            fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
        }
      case 2:
        switch indexPath.row
        {
          case 0:
            //If displaing the lenders, update temporary and new contract and stop displaying lenders.  Otherwise update contracteeTemporary and start displaying lenders.
            if (temporaryData.displayLenders)
            {
              newContract.lenders = temporaryContract.lenders
              temporaryData.displayLenders = false
            }
            else
            {
              temporaryData.displayLenders = true
            }
          default:
            fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
        }
      default:
        fatalError("there are only 3 sections, not \(indexPath.section), in New Contract \(type)'s form.")
    }
    
    iOULogic.refreshViews()
  }
  
  //MARK: New Item Contract Logic
  class func newContractItemRowCount(section: Int) -> (Int)
  {
    return 0
  }
  
  class func newContractItemRowHeight(indexPath: NSIndexPath) -> (CGFloat)
  {
    return CGFloat()
  }
  
  class func newContractItemCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractItemRowSelection(indexPath: NSIndexPath)
  {
    let type = newContract.type.toString()
    
    switch indexPath.section
    {
    case 0:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    case 1:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    case 2:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    default:
      fatalError("there are only 3 sections, not \(indexPath.section), in New Contract \(type)'s form.")
    }
    
    temporaryContract.overWrite(newContract)
    iOULogic.refreshViews()
  }
  
  //MARK: New Service Contract Logic
  class func newContractServiceRowCount(section: Int) -> (Int)
  {
    return 0
  }
  
  class func newContractServiceRowHeight(indexPath: NSIndexPath) -> (CGFloat)
  {
    return CGFloat()
  }
  
  class func newContractServiceCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractServiceRowSelection(indexPath: NSIndexPath)
  {
    let type = newContract.type.toString()
    
    switch indexPath.section
    {
    case 0:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    case 1:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    case 2:
      switch indexPath.row
      {
        case 0:
          break
        case 1:
          break
        case 2:
          break
        default:
          fatalError("there are only 3 rows, not \(indexPath.row), in section \(indexPath.section) in New Contract \(type)'s form.")
      }
    default:
      fatalError("there are only 3 sections, not \(indexPath.section), in New Contract \(type)'s form.")
    }
    
    temporaryContract.overWrite(newContract)
    iOULogic.refreshViews()
  }
  
  //MARK: New Contract Lender Logic
  class func newContractorsCell(#tableView: UITableView, indexPath: NSIndexPath, contractorType: String) -> (UITableViewCell)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in the New Contract " + contractorType + "'s table.")
    }
    
    var cell: UITableViewCell
    
    if (indexPath.row == 0)
    {
      cell = tableView.dequeueReusableCellWithIdentifier("NewContractorCell") as UITableViewCell
    }
    else
    {
      let dynamicEditID = temporaryData.dynamicEdit.id
      var dynamicEditCell: NSIndexPath
      var contractor: (key: String, value: (parts: Int, percent: Int, fixed: Double))
      
      //First, check if the contractor type being dynamically edited is the same as the contrator cell type being requested here.  If it is, set the dynamicEditCell and contractor.  If not, set dynamicEditCell to zero and get set contractor from the appropriate contractor's list.
      if (dynamicEditID == contractorType)
      {
        dynamicEditCell = temporaryData.dynamicEdit.cell
      }
      else
      {
        dynamicEditCell = NSIndexPath(forRow: 0, inSection: 0)
      }
      
      if (contractorType == "Lender")
      {
        contractor = temporaryData.lendersTemporary[indexPath.row - 1]
      }
      else
      {
        contractor = temporaryData.borrowersTemporary[indexPath.row - 1]
      }
      
      //If using equal shares, change the monetary value displayed. (The actual monetary value of each lender can be changed when saving the final contract.)
      var splitEqually = Double(0)
      
      if (temporaryContract.lenderShares == Shares.Equal)
      {
        var monetaryValue = temporaryContract.monetaryValue
        
        if (temporaryData.includeTip)
        {
          var tip = Double(temporaryData.tip)
          tip /= 100
          monetaryValue *= 1 + tip
        }
        
        let contractors = temporaryContract.lenders.count
        splitEqually = monetaryValue / Double(contractors)
      }
      
      //To determine if this is the cell containing the lender marked as the designated "Slack Taker" (takes up any excess unconvered debt above their own value, if any), compare this row against temporaryData.takeUpSlackRow.
      let shouldTakeUpSlack = (indexPath.row == temporaryData.takeUpSlackRow)
      
      if (indexPath == dynamicEditCell)
      {
        temporaryData.dynamicEditContractor = contractor
        
        switch temporaryContract.lenderShares
        {
          case Shares.Equal:
            let tempCell = tableView.dequeueReusableCellWithIdentifier("EditContractorNameCell") as EditContractorNameCell
            let contractor = temporaryData.dynamicEditContractor
            tempCell.contractorName.text = contractor.key
            tempCell.monetaryValue.text = String(format: "%.2f", splitEqually)
            cell = tempCell
          case Shares.Parts:
            let tempCell = tableView.dequeueReusableCellWithIdentifier("EditContractorNameAndValueCell") as EditContractorNameAndValueCell
            tempCell.contractorName.text = contractor.key
            
            //If this cell is a lender or a borrower with fixed value shares, set includeDecimal to true and format monetaryValue.text approiately.
            let id = temporaryData.dynamicEdit.id
            let lenderShares = temporaryContract.lenderShares
            let borrowerShares = temporaryContract.borrowerShares
            
            if ((id == "Lender" && lenderShares == Shares.Fixed) || (id == "Borrower" && borrowerShares == Shares.Fixed))
            {
              tempCell.monetaryValue.text = String(format: "%.2f", contractor.value)
              tempCell.includeDecimal = true
            }
            else
            {
              tempCell.monetaryValue.text = String(Int(contractor.value))
              tempCell.includeDecimal = false
            }
            cell = tempCell
          case Shares.Percentage:
            let tempCell = tableView.dequeueReusableCellWithIdentifier("EditLenderNameAndValuePercentageCell") as EditLenderNameAndValuePercentageCell
            let lender = iOUData.sharedInstance.temporaryData.dynamicEditContractor
            tempCell.lenderName.text = lender.key
            
            //Initialize percentage picker.
            tempCell.percentage.delegate = tempCell
            tempCell.percentage.dataSource = tempCell
            
            let monetaryPercentage = Int(lender.value)
            tempCell.current.hundredsDigit = monetaryPercentage[2]
            tempCell.current.tensDigit = monetaryPercentage[1]
            tempCell.current.onesDigit = monetaryPercentage[0]
            
            tempCell.saved.hundredsDigit = tempCell.current.hundredsDigit
            tempCell.saved.tensDigit = tempCell.current.tensDigit
            tempCell.saved.onesDigit = tempCell.current.onesDigit
            
            let hundredsRow = tempCell.current.hundredsDigit + data.digits[0].count * data.loopRadius
            let tensRow = tempCell.current.tensDigit + data.digits[1].count * data.loopRadius
            let onesRow = tempCell.current.onesDigit + data.digits[2].count * data.loopRadius
            
           tempCell.percentage.selectRow(hundredsRow, inComponent: 0, animated: false)
            tempCell.percentage.selectRow(tensRow, inComponent: 1, animated: false)
            tempCell.percentage.selectRow(onesRow, inComponent: 2, animated: false)
            
            //Initialize takeUpSlack button image.
            tempCell.shouldTakeUpSlack = shouldTakeUpSlack
            
            if (shouldTakeUpSlack)
            {
              tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button On")
            }
            else
            {
              tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button Off")
            }
            cell = tempCell
          case Shares.Fixed:
            let tempCell = tableView.dequeueReusableCellWithIdentifier("EditLenderNameAndValueCell") as EditLenderNameAndValueCell
            let lender = iOUData.sharedInstance.temporaryData.dynamicEditContractor
            tempCell.lenderName.text = lender.key
            tempCell.monetaryValue.text = String(format: "%.2f", lender.value)
            tempCell.shouldTakeUpSlack = shouldTakeUpSlack
            
            if (shouldTakeUpSlack)
            {
              tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button On")
            }
            else
            {
              tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button Off")
            }
            cell = tempCell
        }
      }
      else
      {
        //If using Percentage or Fixed shares, use the special Lender cell that contains the "Slack Taker" button.  Otherwise, use the regualr Contractor cell.
        if (temporaryContract.lenderShares == Shares.Percentage || temporaryContract.lenderShares == Shares.Fixed)
        {
          let tempCell = tableView.dequeueReusableCellWithIdentifier("LenderCell") as LenderCell
          tempCell.lenderName.text = contractor.key
          let currency = data.currency.rawValue
          let lenderShares = temporaryContract.lenderShares
          
          switch lenderShares
          {
            case Shares.Percentage:
              let monetaryTotal = temporaryContract.monetaryValue
              let fracton = contractor.value / monetaryTotal
              let percentage = Int(fracton * 100)
              tempCell.monetaryValue.text = "\(fracton)% (\(currency) \(Int(contractor.value)))"
            case Shares.Fixed:
              tempCell.monetaryValue.text = currency +  " " + String(Int(contractor.value))
            default:
              fatalError("LenderCell is only supposed to be used for Percentage and Fixed shares, not " + lenderShares.toString())
          }
          
          tempCell.shouldTakeUpSlack = shouldTakeUpSlack
          
          if (shouldTakeUpSlack)
          {
            tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button On")
          }
          else
          {
            tempCell.takeUpSlack.imageView!.image = UIImage(contentsOfFile: "Radio Button Off")
          }
          
          cell = tempCell
        }
        else
        {
          let tempCell = tableView.dequeueReusableCellWithIdentifier("ContractorCell") as ContractorCell
          let currency = data.currency.rawValue
          let lenderShares = temporaryContract.lenderShares
          
          switch lenderShares
          {
            case Shares.Equal:
              var monetaryValue = temporaryContract.monetaryValue
            
              if (temporaryData.includeTip)
              {
                var tip = Double(temporaryData.tip)
                tip /= 100
                monetaryValue *= 1 + tip
              }
            
              let contractors = temporaryContract.lenders.count
              let splitEqually = monetaryValue / Double(contractors)
              tempCell.contractorValue.text = currency +  " " + String(splitEqually)
          case Shares.Parts:
            tempCell.contractorValue.text = "\(Int(contractor.value))%"
          case Shares.Percentage:
            let monetaryTotal = temporaryContract.monetaryValue
            let fracton = contractor.value / monetaryTotal
            let percentage = Int(fracton * 100)
            tempCell.contractorValue.text = "\(fracton)% (\(currency) \(Int(contractor.value)))"
          case Shares.Fixed:
            tempCell.contractorValue.text = currency +  " " + String(Int(contractor.value))
          }

          cell = tempCell
        }
      }
    }
    
    return cell
  }
  
  class func newContractLendersRowSelection(indexPath: NSIndexPath)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in the New Contract Lenders table.")
    }
    
    //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
    if (saveDynamicChanges())
    {
      return
    }
    
    //Then reset dynamic editing
    resetDynamicEditing()
    temporaryData.dynamicEdit.id = "Lender"
    temporaryData.dynamicallyEditing = true
    
    if (indexPath.row == 0)
    {
      //If the "New Lender" cell was tapped on, add a new lender to the begining of temporaryContract.lenders and set dynamic editing accordingly.
      
      //First, generate a unique key for the new Lender based on the current number of lenders.
      var lenderID = "Lender "
      
      NamingLoop : for i in 1...temporaryContract.lenders.count + 1
      {
        let temporaryID = lenderID + "\(i)"
        
        if (!temporaryContract.lenders.hasKey(temporaryID))
        {
          lenderID = temporaryID
          break NamingLoop
        }
      }
      
      //Then add it to contracteeTemporary and update dynamicEditCell and temporaryData and reload table to update changes.
      temporaryContract.lenders.insert(insertAtIndex: 0, key: lenderID, value: 0)
      temporaryData.dynamicEdit.cell = NSIndexPath(forRow: 1, inSection: 0)
    }
    else
    {
      //Otherwise, if an exsisting lender has been seleced, set the dynamicEditCell to the current indexPath.
      temporaryData.dynamicEdit.cell = indexPath
    }
    
    //Either way, setup dynamic Editing, update temporaryData and reload the views to update changes.
    iOULogic.refreshViews()
  }
  
  //MARK: - Utility Functions
  class func saveDynamicChanges() -> (Bool)
  {
    //If dynamically editing make sure temporaryContract is uptodate.
    if (temporaryData.dynamicallyEditing)
    {
      let type = temporaryContract.type
      let editID = temporaryData.dynamicEdit.id
      let editSection = temporaryData.dynamicEdit.cell.section
      let editRow = temporaryData.dynamicEdit.cell.row
      
      switch editID
      {
        case "Title":
          //Check if the new contract title is blank, and if so, set it to the default.
          var title = temporaryContract.title
        
          if (title == "")
          {
            temporaryContract.title = "Title (" + type.toAlternateString() + " iOU)"
          }
        case "MonetaryValue":
          calculateValue()
        case "TipPercentage":
          break
        case "Lender":
          //If dynamically editing lenders, update contracteeTemporary and the appropirate list in temporaryContract. Check if the user attempted to use the same name twice.  If they did, ignore all other actions and request that they make the name unique.
          if (editRow > 0)
          {
            if (updateContractors())
            {
              return true
            }
          }
        case "Borrower":
          //If dynamically editing borrowers, update contracteeTemporary and the appropirate list in temporaryContract. Check if the user attempted to use the same name twice.  If they did, ignore all other actions and request that they make the name unique.
          if (editRow > 0)
          {
            if (updateContractors())
            {
              return true
            }
          }
        default:
          fatalError("There is no editID: \(editID).")
      }
      
      //Update the new contract with data from temporary contract.
      newContract.overWrite(temporaryContract)
    }
    
    return false
  }
  
  class func updateContractors() -> (Bool)
  {
    if (temporaryData.dynamicEdit.id == "Lender" || temporaryData.dynamicEdit.id == "Borrower")
    {
      //If the user attempts to use the same name twice, ignore all other actions and request that they make the name unique.
      var dynamicEditContractor = temporaryData.dynamicEditContractor
      let index = temporaryData.dynamicEdit.cell.row - 1
      
      //Find if the contractor's name already exists at some index keyIndex in the appropirate list.
      let name = dynamicEditContractor.key
      var keyIndex: Int?
      
      if (temporaryData.dynamicEdit.id == "Lender")
      {
        keyIndex = temporaryContract.lenders.getIndex(forKey: name)
      }
      else
      {
        keyIndex = temporaryContract.borrowers.getIndex(forKey: name)
      }
      
      if (keyIndex == nil)
      {
        //The contractor's name is new and exists nowhere in the list. Update lenders or borrowers.
        if (temporaryData.dynamicEdit.id == "Lender")
        {
          temporaryContract.lenders.update(overwriteKeyAtIndex: index, withNewKey: dynamicEditContractor.key)
        }
        else
        {
          temporaryContract.borrowers.update(overwriteKeyAtIndex: index, withNewKey: dynamicEditContractor.key)
        }
      }
      else if (index == keyIndex)
      {
        //The contractor's name is the same as it was before (The user has changed the contractor's monetary value). Update lenders or borrowers
        if (temporaryData.dynamicEdit.id == "Lender")
        {
          //If using equal shares, dynamicEditContractor.value will have been replaced with the equal share value.  If so, don't save this value.
          if (temporaryContract.lenderShares != Shares.Equal)
          {
            temporaryContract.lenders.update(overwriteValueAtIndex: index, withNewValue: dynamicEditContractor.value)
          }
        }
        else
        {
          //If using equal shares, dynamicEditContractor.value will have been replaced with the equal share value.  If so, don't save this value.
          if (temporaryContract.borrowerShares != Shares.Equal)
          {
            temporaryContract.borrowers.update(overwriteValueAtIndex: index, withNewValue: dynamicEditContractor.value)
          }
        }
      }
      else
      {
        //The contractor's name matches another contractor's name somehwere else in the list.  Warn the user, and ask them to uniquely identify the current contractor.  Use NSNotificationCenter to request NewContractContoller to perform the segue.
        
        temporaryData.warnSource = "NewContract"
        NSNotificationCenter.defaultCenter().postNotificationName("ContractorNameWarning", object: nil)
        return true
      }
    }
    
    return false
  }
  
  class func resetDynamicEditing()
  {
    temporaryData.dynamicallyEditing = false
    temporaryData.dynamicEdit.id = ""
    temporaryData.dynamicEdit.cell = NSIndexPath()
    temporaryData.dynamicEditContractor.key = ""
    temporaryData.dynamicEditContractor.value = 0
  }
  
  class func updateMonetaryValueText(#sender: MonetaryValue, includeDecimal: Bool)
  {
    //Whenever the user changes the contract monetary value, update temporaryContract.monetaryValue.
    
    //First, eliminate any characters that are not numbers from contractMonetaryValue.text. (Note: Since this is being done in real time, this effectively prevents the user from inputing any non-number characters.)
    var textualMonetaryValue = ""
    
    for character in sender.monetaryValue.text
    {
      switch character
      {
      case "0"..."9":
        textualMonetaryValue.append(character)
      default:
        continue
      }
    }
    
    var monetaryValue = textualMonetaryValue.doubleValue
    
   //Next, if includeDecimal is true, Divide monetaryValue by 100 to move the decimal point up before the final two digits, then use a string formater to make sure sender.monetaryValue displays correctly.
    if (includeDecimal)
    {
      monetaryValue /= 100
      sender.monetaryValue.text = String(format: "%.2f", monetaryValue)
    }
    else
    {
      sender.monetaryValue.text = String(format: "%.0f", monetaryValue)
    }
    
    temporaryContract.monetaryValue = monetaryValue
  }
  
  class func performOperation(operation: Operation) -> (String)
  {
    if (temporaryData.calculatorValue != nil)
    {
      calculateValue()
    }
    
    temporaryData.calculatorValue = temporaryContract.monetaryValue
    temporaryContract.monetaryValue = Double(0)
    temporaryData.calculatorOperator = operation
    return "0.00"
  }
  
  class func calculateValue() -> (String)
  {
    if let previousValue = temporaryData.calculatorValue
    {
      let currentValue = temporaryContract.monetaryValue
      var newValue: Double
      
      switch temporaryData.calculatorOperator
      {
        case Operation.Add:
          newValue = previousValue + currentValue
        case Operation.Subtract:
          newValue = previousValue - currentValue
        case Operation.Multiply:
          newValue = previousValue * currentValue
        case Operation.Divide:
          newValue = previousValue / currentValue
      }
      
      temporaryData.calculatorValue = nil
      temporaryContract.monetaryValue = newValue
      return String(format: "%.2f", newValue)
    }
    else
    {
      let monetaryValue = temporaryContract.monetaryValue
      return String(format: "%.2f", monetaryValue)
    }
  }
  
  class func loopedPickerRowTitle(#sourceData: [[String]], titleForRow row: Int, forComponent component: Int) -> (String!)
  {
    let rowCount = sourceData[component].count
    let rowTitle = row % rowCount
    return sourceData[component][rowTitle]
  }
  
  class func updateLoopedPercentagePicker(var #picker: PercentagePicker, didSelectRow row: Int, inComponent component: Int, var percentageCap cap: Int) -> (Int)
  {
    //Define the padding and the uppper and lower limits for the range to keep the picker within whenever a value is selected.
    let padding = 10 //The size of a the range of values.
    let lowerBound = padding * data.loopRadius
    let upperBound = padding * (data.loopRadius + 1)
    
    //If the user has selected a row outside of the middle range of the pesudo-infinite percentage picker, teleport back within the range.  Provided the user does not scroll continuously without letup, this will give the illusion of an infinite picker wheel.
    if ((row < lowerBound) || (row >= upperBound))
    {
      let toZero = row % padding  //Find the position with the same value as the current selection within the first range.
      let shiftTo = toZero + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
      picker.percentage.selectRow(shiftTo, inComponent: component, animated: false)
    }
    
    //Once at the correct location, calculate the percentage.
    var percent: Int
    
    //If cap is greater than zero, then do not allow any value over the cap.  If the user goes over the cap, shift down to the cap, but save the digit values.  If the user adjusts back below the cap, return to the previous value before they moved above the cap the first time.  If they adust over th cap, set the higher digit(s) to zero and accept the new digit values. If the cap is -1, ignore it.
    
    //Then, find the hundreds, tens, and ones digits.
    var hundredsDigit = picker.percentage.selectedRowInComponent(0)
    var tensDigit = picker.percentage.selectedRowInComponent(1)
    var onesDigit = picker.percentage.selectedRowInComponent(2)
    
    //(Don't forget to remove the row location padding!)
    hundredsDigit %= padding
    tensDigit %= padding
    onesDigit %= padding
    
    if (cap >= 0)
    {
      let hundredsCap = (cap / 100)
      let tensCap = (cap / 10) - (hundredsCap * 10)
      let onesCap = cap - (hundredsCap * 100) - (tensCap * 10)
      let currentValue = picker.current.hundredsDigit * 100 + picker.current.tensDigit * 10 + picker.current.onesDigit
      
      if (hundredsCap < hundredsDigit)
      {
        if (component == 0 && cap == currentValue)
        {
          hundredsDigit = picker.saved.hundredsDigit
          tensDigit = picker.saved.tensDigit
          onesDigit = picker.saved.onesDigit
        }
        else
        {
          //Save and cap the digits
          picker.saved.hundredsDigit = picker.current.hundredsDigit
          picker.saved.tensDigit = picker.current.tensDigit
          picker.saved.onesDigit = picker.current.onesDigit
          
          hundredsDigit = hundredsCap
          tensDigit = tensCap
          onesDigit = onesCap
        }
        
        let hundredsRow = hundredsDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        let tensRow = tensDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        
        picker.percentage.selectRow(hundredsRow, inComponent: 0, animated: true)
        picker.percentage.selectRow(tensRow, inComponent: 1, animated: true)
        picker.percentage.selectRow(onesRow, inComponent: 2, animated: true)
      }
      else if (hundredsCap == hundredsDigit)
      {
        if (tensCap < tensDigit)
        {
          if (component == 1)
          {
            hundredsDigit = 0
            picker.percentage.selectRow(lowerBound, inComponent: 0, animated: true)
            
            if (cap == currentValue)
            {
              if (hundredsCap == 0)
              {
                tensDigit = picker.saved.tensDigit
                onesDigit = picker.saved.onesDigit
              }
              else
              {
                picker.saved.hundredsDigit = hundredsDigit
                picker.saved.tensDigit = tensDigit
                picker.saved.onesDigit = onesDigit
              }
            }
            else
            {
              //Save the tens and ones digits
              picker.saved.hundredsDigit = picker.current.hundredsDigit
              picker.saved.tensDigit = picker.current.tensDigit
              picker.saved.onesDigit = picker.current.onesDigit
              
              tensDigit = tensCap
              onesDigit = onesCap
            }
          }
          else
          {
            //Save the tens and ones digits
            picker.saved.hundredsDigit = picker.current.hundredsDigit
            picker.saved.tensDigit = picker.current.tensDigit
            picker.saved.onesDigit = picker.current.onesDigit
            
            tensDigit = tensCap
            onesDigit = onesCap
          }
          
          let tensRow = tensDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
          let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
          
          picker.percentage.selectRow(tensRow, inComponent: 1, animated: true)
          picker.percentage.selectRow(onesRow, inComponent: 2, animated: true)
        }
        else if (tensCap == tensDigit)
        {
          if (onesCap < onesDigit)
          {
            if (component == 2)
            {
              hundredsDigit = 0
              tensDigit = 0
              
              picker.percentage.selectRow(lowerBound, inComponent: 0, animated: true)
              picker.percentage.selectRow(lowerBound, inComponent: 1, animated: true)
              
              if (cap == currentValue)
              {
                if (hundredsCap == 0 && tensCap == 0)
                {
                  onesDigit = picker.saved.onesDigit
                }
                else
                {
                  picker.saved.hundredsDigit = hundredsDigit
                  picker.saved.tensDigit = tensDigit
                  picker.saved.onesDigit = onesDigit
                }
              }
              else
              {
                //Save the ones digits
                picker.saved.hundredsDigit = picker.current.hundredsDigit
                picker.saved.tensDigit = picker.current.tensDigit
                picker.saved.onesDigit = picker.current.onesDigit
                
                onesDigit = onesCap
              }
            }
            else
            {
              //Save the tens and ones digits
              picker.saved.hundredsDigit = picker.current.hundredsDigit
              picker.saved.tensDigit = picker.current.tensDigit
              picker.saved.onesDigit = picker.current.onesDigit
              
              onesDigit = onesCap
            }
            
            let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
            picker.percentage.selectRow(onesRow, inComponent: 2, animated: true)
          }
          else
          {
            picker.saved.hundredsDigit = hundredsDigit
            picker.saved.tensDigit = tensDigit
            picker.saved.onesDigit = onesDigit
          }
        }
        else
        {
          picker.saved.hundredsDigit = hundredsDigit
          picker.saved.tensDigit = tensDigit
          picker.saved.onesDigit = onesDigit
        }
      }
      else
      {
        picker.saved.hundredsDigit = hundredsDigit
        picker.saved.tensDigit = tensDigit
        picker.saved.onesDigit = onesDigit
      }
      
      picker.current.hundredsDigit = hundredsDigit
      picker.current.tensDigit = tensDigit
      picker.current.onesDigit = onesDigit
      percent = hundredsDigit * 100 + tensDigit * 10 + onesDigit
    }
    else
    {
      //If the percentage cap was not activated, find the hundreds, tens, and ones digits.
      var hundredsDigit = picker.percentage.selectedRowInComponent(0)
      var tensDigit = picker.percentage.selectedRowInComponent(1)
      var onesDigit = picker.percentage.selectedRowInComponent(2)
      
      //(Don't forget to remove the row location padding!)
      hundredsDigit %= padding
      tensDigit %= padding
      onesDigit %= padding
      
      //Calculate the percentage.
      percent = hundredsDigit * 100 + tensDigit * 10 + onesDigit
    }
    
    return percent
  }
  
  class func refreshViews()
  {
    NSNotificationCenter.defaultCenter().postNotificationName("Refresh", object: nil)
  }
}
