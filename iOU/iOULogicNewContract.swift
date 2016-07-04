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
  class var lenderTableIndexPath: NSIndexPath
  {
    get
    {
      return NSIndexPath(forRow: 1, inSection: 2)
    }
  }
  class var borrowerTableIndexPath: NSIndexPath
  {
    get
    {
      return NSIndexPath(forRow: 1, inSection: 3)
    }
  }
  class var newLenderInsertionOffset: Int
  {
    get
    {
      if (contractTempData.lendersTemporary.hasKey("@User@"))
      {
        return 1
      }
      else
      {
        return 2
      }
    }
  }
  class var newLenderInsertionIndexPath: NSIndexPath
  {
    get
    {
      return NSIndexPath(forRow: newLenderInsertionOffset, inSection: 0)
    }
  }
  class var newBorrowerInsertionOffset: Int
  {
    get
    {
      if (contractTempData.borrowersTemporary.hasKey("@User@"))
      {
        return 1
      }
      else
      {
        return 2
      }
    }
  }
  class var newBorrowerInsertionIndexPath: NSIndexPath
  {
    get
    {
      return NSIndexPath(forRow: newBorrowerInsertionOffset, inSection: 0)
    }
  }
  class var data: iOUData
  {
    get
    {
      return iOUData.sharedInstance
    }
  }
  class var contractTempData: ContractTemporaryData
  {
    get
    {
      return data.contractTemporaryData
    }
    set
    {
      data.contractTemporaryData = newValue
    }
  }
  class var temporaryContract: Contract
  {
    get
    {
      return contractTempData.contract
    }
    set
    {
      contractTempData.contract = newValue
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
  
  //MARK: General Logic Functions
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
  
  class func newContractViewDidLoad(view: NewContractController)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "refreshTable", name: "RefreshNewContract", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "refreshCells:", name: "RefreshNewContractCells", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "keyboardWillShow:", name: "NewContractKeyboardWillShow", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    
    //Register Table.
    view.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    switch temporaryContract.type
    {
      case Type.Money:
        newContractMoneyViewDidLoad(view)
      case Type.Item:
        newContractItemViewDidLoad(view)
      case Type.Service:
        newContractServiceViewDidLoad(view)
    }
  }
  
  class func newContractViewWillDisappear(view: NewContractController)
  {
    NSNotificationCenter.defaultCenter().removeObserver(view, name: "RefreshNewContractCells", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(view, name: "NewContractKeyboardWillShow", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(view, name: UIKeyboardWillHideNotification, object: nil)
    
    switch temporaryContract.type
    {
      case Type.Money:
        newContractMoneyViewWillDisappear(view)
      case Type.Item:
        newContractItemViewWillDisapear(view)
      case Type.Service:
        newContractServiceViewWillDisappear(view)
    }
  }
  
  class func newContractEdited(#sender: NewContractController, save: Bool)
  {
    //This function controls what happens when the user clicks done or cancel when creating a new iOU contract.
    
    //First, either save the current temporary contract data (temporaryContract) to the new contract being formed (newContract), or not.  Also fill in those fields that need a default value so they're not blank.
    if (save) //If/else save block.
    {
      
      //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
      if (failedToSaveDynamicChanges())
      {
        return
      }
      
      newContract.overWrite(temporaryContract)
      
      //If not dynamically editing, include tip in monetaryValue now that the contract is finished, then save the new contract to the appropriate list.
      if (!contractTempData.dynamicallyEditing)
      {
        newContract.monetaryValue = totalMonetaryValue()
        
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
      if (contractTempData.dynamicallyEditing)
      {
        if (contractTempData.dynamicEditID == "Lender")
        {
          if (contractTempData.lendersTemporary.count > temporaryContract.lenders.count)
          {
            contractTempData.lendersTemporary.remove(index: 0)
            
            if (contractTempData.lenderSlackRow >= 0)
            {
              contractTempData.lenderSlackRow--
            }
          }
        }
        else if (contractTempData.dynamicEditID == "Borrower")
        {
          if (contractTempData.borrowersTemporary.count > temporaryContract.borrowers.count)
          {
            contractTempData.borrowersTemporary.remove(index: 0)
            
            if (contractTempData.borrowerSlackRow >= 0)
            {
              contractTempData.borrowerSlackRow--
            }
          }
        }
      }
      
      temporaryContract.overWrite(newContract)
    }
    
    if (contractTempData.dynamicallyEditing)
    {
      //If dynamic cell editing was taking place, end it and reload the table to update the changes.
      if (contractTempData.dynamicEditID == "Lender")
      {
        resetDynamicEditing()
        refreshNewContractorTable("Lender")
      }
      else if (contractTempData.dynamicEditID == "Borrower")
      {
        resetDynamicEditing()
        refreshNewContractorTable("Borrower")
      }
      else
      {
        if (contractTempData.dynamicEditID == "MonetaryValue")
        {
          refreshNewContractors()
        }
        
        let refreshRows = [contractTempData.dynamicEditCell]
        resetDynamicEditing()
        refreshNewContractCells(refreshRows)
      }
    }
    else
    {
      //Return to the Main Interface
      data.resetNewContractData()
      sender.performSegue(segueFrom: "NewContract", segueTo: "MainInterface")
    }
  }
  
  class func newContractSectionCount(section: Int) -> (Int)
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

  
  class func newContractCreateCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    var cell: UITableViewCell?
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        cell = iOULogic.newContractMoneyCreateCell(tableView: tableView, indexPath: indexPath)
      case Type.Item:
        cell = iOULogic.newContractItemCreateCell(tableView: tableView, indexPath: indexPath)
      case Type.Service:
        cell = iOULogic.newContractServiceCreateCell(tableView: tableView, indexPath: indexPath)
    }
    
    return cell
  }
  
  class func newContractSelectRow(#tableView: UITableView, indexPath: NSIndexPath)
  {
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        iOULogic.newContractMoneyRowSelection(tableView: tableView, indexPath: indexPath)
      case Type.Item:
        iOULogic.newContractItemRowSelection(tableView: tableView, indexPath: indexPath)
      case Type.Service:
        iOULogic.newContractServiceRowSelection(tableView: tableView, indexPath: indexPath)
    }
  }
  
  
  
  //MARK: New Money Contract Logic
  class func newContractMoneyViewDidLoad(view: NewContractController)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "lenderNameWarning", name: "LenderNameWarning", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "borrowerNameWarning", name: "BorrowerNameWarning", object: nil)
    
    //Initialzie the Table.
    var nib = UINib(nibName: "EditMonetaryValueCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueCell")
    nib = UINib(nibName: "EditMonetaryValueWithCalculatorCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueWithCalculatorCell")
    nib = UINib(nibName: "EditTitleCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditTitleCell")
    nib = UINib(nibName: "EditPercentageCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditPercentageCell")
    nib = UINib(nibName: "EditDatePickerCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditDatePickerCell")
    nib = UINib(nibName: "EditDatePickerNarrowCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditDatePickerNarrowCell")
    nib = UINib(nibName: "EditDateCalenderCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditDateCalenderCell")
    nib = UINib(nibName: "EditDateCalenderNarrowCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditDateCalenderNarrowCell")
    nib = UINib(nibName: "EditTimeCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditTimeCell")
    nib = UINib(nibName: "EditTimeNarrowCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditTimeNarrowCell")
    nib = UINib(nibName: "EditPickerCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditPickerCell")
  }
  
  class func newContractMoneyViewWillDisappear(view: NewContractController)
  {
    NSNotificationCenter.defaultCenter().removeObserver(view, name: "LenderNameWarning", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(view, name: "BorrowerNameWarning", object: nil)
  }
  
  class func newContractMoneyRowCount(section: Int) -> (Int)
  {
    var count: Int
    
    switch section
    {
      case 0:
        count = 1
      case 1:
        count = 3
      case 2:
        if (contractTempData.displayingLenders)
        {
          count = 2
        }
        else
        {
          count = 1
        }
      case 3:
        if (contractTempData.displayingBorrowers)
        {
          count = 2
        }
        else
        {
          count = 1
        }
      case 4:
        count = 2
      case 5:
        count = 1
        
        if (contractTempData.displayAlertSettings)
        {
          count += 5
          
          if (contractTempData.displayAlertRepeatSettings)
          {
            count += 3
          }
        }
      break
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
        if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "Title")
        {
          height = 84
        }
      case (1, 0):
        if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "MonetaryValue" && contractTempData.displayCalculator)
        {
          height = 84
        }
      case (2, 1), (3, 1):
        var contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>
        
        if (location.section == 2)
        {
          contractors = contractTempData.lendersTemporary
        }
        else
        {
          contractors = contractTempData.borrowersTemporary
        }
        
        height = 72 + (contractors.count * 44)
        
        if (!contractors.hasKey("@User@"))
        {
          height += 44
        }
        
        if (data.mainScreenWidth < iPhone4sHeight)
        {
          height += contractors.count * 40
        }
      case (4, 0):
        if (contractTempData.displayDueCalender)
        {
          //TODO - Finish when calender is implented.
        }
        else if (data.mainScreenWidth < iPhone6Width)
        {
          height = 72
        }
        else if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "DueDate" && data.mainScreenWidth > iPhone6Width)
        {
          height = 72
        }
      break
      default:
        break
    }
    
    if (height == nil)
    {
      height = 44
    }
    
    return height!
  }
  
  class func newContractMoneyCreateCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    var cell: UITableViewCell?
    
    if (indexPath == contractTempData.dynamicEditCell)
    {
      switch indexPath.section
      {
        case 0:
          cell = (tableView.dequeueReusableCellWithIdentifier("EditTitleCell") as! UITableViewCell)
        case 1:
          switch indexPath.row
          {
            case 0:
              if (contractTempData.displayCalculator)
              {
                cell = (tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueWithCalculatorCell") as! UITableViewCell)
              }
              else
              {
                cell = (tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueCell") as! UITableViewCell)
              }
            case 1:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditPercentageCell") as! UITableViewCell)
            case 2:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditPercentageCell") as! UITableViewCell)
            default:
              fatalError("There is no dynamic edit cell at row: \(indexPath.row) in section:\(indexPath.section)")
          }
        case 4:
          switch indexPath.row
          {
            case 0:
              var cellID = "EditDate"
              
              if (contractTempData.displayDueCalender)
              {
                cellID += "Calender"
              }
              else
              {
                cellID += "Picker"
              }
              
              if (data.mainScreenWidth < iPhone4sHeight)
              {
                cellID += "Narrow"
              }
              
              cellID += "Cell"
              cell = (tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell)
            case 1:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditTimeCell") as! UITableViewCell)
            default:
              fatalError("There is no dynamic edit cell at row: \(indexPath.row) in section:\(indexPath.section)")
          }
        case 5:
          switch indexPath.row
          {
            case 1:
              var cellID = "EditDate"
              
              if (contractTempData.displayAlertCalender)
              {
                cellID += "Calender"
              }
              else
              {
                cellID += "Picker"
              }
              
              if (data.mainScreenWidth < iPhone4sHeight)
              {
                cellID += "Narrow"
              }
              
              cellID += "Cell"
              cell = (tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell)
            case 2:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditTimeCell") as! UITableViewCell)
            case 3:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditToneCell") as! UITableViewCell)
            case 4:
              cell = (tableView.dequeueReusableCellWithIdentifier("EditPickerCell") as! UITableViewCell)
            case 6:
              switch temporaryContract.alertRepeatType
              {
                case AlertRepeatType.Simple:
                  cell = (tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatSimpleCell") as! UITableViewCell)
                case AlertRepeatType.Month:
                  cell = (tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatCell") as! UITableViewCell)
                case AlertRepeatType.Days:
                  if (contractTempData.alertRepeatCellType.isPattern())
                  {
                    cell = (tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatDaysCell") as! UITableViewCell)
                  }
                  else
                  {
                    cell = (tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatCell") as! UITableViewCell)
                  }
              }
            case 7:
              var cellID = "EditDate"
              
              if (contractTempData.displayAlertRepeatCalender)
              {
                cellID += "Calender"
              }
              else
              {
                cellID += "Picker"
              }
              
              if (data.mainScreenWidth < iPhone4sHeight)
              {
                cellID += "Narrow"
              }
              
              cellID += "Cell"
              cell = (tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell)
            break
            default:
              fatalError("There is no dynamic edit cell at row: \(indexPath.row) in section:\(indexPath.section)")
          }
        default:
          fatalError("There is no dynamic edit cell in section: \(indexPath.section)")
      }
    }

    return cell
  }
  
  class func newContractMoneyUpdateCell(#cell: UITableViewCell, indexPath: NSIndexPath)
  {
    switch indexPath.section
    {
      case 0:
        if (indexPath.row == 0)
        {
          if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "Title")
          {
            let tempCell = cell as! EditTitleCell
            tempCell.contractTitle.text = temporaryContract.title
            tempCell.contractType.selectedSegmentIndex = temporaryContract.type.rawValue
            data.currentFocus = tempCell
          }
          else
          {
            cell.textLabel?.text = temporaryContract.title
            cell.detailTextLabel?.text = temporaryContract.type.toString()
          }
        }
      case 1:
        switch indexPath.row
        {
          case 0:
            let currency = data.currency.rawValue
            
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "MonetaryValue")
            {
              let tempCell = cell as! EditMonetaryValueCell
              tempCell.contractCurrency.setTitle(currency, forState: UIControlState.Normal)
              let monetaryValue = temporaryContract.monetaryValue
              tempCell.monetaryValue.text = String(format: "%.2f", monetaryValue)
              data.currentFocus = tempCell
            }
            else
            {
              if (contractTempData.includeTip)
              {
                let monetaryValue = totalMonetaryValue()
                cell.detailTextLabel?.text = currency + String(format: " %.2f", monetaryValue) + String(format: " (%.2f", temporaryContract.monetaryValue) + ")"
              }
              else
              {
                cell.detailTextLabel?.text = currency + String(format: " %.2f", temporaryContract.monetaryValue)
              }
            }
          case 1:
            let switchCell = cell as! SwitchCell
            
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "TipPercentage")
            {
              let tempCell = cell as! EditPercentageCell
              tempCell.percentageLabel.text = "Include Tip:"
              
              //Initialize percentage picker.
              initializePercentagePicker(tempCell, percentage: temporaryContract.tip)
            }
            else
            {
              switchCell.toggleLabel.text = "\(temporaryContract.tip)%"
            }
            
            switchCell.toggleID = "Tip"
            switchCell.toggle.setOn(contractTempData.includeTip, animated: false)
          case 2:
            let switchCell = cell as! SwitchCell
            
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "IntrestPercentage")
            {
              let tempCell = cell as! EditPercentageCell
              tempCell.percentageLabel.text = "Include Intrest:"
              
              //Initialize percentage picker.
              initializePercentagePicker(tempCell, percentage: temporaryContract.tip)
            }
            else
            {
              switchCell.toggleLabel.text = "\(temporaryContract.tip)%"
            }
            
            switchCell.toggleID = "Intrest"
            switchCell.toggle.setOn(contractTempData.includeTip, animated: false)
          default:
            return
        }
      case 4:
        if (indexPath.row =| [0, 1])
        {
          let date = temporaryContract.dateDue
          var dateCell: EditDateCell!
          
          if (contractTempData.dynamicallyEditing)
          {
            if (contractTempData.dynamicEditID == "DueDate" && indexPath.row == 0)
            {
              if (contractTempData.displayDueCalender)
              {
                let tempCell = cell as! EditDateCalenderCell
                //TODO - Finish when calender is working!!!
              }
              
              dateCell = cell as! EditDatePickerCell
            }
            else if (contractTempData.dynamicEditID == "DueTime" && indexPath.row == 1)
            {
              dateCell = (cell as! EditDateCell)
            }
          }
          
          if (dateCell != nil)
          {
            if (dateCell.dateLabel != nil)
            {
              if (indexPath.row == 0)
              {
                dateCell.dateLabel.text = "Due Date"
              }
              else
              {
                dateCell.dateLabel.text = "Due Time"
              }
            }
            
            dateCell.datePicker.setDate(date, animated: false)
            contractTempData.dynamicEditValue = date
          }
          else
          {
            if (indexPath.row == 0)
            {
              data.dateFormatter.dateFormat = "E MMM dd, yyyy"
            }
            else
            {
              data.dateFormatter.dateFormat = "h:mm a"
            }
            
            cell.detailTextLabel?.text = data.dateFormatter.stringFromDate(date)
          }
        }
      case 5:
        switch indexPath.row
        {
          case 0:
            let tempcell = cell as! SwitchCell
            tempcell.toggleID = "UseAlert"
            tempcell.toggle.setOn(temporaryContract.useAlert, animated: false)
          case 1, 2:
            let date = temporaryContract.alertDate
            var dateCell: EditDateCell!
            
            if (contractTempData.dynamicallyEditing == true)
            {
              if (contractTempData.dynamicEditID == "AlertDate" && indexPath.row == 1)
              {
                if (contractTempData.displayAlertCalender)
                {
                  let tempCell = cell as! EditDateCalenderCell
                  //TODO - Finish when calender is working!!!
                }
                
                dateCell = (cell as! EditDateCell)
              }
              else if (contractTempData.dynamicEditID == "AlertTime" && indexPath.row == 2)
              {
                dateCell = (cell as! EditDateCell)
              }
            }
              
            if (dateCell != nil)
            {
              if (dateCell.dateLabel != nil)
              {
                if (indexPath.row == 1)
                {
                  dateCell.dateLabel.text = "Alert Date"
                }
                else
                {
                  dateCell.dateLabel.text = "Alert Time"
                }
              }
              
              dateCell.datePicker.setDate(date, animated: false)
              contractTempData.dynamicEditValue = date
            }
            else
            {
              if (indexPath.row == 0)
              {
                data.dateFormatter.dateFormat = "E MMM dd, yyyy"
              }
              else
              {
                data.dateFormatter.dateFormat = "h:mm a"
              }
              
              cell.detailTextLabel?.text = data.dateFormatter.stringFromDate(date)
            }
          case 3:
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "AlertTone")
            {
              let tempCell = cell as! EditPickerCell
              tempCell.pickerID = "AlertTone"
              tempCell.pickerLabel.text = "Alert Tone"
              tempCell.picker.selectRow(temporaryContract.alertTone.rawValue, inComponent: 0, animated: false)
            }
            else
            {
              cell.detailTextLabel?.text = temporaryContract.alertNagRate.toString()
            }
            break //TODO - Finish!!!
          case 4:
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "AlertNagRate")
            {
              let tempCell = cell as! EditPickerCell
              tempCell.pickerID = "AlertNagRate"
              tempCell.pickerLabel.text = "Alert Nag Rate"
              tempCell.picker.selectRow(temporaryContract.alertNagRate.rawValue, inComponent: 0, animated: false)
            }
            else
            {
              cell.detailTextLabel?.text = temporaryContract.alertNagRate.toString()
            }
          case 5:
            let tempcell = cell as! SwitchCell
            tempcell.toggleID = "RepeatAlert"
            tempcell.toggle.setOn(temporaryContract.repeatAlert, animated: false)
          case 6:
            let date = temporaryContract.dateDue
            
            if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == "AlertRepeatRate")
            {
              var repeatPattern = ""
              var repeatRate = "Every "
              
              switch temporaryContract.alertRepeatType
              {
                case AlertRepeatType.Simple:
                  let tempCell = cell as! EditAlertRepeatSimpleCell
                  tempCell.pickerID = "AlertRepeatSimple"
                  
                  tempCell.fromCompleation.setOn(temporaryContract.repeatFromCompleation, animated: false)
                  
                  let rate = contractTempData.alertRepeatSimpleRate
                  let interval = contractTempData.alertRepeatSimpleInterval.rawValue
                  tempCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  tempCell.picker.selectRow(interval, inComponent: 1, animated: false)
                  
                  if (contractTempData.alertRepeatSimpleRate == 1)
                  {
                    repeatRate += contractTempData.alertRepeatSimpleInterval.toString()
                  }
                  else
                  {
                    repeatRate += contractTempData.alertRepeatSimpleRate + " " + contractTempData.alertRepeatSimpleInterval.toString() + "s"
                    
                    if (contractTempData.alertRepeatSimpleInterval != TimeInterval.Day)
                    {
                      repeatRate += " on "
                      
                      switch contractTempData.alertRepeatSimpleInterval
                      {
                        case TimeInterval.Week:
                          data.dateFormatter.dateFormat = "E"
                          repeatRate += data.dateFormatter.stringFromDate(date)
                        case TimeInterval.Month:
                          data.dateFormatter.dateFormat = "d"
                          let day = data.dateFormatter.stringFromDate(date)
                          repeatRate += "the " + day + numberSuffix(day)
                        case TimeInterval.Year:
                          data.dateFormatter.dateFormat = "MMMM"
                          let month = data.dateFormatter.stringFromDate(date)
                          data.dateFormatter.dateFormat = "d"
                          let day = data.dateFormatter.stringFromDate(date)
                          repeatRate += month + " " + day + numberSuffix(day)
                        case TimeInterval.Day:
                          break
                      }
                    }
                  }
                  
                  tempCell.repeatRate.titleLabel?.text = repeatRate
                case AlertRepeatType.Month:
                  let tempCell = cell as! EditAlertRepeatCell
                  let pattern = contractTempData.alertRepeatMonthPattern
                  let interval = contractTempData.alertRepeatMonthInterval
                  let rate = contractTempData.alertRepeatMonthRate
                  
                  if (contractTempData.alertRepeatCellType.isPattern())
                  {
                    tempCell.pickerID = "AlertRepeatMonthPattern"
                    
                    tempCell.picker.selectRow(pattern, inComponent: 0, animated: false)
                    tempCell.picker.selectRow(interval.rawValue, inComponent: 1, animated: false)
                  }
                  else
                  {
                    tempCell.pickerID = "AlertRepeatMonthRate"
                    tempCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  }
                  
                  repeatPattern = "The " + pattern + numberSuffix(pattern) + " " + interval.toString()
                  tempCell.repeatPattern.titleLabel?.text = repeatPattern
                  
                  if (contractTempData.alertRepeatMonthRate == 1)
                  {
                    repeatRate += "Month"
                  }
                  else
                  {
                    repeatRate += contractTempData.alertRepeatMonthRate + "Months"
                  }
                  
                  tempCell.repeatPattern.titleLabel?.text = repeatPattern
                  tempCell.repeatRate.titleLabel?.text = repeatRate
                case AlertRepeatType.Days:
                  let tempCell = cell as! EditAlertRepeatCell

                  if (contractTempData.alertRepeatDaysPattern.monday)
                  {
                    repeatPattern += "Mon, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.tuesday)
                  {
                    repeatPattern += "Tue, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.wednesday)
                  {
                    repeatPattern += "Wed, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.thursday)
                  {
                    repeatPattern += "Thu, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.friday)
                  {
                    repeatPattern += "Fri, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.saturday)
                  {
                    repeatPattern += "Sat, "
                  }
                  
                  if (contractTempData.alertRepeatDaysPattern.sunday)
                  {
                    repeatPattern += "Sun, "
                  }
                  
                  
                  if (repeatPattern != "")
                  {
                    repeatPattern = repeatPattern[0..<repeatPattern.count - 2]
                  }
                  
                  if (repeatPattern == "Mon, Tue, Wed, Thu, Fri, Sat, Sun")
                  {
                    repeatPattern = "Every Day"
                  }
                  else if (repeatPattern == "Mon, Tue, Wed, Thu, Fri")
                  {
                    repeatPattern = "Every Weekday"
                  }
                  else if (repeatPattern == "Sat, Sun")
                  {
                    repeatPattern = "Every Weekend"
                  }
                  
                  tempCell.repeatPattern.titleLabel?.text = repeatPattern
                  
                  if (contractTempData.alertRepeatDaysRate == 1)
                  {
                    repeatRate += "Week"
                  }
                  else
                  {
                    repeatRate += contractTempData.alertRepeatDaysRate + "Weeks"
                  }
                  
                  tempCell.repeatRate.titleLabel?.text = repeatRate
                  
                  if (contractTempData.alertRepeatCellType.isPattern())
                  {
                    let daysCell = cell as! EditAlertRepeatDaysCell
                    
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.monday, button: daysCell.monday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.tuesday, button: daysCell.tuesday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.wednesday, button: daysCell.wednesday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.thursday, button: daysCell.thursday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.friday, button: daysCell.friday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.sunday, button: daysCell.saturday)
                    setRepeatDayButtonImage(state: contractTempData.alertRepeatDaysPattern.sunday, button: daysCell.sunday)
                  }
                  else
                  {
                    tempCell.pickerID = "AlertRepeatDaysRate"

                    let rate = contractTempData.alertRepeatMonthRate
                    tempCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  }
              }
            }
          case 7:
            let date = temporaryContract.alertRepeatDate
            
            if (contractTempData.dynamicallyEditing == true && contractTempData.dynamicEditID == "AlertDate")
            {
              if (contractTempData.displayAlertCalender)
              {
                let tempCell = cell as! EditDateCalenderCell
                //TODO - Finish when calender is working!!!
              }
              
              let tempCell = cell as! EditDateCell
              
              if (tempCell.dateLabel != nil)
              {
                if (indexPath.row == 1)
                {
                  tempCell.dateLabel.text = "Alert Date"
                }
                else
                {
                  tempCell.dateLabel.text = "Alert Time"
                }
              }
              
              tempCell.datePicker.setDate(date, animated: false)
              contractTempData.dynamicEditValue = date
            }
            else
            {
              data.dateFormatter.dateFormat = "E MMM dd, yyyy"
              cell.detailTextLabel?.text = data.dateFormatter.stringFromDate(date)
            }
          case 8:
            let tempcell = cell as! SwitchCell
            tempcell.toggleID = "AutoCompleteAlert"
            tempcell.toggle.setOn(temporaryContract.autoCompleteAlert, animated: false)
          default:
            return
        }
      default:
        return
    }
  }
  
  class func newContractMoneyRowSelection(#tableView: UITableView, indexPath: NSIndexPath)
  {
    if (indexPath != contractTempData.dynamicEditCell)
    {
      var refreshRows: [NSIndexPath] = []
      
      //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
      if (contractTempData.dynamicallyEditing)
      {
        if (failedToSaveDynamicChanges())
        {
          return
        }
        
        if (contractTempData.dynamicEditID == "Lender")
        {
          resetDynamicEditing()
          refreshNewContractorTable("Lender")
        }
        else if (contractTempData.dynamicEditID == "Borrower")
        {
          resetDynamicEditing()
          refreshNewContractorTable("Borrower")
        }
        else
        {
          refreshRows.append(contractTempData.dynamicEditCell)
          resetDynamicEditing()
        }
      }
      
      let type = newContract.type.toString()
      
      switch indexPath.section
      {
        case 0:
          if (indexPath.row == 0)
          {
            contractTempData.dynamicEditID = "Title"
            contractTempData.dynamicEditCell = indexPath
            contractTempData.dynamicallyEditing = true
          }
          else
          {
            fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 1:
          switch indexPath.row
          {
            case 0:
              contractTempData.dynamicEditID = "MonetaryValue"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 1:
              contractTempData.dynamicEditID = "TipPercentage"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 2:
              contractTempData.dynamicEditID = "IntrestPercentage"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            default:
              fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 2:
          if (indexPath.row == 0)
          {
            //If displaing the lenders, update temporary and new contract and stop displaying lenders.  Otherwise update contracteeTemporary and start displaying lenders.
            let row: [AnyObject] = [lenderTableIndexPath]
            
            if (contractTempData.displayingLenders)
            {
              contractTempData.displayingLenders = false
              tableView.beginUpdates()
              tableView.deleteRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
              tableView.endUpdates()
            }
            else
            {
              if (temporaryContract.lenderShares == nil)
              {
                if (temporaryContract.borrowerShares != nil)
                {
                  temporaryContract.lenderShares = temporaryContract.borrowerShares
                }
                else
                {
                  temporaryContract.lenderShares = Shares.Equal
                }
              }
              
              contractTempData.displayingLenders = true
              tableView.beginUpdates()
              tableView.insertRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
              tableView.endUpdates()
            }
          }
          else
          {
            fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 3:
          if (indexPath.row == 0)
          {
            //If displaing the borrowers, update temporary and new contract and stop displaying borrowers.  Otherwise update contracteeTemporary and start displaying borrowers.
            let row: [AnyObject] = [borrowerTableIndexPath]
            
            if (contractTempData.displayingBorrowers)
            {
              contractTempData.displayingBorrowers = false
              tableView.beginUpdates()
              tableView.deleteRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
              tableView.endUpdates()
            }
            else
            {
              if (temporaryContract.borrowerShares == nil)
              {
                if (temporaryContract.lenderShares != nil)
                {
                  temporaryContract.borrowerShares = temporaryContract.lenderShares
                }
                else
                {
                  temporaryContract.borrowerShares = Shares.Equal
                }
              }
              
              contractTempData.displayingBorrowers = true
              tableView.beginUpdates()
              tableView.insertRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
              tableView.endUpdates()
            }
          }
          else
          {
            fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 4:
          if (indexPath.row == 0)
          {
            contractTempData.dynamicEditID = "DueDate"
            contractTempData.dynamicEditCell = indexPath
            contractTempData.dynamicallyEditing = true
          }
          else if (indexPath.row == 1)
          {
            contractTempData.dynamicEditID = "DueTime"
            contractTempData.dynamicEditCell = indexPath
            contractTempData.dynamicallyEditing = true
          }
          else
          {
            fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 5:
          switch indexPath.row
          {
            case 0:
              //If displaing the alert settings, update temporary and new contract and stop displaying alert settings.  Otherwise update contracteeTemporary and start displaying alert settings.
              var rows: [AnyObject] = []
              var count = 5
              
              if (contractTempData.displayAlertRepeatSettings)
              {
                count += 3
              }
              
              for i in 1...count
              {
                rows.append(NSIndexPath(forRow: i, inSection: 5))
              }
              
              if (contractTempData.displayAlertSettings)
              {
                contractTempData.displayAlertSettings = false
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
              else
              {
                contractTempData.displayAlertSettings = true
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
            case 1:
              contractTempData.dynamicEditID = "AlertDate"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 2:
              contractTempData.dynamicEditID = "AlertTime"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 3:
              contractTempData.dynamicEditID = "AlertTone"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 4:
              contractTempData.dynamicEditID = "AlertNagRate"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 5:
              //If displaing the alert Repeat settings, update temporary and new contract and stop displaying alert settings.  Otherwise update contracteeTemporary and start displaying alert Repeat settings.
              var rows: [AnyObject] = []
              
              for i in 6...8
              {
                rows.append(NSIndexPath(forRow: i, inSection: 5))
              }
              
              if (contractTempData.displayAlertRepeatSettings)
              {
                contractTempData.displayAlertRepeatSettings = false
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
              else
              {
                contractTempData.displayAlertRepeatSettings = true
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
            case 6:
              contractTempData.dynamicEditID = "AlertRepeatRate"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            case 7:
              contractTempData.dynamicEditID = "AlertRepeatDate"
              contractTempData.dynamicEditCell = indexPath
              contractTempData.dynamicallyEditing = true
            default:
              fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        break
        default:
          fatalError("there are only 3 sections, not \(indexPath.section), in New Contract \(type)'s form.")
      }
      
      refreshRows.append(indexPath)
      refreshNewContractCells(refreshRows)
    }
  }
  
  
  
  //MARK: New Item Contract Logic
  class func newContractItemViewDidLoad(view: NewContractController)
  {
    
  }
  
  class func newContractItemViewWillDisapear(view: NewContractController)
  {
    
  }
  
  class func newContractItemRowCount(section: Int) -> (Int)
  {
    return 0
  }
  
  class func newContractItemRowHeight(indexPath: NSIndexPath) -> (CGFloat)
  {
    return CGFloat()
  }
  
  class func newContractItemCreateCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractItemUpdateCell(#cell: UITableViewCell, indexPath: NSIndexPath)
  {
    
  }
  
  class func newContractItemRowSelection(#tableView: UITableView, indexPath: NSIndexPath)
  {
    
  }
  
  
  
  //MARK: New Service Contract Logic
  class func newContractServiceViewDidLoad(view: NewContractController)
  {
    
  }
  
  class func newContractServiceViewWillDisappear(view: NewContractController)
  {
    
  }
  
  class func newContractServiceRowCount(section: Int) -> (Int)
  {
    return 0
  }
  
  class func newContractServiceRowHeight(indexPath: NSIndexPath) -> (CGFloat)
  {
    return CGFloat()
  }
  
  class func newContractServiceCreateCell(#tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractServiceUpdateCell(#cell: UITableViewCell, indexPath: NSIndexPath)
  {
    
  }
  
  class func newContractServiceRowSelection(#tableView: UITableView, indexPath: NSIndexPath)
  {
    
  }
  
  
  
  //MARK: New Contract Lender And Borrower Logic
  class func newContractorViewDidLoad(#view: UIViewController, table: UITableView, contractorType: String)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "refreshTable", name:"RefreshNew" + contractorType + "Table", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    
    //Register Table.
    table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    //Initialzie the Table.
    table.estimatedRowHeight = 44.0
    table.rowHeight = UITableViewAutomaticDimension
    var nib = UINib(nibName: "EditContractorFixedCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditContractorFixedCell")
    nib = UINib(nibName: "EditContractorPercentageCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditContractorPercentageCell")
    nib = UINib(nibName: "EditContractorPartCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditContractorPartCell")
    nib = UINib(nibName: "EditContractorEqualCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditContractorEqualCell")
    nib = UINib(nibName: "ContractorEqualFixedCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "ContractorEqualFixedCell")
    nib = UINib(nibName: "ContractorPartPercentageCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "ContractorPartPercentageCell")
    
    nib = UINib(nibName: "EditSelfFixedCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditSelfFixedCell")
    nib = UINib(nibName: "EditSelfPercentageCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditSelfPercentageCell")
    nib = UINib(nibName: "EditSelfPartCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "EditSelfPartCell")
    nib = UINib(nibName: "SelfEqualFixedCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "SelfEqualFixedCell")
    nib = UINib(nibName: "SelfPartPercentageCell", bundle: nil)
    table.registerNib(nib, forCellReuseIdentifier: "SelfPartPercentageCell")
  }
  
  class func newContractorViewWillDisappear(#view: UIViewController, contractorType: String)
  {
    NSNotificationCenter.defaultCenter().removeObserver(view, name:"RefreshNew" + contractorType + "Table", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(view, name: UIKeyboardWillShowNotification, object: nil)
  }
  
  class func updateShares(#sender: UISegmentedControl, contractorType: String)
  {
    var previousShare: Int
    
    if (contractorType == "Lender")
    {
      previousShare = temporaryContract.lenderShares.rawValue
    }
    else
    {
      previousShare = temporaryContract.borrowerShares.rawValue
    }
    
    let newShare: Shares = Shares(rawValue: sender.selectedSegmentIndex)!
    
    if (contractorType == "Lender")
    {
      temporaryContract.lenderShares = newShare
    }
    else
    {
      temporaryContract.borrowerShares = newShare
    }
    
    if (failedToSaveDynamicChanges())
    {
      sender.selectedSegmentIndex = previousShare
      return
    }
    
    resetDynamicEditing()
    refreshNewContractors()
  }
  
  class func newContractRowCount(#section: Int, contractorType: String) -> (Int)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (section > 0)
    {
      fatalError("There is only 1 section, not \(section), in the New Contract Lender's table.")
    }
    
    var count: Int
    
    if (contractorType == "Lender")
    {
      count = 1 + contractTempData.lendersTemporary.count
      
      if (!contractTempData.lendersTemporary.hasKey("@User@"))
      {
        count++
      }
    }
    else
    {
      count = 1 + contractTempData.borrowersTemporary.count
      
      if (!contractTempData.borrowersTemporary.hasKey("@User@"))
      {
        count++
      }
    }
    
    return count
  }
  
  class func newContractorRowHeight(#indexPath: NSIndexPath, contractorType: String) -> (CGFloat)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in New Contract " + contractorType + "'s table.")
    }
    
    if (data.mainScreenWidth < iPhone4sHeight)
    {
      if (isNotHeaderRow(contractorType, indexPath))
      {
        return CGFloat(84)
      }
    }
    
    return CGFloat(44)
  }
  
  class func newContractorsCreateCell(tableView: UITableView, _ indexPath: NSIndexPath, contractorType: String) -> (UITableViewCell)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in New Contract " + contractorType + "'s table.")
    }
    
    var cell: UITableViewCell
    
    if (isAddUserHeaderRow(contractorType, indexPath))
    {
      cell = tableView.dequeueReusableCellWithIdentifier("NewSelfCell") as! UITableViewCell
    }
    else if (isNewContractorHeaderRow(contractorType, indexPath))
    {
      cell = tableView.dequeueReusableCellWithIdentifier("NewContractorCell") as! UITableViewCell
    }
    else
    {
      var shares: Shares
      var cellID: String
      var isUser = false
      
      if (contractorType == "Lender")
      {
        shares = temporaryContract.lenderShares
        isUser = (contractTempData.lendersTemporary[indexPath.row - newLenderInsertionOffset].key == "@User@")
      }
      else
      {
        shares = temporaryContract.borrowerShares
        isUser = (contractTempData.borrowersTemporary[indexPath.row - newBorrowerInsertionOffset].key == "@User@")
      }
      
      if (isUser)
      {
        cellID = "Self"
      }
      else
      {
        cellID = "Contractor"
      }
      
      if (contractTempData.dynamicallyEditing && contractTempData.dynamicEditID == contractorType && indexPath == contractTempData.dynamicEditCell)
      {
        if (cellID == "Self" && shares == Shares.Equal)
        {
          cellID = "SelfEqualFixedCell"
        }
        else
        {
          cellID = "Edit" + cellID + shares.toString() + "Cell"
        }
      }
      else
      {
        if (shares =| [Shares.Equal, Shares.Fixed])
        {
          cellID += "EqualFixedCell"
        }
        else
        {
          cellID += "PartPercentageCell"
        }
      }
      
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell
    }
    
    newContractorsUpdateCell(cell, indexPath, contractorType)
    
    return cell
  }
  
  class func newContractorsUpdateCell(cell: UITableViewCell, _ indexPath: NSIndexPath, _ contractorType: String)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in New Contract " + contractorType + "'s table.")
    }
    
    if (isNotHeaderRow(contractorType, indexPath))
    {
      var contractor: (key: String, value: (parts: Int, percent: Int, fixed: Double))
      var shares: Shares
      var isUser: Bool
      
      //First, check if the contractor type being dynamically edited is the same as the contrator cell type being requested here.  If it is, set the dynamicEditCell.  If not, set dynamicEditCell to zero. Set contractor from the appropriate contractor's list.
      if (contractorType == "Lender")
      {
        shares = temporaryContract.lenderShares
        isUser = (contractTempData.lendersTemporary[indexPath.row - newLenderInsertionOffset].key == "@User@")
      }
      else
      {
        shares = temporaryContract.borrowerShares
        isUser = (contractTempData.borrowersTemporary[indexPath.row - newBorrowerInsertionOffset].key == "@User@")
      }
      
      if (dynamicallyEditingThisCell(indexPath, dynamicEditID: contractorType))
      {
        contractor = contractTempData.dynamicEditContractor
        
        switch shares
        {
          case Shares.Equal:
            var tempCell: MonetaryCell
            
            if (isUser)
            {
              tempCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! EditContractorEqualCell
              contractorCell.contractorName.text = contractor.key
              data.currentFocus = contractorCell
              tempCell = contractorCell
            }
            
            let calculatedValues = equalSharesMonetaryValue(contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack)
            }
            else
            {
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Part:
            var tempCell: EditPartCell
            
            if (isUser)
            {
              tempCell = cell as! EditSelfPartCell
            }
            else
            {
              let contractorCell = cell as! EditContractorPartCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            
            let parts = contractor.value.parts
            tempCell.monetaryShare.text = String(parts)
            let calculatedValues = partSharesMonetaryValue(Double(parts), contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              if (calculatedValues.noSharesYet)
              {
                tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack) + " (0.00)"
              }
              else
              {
                tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack)
              }
            }
            else
            {
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Percentage:
            var tempCell: EditPercentagesCell
            
            if (isUser)
            {
              tempCell = cell as! EditSelfPercentageCell
            }
            else
            {
              let contractorCell = cell as! EditContractorPercentageCell
              contractorCell.contractorName.text = contractor.key
              data.currentFocus = contractorCell
              tempCell = contractorCell
            }
            
            //Initialize percentage picker.
            let monetaryPercentage = contractor.value.percent
            initializePercentagePicker(tempCell, percentage: monetaryPercentage)
            
            let calculatedValues = percentageSharesMonetaryValue(monetaryPercentage, contractorType, indexPath)
            
            tempCell.monetaryValue.text = String(format: " %.2f", calculatedValues.given.value)
          case Shares.Fixed:
            var tempCell: EditMonetaryCell
            
            if (isUser)
            {
              tempCell = cell as! EditSelfFixedCell
            }
            else
            {
              let contractorCell = cell as! EditContractorFixedCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            let calculatedValues = fixedSharesMonetaryValue(contractor, contractorType, indexPath)
            tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            
            data.currentFocus = tempCell
        }
      }
      else
      {
        if (contractorType == "Lender")
        {
          contractor = contractTempData.lendersTemporary[indexPath.row - newLenderInsertionOffset]
        }
        else
        {
          contractor = contractTempData.borrowersTemporary[indexPath.row - newBorrowerInsertionOffset]
        }
        
        switch shares
        {
          case Shares.Equal:
            var tempCell: MonetaryCell
            
            if (isUser)
            {
              tempCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! ContractorEqualFixedCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            let calculatedValues = equalSharesMonetaryValue(contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              tempCell.monetaryValue.text = String(format: " %.2f", calculatedValues.slack)
            }
            else
            {
              tempCell.monetaryValue.text = String(format: " %.2f", calculatedValues.given)
            }
          case Shares.Part:
            var tempCell: PartPercentageCell
            
            if (isUser)
            {
              tempCell = cell as! SelfPartPercentageCell
            }
            else
            {
              let contractorCell = cell as! ContractorPartPercentageCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            let parts = contractor.value.parts
            let calculatedValues = partSharesMonetaryValue(Double(parts), contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              if (calculatedValues.noSharesYet)
              {
                tempCell.monetaryShare.text = "1 (0)"
                tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack) + " (0.00)"
              }
              else
              {
                tempCell.monetaryShare.text = String(parts)
                tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack)
              }
            }
            else
            {
              tempCell.monetaryShare.text = String(parts)
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Percentage:
            var tempCell: PartPercentageCell
            
            if (isUser)
            {
              tempCell = cell as! SelfPartPercentageCell
            }
            else
            {
              let contractorCell = cell as! ContractorPartPercentageCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            let monetaryPercentage = contractor.value.percent
            let calculatedValues = percentageSharesMonetaryValue(monetaryPercentage, contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath) && calculatedValues.slack.percentage != calculatedValues.given.percentage)
            {
              tempCell.monetaryShare.text = "\(calculatedValues.slack.percentage) (\(calculatedValues.given.percentage)) %"
              tempCell.monetaryValue.text = String(format: " %.2f", calculatedValues.slack.value) + String(format: " (%.2f", calculatedValues.given.value) + ")"
            }
            else
            {
              tempCell.monetaryShare.text = String(calculatedValues.given.percentage) + "%"
              tempCell.monetaryValue.text = String(format: " %.2f", calculatedValues.given.value)
            }
          case Shares.Fixed:
            var tempCell: MonetaryCell
            
            if (isUser)
            {
              tempCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! ContractorEqualFixedCell
              contractorCell.contractorName.text = contractor.key
              tempCell = contractorCell
            }
            
            let calculatedValues = fixedSharesMonetaryValue(contractor, contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath) && calculatedValues.slack != calculatedValues.given)
            {
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.slack) + String(format: " (%.2f", calculatedValues.given) + ")"
            }
            else
            {
              tempCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            }
        }
      }
      
      //Set the currency button's text, then determine if this is the cell contains the contractor marked as the designated "Slack Taker" (includes unallocated monetaryValue on top of their own value, if any), by compare this cell's row against temporaryData.takeUpSlackRow.
      let tempCell = cell as! ContractorCell
      let currency = data.currency.rawValue
      tempCell.currency.setTitle(currency, forState: UIControlState.Normal)
      
      if (contractorType == "Lender")
      {
        tempCell.isLenderCell = true
        tempCell.row = indexPath.row - newLenderInsertionOffset
      }
      else
      {
        tempCell.isLenderCell = false
        tempCell.row = indexPath.row - newBorrowerInsertionOffset
      }
      
      if (isSlackRow(contractorType, indexPath))
      {
        if let image = UIImage(named: "Radio Button On.png")
        {
          tempCell.takeUpSlack.setImage(image, forState: UIControlState.Normal)
        }
      }
      else
      {
        if let image = UIImage(named: "Radio Button Off.png")
        {
          tempCell.takeUpSlack.setImage(image, forState: UIControlState.Normal)
        }
      }
    }
  }
  
  class func newContractorsRowSelection(tableView: UITableView, _ indexPath: NSIndexPath, contractorType: String)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (indexPath.section > 0)
    {
      fatalError("There is only 1 section, not \(indexPath.section), in the New Contract Lenders table.")
    }
    
    //Save any changes made by dynamic editing. If the user attempted to use the same name twice for a lender or borrower, ignore all other actions and request that they make the name unique.
    if (failedToSaveDynamicChanges())
    {
      return
    }
    
    contractTempData.adjustForKeyboard = contractTempData.dynamicallyEditing
    
    if (contractTempData.dynamicallyEditing)
    {
      if (contractTempData.dynamicEditID != contractorType)
      {
        if (contractTempData.dynamicEditID == "Lender")
        {
          resetDynamicEditing()
          refreshNewContractorTable("Lender")
        }
        else if (contractTempData.dynamicEditID == "Borrower")
        {
          resetDynamicEditing()
          refreshNewContractorTable("Borrower")
        }
        else
        {
          let refreshRows = [contractTempData.dynamicEditCell]
          resetDynamicEditing()
          refreshNewContractCells(refreshRows)
        }
      }
    }
    
    //Then set dynamic editing
    contractTempData.dynamicEditID = contractorType
    contractTempData.dynamicallyEditing = true
    var contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>
    
    if (contractorType == "Lender")
    {
      contractors = contractTempData.lendersTemporary
    }
    else
    {
      contractors = contractTempData.borrowersTemporary
    }
    
    if (isAddUserHeaderRow(contractorType, indexPath))
    {
      //Add the user to the contractors list.
      let contractor = (key: "@User@", value: (parts: Int(0), percent: Int(0), fixed: Double(0)))
      
      addContractor(contractorType, contractor, contractors)
    }
    else if (isNewContractorHeaderRow(contractorType, indexPath))
    {
      //Since the NewContractorCell was tapped on, add a new contractor to the begining of the appropirate list and set dynamic editing accordingly.
      
      //First, generate a unique key for the new Lender based on the current number of lenders.
      var contractorID = contractorType + " "
      
      NamingLoop : for i in 1...contractors.count + 1
      {
        let temporaryID = contractorID + "\(i)"
        
        if (!contractors.hasKey(temporaryID))
        {
          contractorID = temporaryID
          break NamingLoop
        }
      }
      
      //Then add it to the contractors list, update the either lendersTemporary or BorrowersTemporary, dynamicEditCell, and temporaryData, and reload table to update changes.
      let contractor = (key: contractorID, value: (parts: Int(0), percent: Int(0), fixed: Double(0)))
      
      addContractor(contractorType, contractor, contractors)
      
      var row: [AnyObject] = [contractTempData.dynamicEditCell]
      tableView.beginUpdates()
      tableView.insertRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
      tableView.endUpdates()
    }
    else
    {
      //Otherwise, if an exsisting contractor has been seleced, set the dynamicEditCell to the current indexPath.
      contractTempData.dynamicEditCell = indexPath
      
      if (contractorType == "Lender")
      {
        contractTempData.dynamicEditContractor = contractors[indexPath.row - newLenderInsertionOffset]
      }
      else
      {
        contractTempData.dynamicEditContractor = contractors[indexPath.row - newBorrowerInsertionOffset]
      }
    }
    
    refreshNewContractorTable(contractorType)
  }
  
  class func addContractor(contractorType: String, _ contractor: (String, (parts: Int, percent: Int, fixed: Double)), var _ contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>)
  {
    //Update dynamicEditContractor, dynamicEditCell, and either lendersTemporary and lenderSlackRow or BorrowersTemporary and borrowerSlackRow
    contractTempData.dynamicEditContractor = contractor
    contractors.insert(atIndex: 0, newElement: contractor)
    
    if (contractorType == "Lender")
    {
      contractTempData.lendersTemporary = contractors
      contractTempData.dynamicEditCell = newLenderInsertionIndexPath
      contractTempData.lenderSlackRow++
    }
    else
    {
      contractTempData.borrowersTemporary = contractors
      contractTempData.dynamicEditCell = newBorrowerInsertionIndexPath
      contractTempData.borrowerSlackRow++
    }
  }
  
  
  
  //MARK: Contract Alert Repeat Functions
  class func changeRepeatType(sender: UISegmentedControl)
  {
    temporaryContract.alertRepeatType = AlertRepeatType(rawValue: sender.selectedSegmentIndex)!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func editRepeatPattern()
  {
    if (contractTempData.alertRepeatCellType.isRate())
    {
      swapAlertRepeatType()
    }
  }
  
  class func editRepeatRate()
  {
    if (contractTempData.alertRepeatCellType.isPattern())
    {
      swapAlertRepeatType()
    }
  }
  
  private class func swapAlertRepeatType()
  {
    contractTempData.alertRepeatCellType = contractTempData.alertRepeatCellType.swapPatternRate()
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleFromCompleation(sender: UISwitch)
  {
    temporaryContract.repeatFromCompleation = sender.on
  }
  
  class func toggleWeekdays(sender: EditAlertRepeatDaysCell)
  {
    contractTempData.alertRepeatDaysPattern.monday=!
    contractTempData.alertRepeatDaysPattern.tuesday=!
    contractTempData.alertRepeatDaysPattern.wednesday=!
    contractTempData.alertRepeatDaysPattern.thursday=!
    contractTempData.alertRepeatDaysPattern.friday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleWeekends(sender: EditAlertRepeatDaysCell)
  {
    contractTempData.alertRepeatDaysPattern.sunday=!
    contractTempData.alertRepeatDaysPattern.sunday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleMonday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.monday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleTuesday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.tuesday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleWednesday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.wednesday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleThursday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.thursday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleFriday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.friday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleSaturday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.saturday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleSunday(sender: UIButton)
  {
    contractTempData.alertRepeatDaysPattern.sunday=!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func setRepeatDayButtonImage(#state: Bool, button: UIButton)
  {
    if (state)
    {
      if let image = UIImage(named: "Checkbox Checked.png")
      {
        button.setImage(image, forState: UIControlState.Normal)
      }
    }
    else
    {
      if let image = UIImage(named: "Checkbox Unchecked.png")
      {
        button.setImage(image, forState: UIControlState.Normal)
      }
    }
  }
  
  
  
  //MARK: - Utility Functions
  
  //MARK: Dynamic Editing Functions
  class func failedToSaveDynamicChanges() -> (Bool)
  {
    //If dynamically editing make sure temporaryContract is uptodate.
    if (contractTempData.dynamicallyEditing)
    {
      let type = temporaryContract.type
      let editRow = contractTempData.dynamicEditCell.row
      
      switch contractTempData.dynamicEditID
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
        case "DueDate", "DueTime":
          temporaryContract.dateDue = contractTempData.dynamicEditValue as! NSDate
        case "AlertDate", "AlertTime":
          temporaryContract.alertDate = contractTempData.dynamicEditValue as! NSDate
        case "AlertTone":
          temporaryContract.alertTone = contractTempData.dynamicEditValue as! AlertTone
        case "AlertNagRate":
          temporaryContract.alertNagRate = contractTempData.dynamicEditValue as! AlertNagRate
        case "AlertRepeatRate":
          var pattern: Any
          var interval: Any
          var rate: Int
          
          switch temporaryContract.alertRepeatType
          {
            case AlertRepeatType.Simple:
              pattern = 0
              interval = contractTempData.alertRepeatSimpleInterval
              rate = contractTempData.alertRepeatSimpleRate
            case AlertRepeatType.Month:
              pattern = contractTempData.alertRepeatMonthPattern
              interval = contractTempData.alertRepeatMonthInterval
              rate = contractTempData.alertRepeatMonthRate
            case AlertRepeatType.Days:
              pattern = contractTempData.alertRepeatDaysPattern
              interval = 0
              rate = contractTempData.alertRepeatDaysRate
          }
          
          temporaryContract.alertRepeatPattern = pattern
          temporaryContract.alertRepeatInterval = interval
          temporaryContract.alertRepeatRate = rate
        case "AlertRepeatDate":
          temporaryContract.alertRepeatDate = contractTempData.dynamicEditValue as! NSDate
        default:
          if (data.debugging)
          {
            fatalError("There is no Dynamic Edit ID: \(contractTempData.dynamicEditID).")
          }
      }
    }
    
    
    //Update the new contract with data from temporary contract.
    newContract.overWrite(temporaryContract)
    return false
  }
  
  class func updateContractors() -> (Bool)
  {
    //If the user was dynamically editing a contractor and attempted to use the same name twice, ignore all other actions and request that they make the name unique.
    if (contractTempData.dynamicEditID =| ["Lender", "Borrower"])
    {
      var contractor = contractTempData.dynamicEditContractor
      var index: Int
      var contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>
      
      if (contractTempData.dynamicEditID == "Lender")
      {
        contractors = contractTempData.lendersTemporary
        index = contractTempData.dynamicEditCell.row - newLenderInsertionOffset
      }
      else
      {
        contractors = contractTempData.borrowersTemporary
        index = contractTempData.dynamicEditCell.row - newBorrowerInsertionOffset
      }
      
      //Find if the contractor's name already exists at some index keyIndex in the appropirate list.
      let name = contractor.key
      let keyIndex = contractors.getIndex(forKey: name)
      
      if (keyIndex == nil)
      {
        //The contractor's name is new and exists nowhere in the list. Therefore the user must have changed the contractor's name, so update the appropriate list.
        contractors.update(keyAtIndex: index, withNewKey: contractor.key)
      }
      else if (index == keyIndex)
      {
        //The contractor's name is the same as it was before. Therefore the user must have changed the contractor's value, update the appropriate list.
        contractors.update(valueAtIndex: index, withNewValue: contractor.value)
      }
      else
      {
        //The contractor's name matches another contractor's name somehwere else in the list.  Warn the user and ask them to uniquely identify the current contractor.  Use NSNotificationCenter to request NewContractContoller to perform the segue.
        
        contractTempData.warnRefreshID = "RefreshNewContract"
        contractTempData.warnFromID = contractTempData.dynamicEditID + "NameWarning"
        contractTempData.warnToID = "NewContract"
        NSNotificationCenter.defaultCenter().postNotificationName(contractTempData.warnFromID, object: nil)
        
        return true
      }
      
      //Make usre the contractor lists in temporaryContract are updated properly.
      if (contractTempData.dynamicEditID == "Lender")
      {
        contractTempData.lendersTemporary = contractors
        
        //If a new lender has been added, add them to the lender's list in temporaryContract.
        if (contractTempData.lendersTemporary.count > temporaryContract.lenders.count)
        {
          temporaryContract.lenders.insert(atIndex: index, newKey: contractor.key, andNewValue: Double(0))
        }
        
        //Then update the monetaryValues of all the lenders in temporaryContract's lender list if using equal or part shares.  For percentage and fixed shares, just fix the monetaryValue of the newly added lender.
        switch temporaryContract.lenderShares!
        {
          case Shares.Equal:
            for i in 0..<contractTempData.lendersTemporary.count
            {
              let indexPath = NSIndexPath(forRow: i + 1, inSection: 0)
              let calculatedValues = equalSharesMonetaryValue("Lender", indexPath)
              
              if (isSlackRow("Lender", indexPath))
              {
                temporaryContract.lenders.update(valueAtIndex: i, withNewValue: calculatedValues.slack)
              }
              else
              {
                temporaryContract.lenders.update(valueAtIndex: i, withNewValue: calculatedValues.given)
              }
            }
          case Shares.Part:
            for i in 0..<contractTempData.lendersTemporary.count
            {
              let numerator = Double(contractTempData.lendersTemporary.values[i].parts)
              let indexPath = NSIndexPath(forRow: i + 1, inSection: 0)
              let calculatedValues = partSharesMonetaryValue(numerator, "Lender", indexPath)
              
              if (isSlackRow("Lender", indexPath))
              {
                temporaryContract.lenders.update(valueAtIndex: i, withNewValue: calculatedValues.slack)
              }
              else
              {
                temporaryContract.lenders.update(valueAtIndex: i, withNewValue: calculatedValues.given)
              }
            }
          case Shares.Percentage:
            let givenPercentage = contractor.value.percent
            let indexPath = newLenderInsertionIndexPath
            let calculatedValues = percentageSharesMonetaryValue(givenPercentage, "Lender", indexPath)
            
            if (isSlackRow("Lender", indexPath))
            {
              temporaryContract.lenders.update(valueAtIndex: index, withNewValue: calculatedValues.slack.value)
            }
            else
            {
              temporaryContract.lenders.update(valueAtIndex: index, withNewValue: calculatedValues.given.value)
            }
          case Shares.Fixed:
            let indexPath = newLenderInsertionIndexPath
            let calculatedValues = fixedSharesMonetaryValue(contractor, "Lender", indexPath)
            
            if (isSlackRow("Lender", indexPath))
            {
              temporaryContract.lenders.update(valueAtIndex: index, withNewValue: calculatedValues.slack)
            }
            else
            {
              temporaryContract.lenders.update(valueAtIndex: index, withNewValue: calculatedValues.given)
            }
        }
      }
      else
      {
        contractTempData.borrowersTemporary = contractors
        
        //If a new borrower has been added, add them to the borrower's list in temporaryContract.
        if (contractTempData.borrowersTemporary.count > temporaryContract.borrowers.count)
        {
          temporaryContract.borrowers.insert(atIndex: index, newKey: contractor.key, andNewValue: Double(0))
        }
        
        //Then update the monetaryValues of all the borrowers in temporaryContract's borrower list if using equal or part shares.  For percentage and fixed shares, just fix the monetaryValue of the newly added borrower.
        switch temporaryContract.borrowerShares!
        {
        case Shares.Equal:
          for i in 0..<contractTempData.borrowersTemporary.count
          {
            let indexPath = NSIndexPath(forRow: i + 1, inSection: 0)
            let calculatedValues = equalSharesMonetaryValue("Borrower", indexPath)
            
            if (isSlackRow("Borrower", indexPath))
            {
              temporaryContract.borrowers.update(valueAtIndex: i, withNewValue: calculatedValues.slack)
            }
            else
            {
              temporaryContract.borrowers.update(valueAtIndex: i, withNewValue: calculatedValues.given)
            }
          }
        case Shares.Part:
          for i in 0..<contractTempData.borrowersTemporary.count
          {
            let numerator = Double(contractTempData.borrowersTemporary.values[i].parts)
            let indexPath = NSIndexPath(forRow: i + 1, inSection: 0)
            let calculatedValues = partSharesMonetaryValue(numerator, "Borrower", indexPath)
            
            if (isSlackRow("Borrower", indexPath))
            {
              temporaryContract.borrowers.update(valueAtIndex: i, withNewValue: calculatedValues.slack)
            }
            else
            {
              temporaryContract.borrowers.update(valueAtIndex: i, withNewValue: calculatedValues.given)
            }
          }
        case Shares.Percentage:
          let givenPercentage = contractor.value.percent
          let indexPath = newBorrowerInsertionIndexPath
          let calculatedValues = percentageSharesMonetaryValue(givenPercentage, "Borrower", indexPath)
          
          if (isSlackRow("Borrower", indexPath))
          {
            temporaryContract.borrowers.update(valueAtIndex: index, withNewValue: calculatedValues.slack.value)
          }
          else
          {
            temporaryContract.borrowers.update(valueAtIndex: index, withNewValue: calculatedValues.given.value)
          }
        case Shares.Fixed:
          let indexPath = newBorrowerInsertionIndexPath
          let calculatedValues = fixedSharesMonetaryValue(contractor, "Borrower", indexPath)
          
          if (isSlackRow("Borrower", indexPath))
          {
            temporaryContract.borrowers.update(valueAtIndex: index, withNewValue: calculatedValues.slack)
          }
          else
          {
            temporaryContract.borrowers.update(valueAtIndex: index, withNewValue: calculatedValues.given)
          }
        }
      }
    }
    
    return false
  }
  
  class func resetDynamicEditing()
  {
    contractTempData.dynamicallyEditing = false
    contractTempData.dynamicEditID = ""
    contractTempData.dynamicEditCell = NSIndexPath()
    contractTempData.dynamicEditContractor.key = ""
    contractTempData.dynamicEditContractor.value = (parts: Int(), percent: Int(), fixed: Double())
    data.currentFocus = nil
  }
  
  
  
  //MARK: Monetary Functions
  class func totalMonetaryValue() -> (Double)
  {
    var monetaryValue = temporaryContract.monetaryValue
    
    if (contractTempData.includeTip)
    {
      var tip = Double(temporaryContract.tip)
      tip /= 100
      monetaryValue *= (1 + tip)
    }
    
    return monetaryValue
  }
  
  class func equalSharesMonetaryValue(contractorType: String, _ indexPath: NSIndexPath)-> (given: Double, slack: Double)
  {
    var monetaryValue = totalMonetaryValue()
    
    //If using equal shares, change the monetary value displayed. (The actual monetary value of each lender can be changed when saving the final contract.)
    var contractorCount: Double
    
    if (contractorType == "Lender")
    {
      contractorCount = Double(contractTempData.lendersTemporary.count)
    }
    else
    {
      contractorCount = Double(contractTempData.borrowersTemporary.count)
    }
    
    var splitEqually = monetaryValue / contractorCount
    splitEqually = floor(value: splitEqually, decimals: 2)
    
    //If this contractor is the designated lender or borrower slack taker (if test: {is lender and lender slacktaker} or {is borrower and borrower slacktaker}), add on whatever remainder is left over from the total monetaryValue after it has been split equally between all lender or borrowers.
    var slackFraction: Double = 0
    
    if (isSlackRow(contractorType, indexPath))
    {
      slackFraction = monetaryValue - (splitEqually * contractorCount)
      slackFraction += splitEqually
    }
    
    return (given: splitEqually, slack: slackFraction)
  }
  
  class func partSharesMonetaryValue(numerator: Double, _ contractorType: String, _ indexPath: NSIndexPath) -> (given: Double, slack: Double, noSharesYet: Bool)
  {
    var monetaryValue = totalMonetaryValue()
    var denomenator: Double
    
    if (contractorType == "Lender")
    {
      denomenator = Double(data.totalLenderParts())
    }
    else
    {
      denomenator = Double(data.totalBorrowerParts())
    }
    
    var singlePart: Double
    
    if (denomenator == 0)
    {
      singlePart = 0
    }
    else
    {
      singlePart = monetaryValue / denomenator
      singlePart = floor(value: singlePart, decimals: 2)
    }
    
    let givenValue = numerator * singlePart
    
    //If this contractor is the designated lender or borrower slack taker (if test: {is lender and lender slacktaker} or {is borrower and borrower slacktaker}), add on whatever remainder is left over from the total monetaryValue after it has been split equally between all lender or borrowers.
    var slackValue: Double = 0
    
    if (isSlackRow(contractorType, indexPath))
    {
      slackValue = denomenator - numerator
      slackValue *= singlePart
      slackValue =- monetaryValue
    }
    
    return (given: givenValue, slack: slackValue, noSharesYet: (denomenator == 0))
  }
  
  class func percentageSharesMonetaryValue(givenPercentage: Int, _ contractorType: String, _ indexPath: NSIndexPath) -> (given: (percentage: Int, value: Double), slack: (percentage: Int, value: Double))
  {
    let monetaryValue = totalMonetaryValue()
    let givenValue = Double(givenPercentage) / 100.0 * monetaryValue
    var slackPercentage: Int = 0
    var slackValue: Double = 0

    //If this contractor is the designated lender or borrower slack taker (if test: {is lender and lender slacktaker} or {is borrower and borrower slacktaker}), add on whatever remainder is left over from the total monetaryValue after it has been split equally between all lender or borrowers.
    if (isSlackRow(contractorType, indexPath))
    {
      var unUsedPercentage: Double
      
      if (contractorType == "Lender")
      {
        unUsedPercentage = data.totalLenderPercentageUsed()
      }
      else
      {
        unUsedPercentage = data.totalBorrowerPercentageUsed()
      }
      
      unUsedPercentage =- 100
      slackPercentage = Int(unUsedPercentage)
      slackPercentage += givenPercentage
      
      unUsedPercentage /= 100
      slackValue = monetaryValue * unUsedPercentage
      slackValue += givenValue
    }
    
    return (given: (percentage: givenPercentage, value: givenValue), slack: (percentage: slackPercentage, value: slackValue))
  }
  
  class func fixedSharesMonetaryValue(contractor: (key: String, value: (parts: Int, percent: Int, fixed: Double)), _ contractorType: String, _ indexPath: NSIndexPath) -> (given: Double, slack: Double)
  {
    //If this contractor is the designated lender or borrower slack taker (if test: {is lender and lender slacktaker} or {is borrower and borrower slacktaker}), add on whatever remainder is left over from the total monetaryValue after it has been split equally between all lender or borrowers.
    var monetaryValue: Double = 0
    
    if (isSlackRow(contractorType, indexPath))
    {
      monetaryValue = totalMonetaryValue()
      var contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>
      
      if (contractorType == "Lender")
      {
        contractors = contractTempData.lendersTemporary
      }
      else
      {
        contractors = contractTempData.borrowersTemporary
      }
      
      for i in 0..<contractors.count
      {
        if (contractors[i].key != contractor.key)
        {
          monetaryValue -= contractors[i].value.fixed
        }
      }
    }
    
    return (given: contractor.value.fixed, slack: monetaryValue)
  }
  
  class func updateMonetaryParts(sender: EditPartCell)
  {
    let numerator = updateNumericalValue(sender: sender.monetaryShare, includeDecimal: false, fieldType: contractTempData.dynamicEditID)
    contractTempData.dynamicEditContractor.value.parts = Int(numerator)
    var denomenator: Int
    
    if (contractTempData.dynamicEditID == "Lender")
    {
      denomenator = data.totalLenderParts()
    }
    else
    {
      denomenator = data.totalBorrowerParts()
    }
    
    let monetaryValue = totalMonetaryValue()
    var monetaryFraction: Double
    
    if (denomenator == 0)
    {
      monetaryFraction = 0
    }
    else
    {
      monetaryFraction = (numerator / Double(denomenator)) * monetaryValue
    }
    
    sender.monetaryValue.text = String(format: "%.2f", monetaryFraction)
    contractTempData.dynamicEditContractor.value.parts = Int(numerator)
    
    refreshNewContractorTable(contractTempData.dynamicEditID)
  }
  
  class func updateMonetaryValue(sender: UITextField)
  {
    temporaryContract.monetaryValue = updateNumericalValue(sender: sender, includeDecimal: true, fieldType: "MonetaryValue")
  }
  
  class func updateFixedMonetaryValue(#sender: UITextField, contractorType: String)
  {
    contractTempData.dynamicEditContractor.value.fixed = updateNumericalValue(sender: sender, includeDecimal: true, fieldType: contractorType)
  }
  
  private class func updateNumericalValue(#sender: UITextField, includeDecimal: Bool, fieldType: String) -> (Double)
  {
    //Whenever the user changes the contract monetary value, update temporaryContract.monetaryValue.
    
    //First, eliminate any characters that are not numbers from contractMonetaryValue.text. (Note: Since this is being done in real time, this effectively prevents the user from inputing any non-number characters.)
    var textualNumericalValue = ""
    
    for character in sender.text
    {
      switch character
      {
      case "0"..."9":
        textualNumericalValue.append(character)
      default:
        continue
      }
    }
    
    var numericalValue = textualNumericalValue.doubleValue
    
    //Next, if includeDecimal is true format sender.text so that it includes a decimal ('.') and any ',' as appropirate.  Otherwise display numericalValue in sender.text as an integer number.
    if (includeDecimal)
    {
      //Divide monetaryValue by 100 to move the decimal point into postition, then format monetaryPreText so it includes said decimal.
      numericalValue /= 100
      
      //If sender is a Lender or Borrower textbox, and if numericalValues is greater than the remainder of the contract's monetary value after all other contractor's values are subtracted, reduce numericalValue.
      if (fieldType =| ["Lender", "Borrower"])
      {
        var totalMonetaryValueUsed: Double
        
        if (fieldType == "Lender")
        {
          totalMonetaryValueUsed = data.totalLenderFixedUsed()
        }
        else
        {
          totalMonetaryValueUsed = data.totalBorrowerFixedUsed()
        }
        
        let remainder = totalMonetaryValue() - totalMonetaryValueUsed
        
        if (numericalValue > remainder)
        {
          numericalValue = remainder
        }
      }
      
      sender.text = data.currencyFormatter.stringFromNumber(numericalValue)
    }
    else
    {
      sender.text = String(Int(numericalValue))
    }
    
    return numericalValue
  }
  
  class func displayCalculator(shouldDisplay: Bool)
  {
    contractTempData.displayCalculator = shouldDisplay
    
    if (!shouldDisplay)
    {
      calculateValue()
    }
    
    refreshNewContractCells([contractTempData.dynamicEditCell])
  }
  
  class func performOperation(operation: Operation) -> (String)
  {
    if (contractTempData.calculatorValue != nil)
    {
      calculateValue()
    }
    
    contractTempData.calculatorValue = temporaryContract.monetaryValue
    temporaryContract.monetaryValue = Double(0)
    contractTempData.calculatorOperator = operation
    return "0.00"
  }
  
  class func calculateValue() -> (String)
  {
    if let previousValue = contractTempData.calculatorValue
    {
      let currentValue = temporaryContract.monetaryValue
      var newValue: Double
      
      switch contractTempData.calculatorOperator
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
      
      contractTempData.calculatorValue = nil
      temporaryContract.monetaryValue = newValue
      return String(format: "%.2f", newValue)
    }
    else
    {
      let monetaryValue = temporaryContract.monetaryValue
      return String(format: "%.2f", monetaryValue)
    }
  }
  
  class func flipToggle(#toggle: UISwitch, toggleID: String)
  {
    if (failedToSaveDynamicChanges())
    {
      toggle.setOn(!toggle.on, animated: true)
      return
    }
    
    switch toggleID
    {
      case "Tip":
        contractTempData.includeTip = toggle.on
      case "UseAlert":
        temporaryContract.useAlert = toggle.on
        contractTempData.displayAlertSettings = toggle.on
      break
      case "RepeatAlert":
        temporaryContract.repeatAlert = toggle.on
        contractTempData.displayAlertRepeatSettings = toggle.on
      case "AutoCompleteAlert":
        temporaryContract.autoCompleteAlert = toggle.on
      default:
        fatalError(toggleID + " is not a recognized toggle ID.")
    }
    
    resetDynamicEditing()
    refreshNewContract()
  }
  
  class func updateTip(#picker: PercentagePicker, didSelectRow row: Int, inComponent component: Int)
  {
    temporaryContract.tip = percentagePicker(didSelectRow: row, forComponent: component, forPercentagePicker: picker, withCap: -1)
    let refreshRows = [NSIndexPath(forRow: 0, inSection: 1)!]
    refreshNewContractCells(refreshRows)
  }
  
  
  
  //MARK: Percentage Picker Functions
  class func initializePercentagePicker(var picker: PercentagePicker, percentage: Int)
  {
    picker.current.hundredsDigit = percentage[2]
    picker.current.tensDigit = percentage[1]
    picker.current.onesDigit = percentage[0]
    
    picker.saved.hundredsDigit = picker.current.hundredsDigit
    picker.saved.tensDigit = picker.current.tensDigit
    picker.saved.onesDigit = picker.current.onesDigit
    
    let hundredsRow = picker.current.hundredsDigit + data.digits[0].count * data.loopRadius
    let tensRow = picker.current.tensDigit + data.digits[1].count * data.loopRadius
    let onesRow = picker.current.onesDigit + data.digits[2].count * data.loopRadius
    
    picker.percentage.selectRow(hundredsRow, inComponent: 0, animated: false)
    picker.percentage.selectRow(tensRow, inComponent: 1, animated: false)
    picker.percentage.selectRow(onesRow, inComponent: 2, animated: false)
  }
  
  class func dynamicContractorPercentageCap() -> (Int)
  {
    var contractorPercentageUnused: Int
    
    if (contractTempData.dynamicEditID == "Lender")
    {
      contractorPercentageUnused = 100 - Int(data.totalLenderPercentageUsed())
    }
    else
    {
      contractorPercentageUnused = 100 - Int(data.totalBorrowerPercentageUsed())
    }
    
    return contractorPercentageUnused
  }
  
  class func percentagePicker(titleForRow row: Int, forComponent component: Int) -> (String!)
  {
    let rowCount = data.digits[component].count
    let rowTitle = row % rowCount
    return data.digits[component][rowTitle]
  }
  
  class func percentagePicker(rowSelected row: Int, forComponent component: Int, forPercentagePicker picker: EditPercentagesCell)
  {
    let cap = dynamicContractorPercentageCap()
    let monetaryPercentage = percentagePicker(didSelectRow: row, forComponent: component, forPercentagePicker: picker, withCap: cap)
    contractTempData.dynamicEditContractor.value.percent = monetaryPercentage
    let monetaryTotal = contractTempData.contract.monetaryValue
    let monetaryFraction = (Double(monetaryPercentage) / 100.0) * monetaryTotal
    picker.monetaryValue.text = String(format: "%.2f", monetaryFraction)
    contractTempData.dynamicEditContractor.value.percent = monetaryPercentage
  }

  
  class func percentagePicker(didSelectRow row: Int, forComponent component: Int, var forPercentagePicker picker: PercentagePicker, var withCap cap: Int) -> (Int)
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
    
    //Convert from picker row number to digit.
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
  
  
  
  //MARK: Picker Cell Functions
  class func pickerCell(componentCountForPickerID pickerID: String) -> (Int)
  {
    switch (pickerID)
    {
      case "AlertNagRate", "AlertRepeatMonthRate", "AlertRepeatDaysRate":
        return 1
      case "AlertRepeatSimple", "AlertRepeatMonthPattern":
        return 2
      default:
        fatalError(pickerID + " is not a recognized PickerID.")
    }
  }
  
  class func pickerCell(rowCountForComponent component: Int, withID pickerID: String) -> (Int)
  {
    switch (pickerID)
    {
      case "AlertNagRate":
        return 5
      case "AlertRepeatSimple":
        switch component
        {
          case 0:
            return 100
          case 1:
            return 4
          default:
            fatalError("There is no component \(component) in \(pickerID).")
        }
      case "AlertRepeatMonthPattern":
        if (component == 0)
        {
          switch contractTempData.alertRepeatMonthInterval
          {
            case Days.Monday, Days.Tuesday, Days.Wednesday, Days.Thursday, Days.Friday, Days.Saturday, Days.Sunday:
              return 6
            case Days.AnyDay:
              return 32
            case Days.Weekday:
              return 22
            case Days.WeekendDay:
              return 11
          }
        }
        else
        {
          return 10
        }
      case "AlertRepeatMonthRate", "AlertRepeatDaysRate":
        return 100
      default:
        fatalError(pickerID + " is not a recognized PickerID.")
    }
  }
  
  class func pickerCell(titleForRow row: Int, inComponent component: Int, withID pickerID: String) -> (String!)
  {
    switch (pickerID)
    {
      case "AlertNagRate":
        return AlertNagRate(rawValue: row)!.toString()
      case "AlertRepeatSimple":
        switch component
        {
          case 0:
            return String(row + 1)
          case 1:
            return TimeInterval(rawValue: row)!.toString()
          default:
            fatalError("There is no component \(component) in \(pickerID).")
        }
      case "AlertRepeatMonthPattern":
        if (component == 0)
        {
          let lastRow = pickerCell(rowCountForComponent: component, withID: pickerID) - 1
          
          if (row == lastRow)
          {
            return "Last"
          }
          else
          {
            return String(row) + numberSuffix(row)
          }
        }
        else
        {
          return Days(rawValue: row)!.toString()
        }
      case "AlertRepeatMonthRate", "AlertRepeatDaysRate":
        return String(row + 1)
      default:
        fatalError(pickerID + " is not a recognized PickerID.")
    }
  }
  
  class func pickerCell(didSelectRow row: Int, inComponent component: Int, withID pickerID: String)
  {
    switch (pickerID)
    {
      case "AlertNagRate":
        contractTempData.dynamicEditValue = AlertNagRate(rawValue: row)!
      case "AlertRepeatSimple":
        switch component
        {
          case 0:
            contractTempData.alertRepeatSimpleRate = row
          case 1:
            contractTempData.alertRepeatSimpleInterval = TimeInterval(rawValue: row)!
          default:
            fatalError("There is no component \(component) in \(pickerID).")
        }
      case "AlertRepeatMonthPattern":
        switch component
        {
          case 0:
            contractTempData.alertRepeatMonthPattern = row
          case 1:
            contractTempData.alertRepeatMonthInterval = Days(rawValue: row)!
            let newMaximum = pickerCell(rowCountForComponent: component, withID: pickerID)
            
            if (contractTempData.alertRepeatMonthPattern > newMaximum)
            {
              contractTempData.alertRepeatMonthPattern = newMaximum
            }
          default:
            fatalError("There is no component \(component) in \(pickerID).")
        }
        
        refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
      case "AlertRepeatMonthRate":
        contractTempData.alertRepeatMonthRate = row
      case "AlertRepeatDaysRate":
        contractTempData.alertRepeatDaysRate = row
      default:
        fatalError(pickerID + " is not a recognized PickerID.")
    }
  }
  
  
  
  //MARK: New Contract Cell Functions
  class func updateDynamicDate(sender: UIDatePicker)
  {
    contractTempData.dynamicEditValue = sender.date
  }
  
//  class func updateDueDate(sender: CVCalendarView)
//  {
//    temporaryData.dynamicEditValue = sender.date
//  }
  
  class func toggleCalender()
  {
    //TODO - Get Calender Working!!! (Then you can uncomment this code.)
//    temporaryData.displayDueCalender=!
//    refreshNewContractCells([temporaryData.dynamicEditCell])
  }
  
  
  
  //MARK: Misc. Utility Functions
  class func isSlackRow(contractorType: String, _ indexPath: NSIndexPath) -> (Bool)
  {
    if (contractorType == "Lender")
    {
      return (contractTempData.lenderSlackRow == (indexPath.row - newLenderInsertionOffset))
    }
    else
    {
      return (contractTempData.borrowerSlackRow == (indexPath.row - newBorrowerInsertionOffset))
    }
  }
  
  class func isAddUserHeaderRow(contractorType: String, _ indexPath: NSIndexPath) -> (Bool)
  {
    if (indexPath.row == 0)
    {
      if (contractorType == "Lender")
      {
        return (!contractTempData.lendersTemporary.hasKey("@User@"))
      }
      else
      {
        return (!contractTempData.borrowersTemporary.hasKey("@User@"))
      }
    }
    else
    {
      return false
    }
  }
  
  class func isNewContractorHeaderRow(contractorType: String, _ indexPath: NSIndexPath) -> (Bool)
  {
    if (contractorType == "Lender")
    {
      return (indexPath.row == (newLenderInsertionOffset - 1))
    }
    else
    {
      return (indexPath.row == (newBorrowerInsertionOffset - 1))
    }
  }
  
  class func isNotHeaderRow(contractorType: String, _ indexPath: NSIndexPath) -> (Bool)
  {
    if (contractorType == "Lender")
    {
      return (indexPath.row >= newLenderInsertionOffset)
    }
    else
    {
      return (indexPath.row >= newBorrowerInsertionOffset)
    }
  }
  
  class func dynamicallyEditingThisCell(indexPath: NSIndexPath, dynamicEditID id: String) -> (Bool)
  {
    if (contractTempData.dynamicallyEditing)
    {
      if (contractTempData.dynamicEditID == id)
      {
        return (contractTempData.dynamicEditCell == indexPath)
      }
    }
    
    return false
  }
  
  class func toggleContractorSlackButton(sender: ContractorCell)
  {
    if (failedToSaveDynamicChanges())
    {
      return
    }
    
    resetDynamicEditing()
    
    if (sender.isLenderCell!)
    {
      if (contractTempData.lenderSlackRow != sender.row)
      {
        contractTempData.lenderSlackRow = sender.row
        
        if let image = UIImage(named: "Radio Button On.png")
        {
          sender.takeUpSlack.setImage(image, forState: UIControlState.Normal)
        }
        
        refreshNewContractorTable("Lender")
      }
    }
    else
    {
      if (contractTempData.borrowerSlackRow != sender.row)
      {
        contractTempData.borrowerSlackRow = sender.row
        
        if let image = UIImage(named: "Radio Button On.png")
        {
          sender.takeUpSlack.setImage(image, forState: UIControlState.Normal)
        }
        
        refreshNewContractorTable("Borrower")
      }
    }
  }
  
  
  
  //MARK: Refresh New Contract View Functions
  class func refreshNewContract()
  {
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshNewContract", object: nil)
  }
  
  class func refreshNewContractCells(rows: [NSIndexPath])
  {
    var postedData: [NSObject : AnyObject] = [:]
    
    for var i = 0; i < rows.count; i++
    {
      let indexPath = rows[i]
      
      if (indexPath == lenderTableIndexPath)
      {
        refreshNewContractorTable("Lender")
      }
      else if (indexPath == borrowerTableIndexPath)
      {
        refreshNewContractorTable("Borrower")
      }
      else
      {
        postedData.updateValue(indexPath, forKey: i)
      }
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshNewContractCells", object: nil, userInfo: postedData)
    
    if (data.currentFocus != nil)
    {
      data.currentFocus.setFocus()
    }
  }
  
  class func refreshNewContractCells(#view: NewContractController, notification: NSNotification)
  {
    let table = view.tableView
    var refreshRows: [AnyObject] = []
    
    for datum in notification.userInfo!.values
    {
      refreshRows.append(datum)
    }
    
    //HACK!!! reloadRowsAtIndexPaths is a bit glitchy, a double call to it seems to ensure that it always updates properly. If Apple ever fixes it, this section may need adjusting...
    table.reloadRowsAtIndexPaths(refreshRows, withRowAnimation: UITableViewRowAnimation.None)
    table.reloadRowsAtIndexPaths(refreshRows, withRowAnimation: UITableViewRowAnimation.None)
  }
  
  class func refreshNewContractors()
  {
    if (contractTempData.displayingLenders)
    {
      refreshNewContractorTable("Lender")
    }
    
    if (contractTempData.displayingBorrowers)
    {
      refreshNewContractorTable("Borrower")
    }
  }
  
  class func refreshNewContractorTable(contractorType: String)
  {
    let notificationID = "RefreshNew" + contractorType + "Table"
    NSNotificationCenter.defaultCenter().postNotificationName(notificationID, object: nil)
    
    if (data.currentFocus != nil)
    {
      data.currentFocus.setFocus()
    }
  }
  
  class func refreshNewContractorTable(#sharesController: UISegmentedControl, table: UITableView, contractorType: String)
  {
    table.reloadData()
    var postedData: [NSObject : AnyObject]
    
    if (contractorType == "Lender")
    {
      sharesController.selectedSegmentIndex = temporaryContract.lenderShares.rawValue
      postedData = [0: lenderTableIndexPath]
    }
    else
    {
      sharesController.selectedSegmentIndex = temporaryContract.borrowerShares.rawValue
      postedData = [0: borrowerTableIndexPath]
    }
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshNewContractCells", object: nil, userInfo: postedData)
    
    if (data.currentFocus != nil)
    {
      data.currentFocus.setFocus()
    }
  }
  
  class func endWarning(sender: Segueable)
  {
    NSNotificationCenter.defaultCenter().postNotificationName(contractTempData.warnRefreshID, object: nil)
    sender.performSegue(segueFrom: contractTempData.warnFromID, segueTo: contractTempData.warnToID)
  }
  
  class func keyboardWillShow(#newContractor: NewContractors, notification: NSNotification)
  {
    if (contractTempData.adjustForKeyboard)
    {
      let postedData = notification.userInfo!
      let keyboardNSSize: NSValue = postedData[UIKeyboardFrameEndUserInfoKey]! as! NSValue
      
      var userInfo: [NSObject : AnyObject] = [:]
      userInfo.updateValue(keyboardNSSize, forKey: "KeyboardNSSize")
      userInfo.updateValue(newContractor, forKey: "ContractorView")
      userInfo.updateValue(newContractor.contractorsList, forKey: "ContractorTable")
      
      NSNotificationCenter.defaultCenter().postNotificationName("NewContractKeyboardWillShow", object: nil, userInfo: userInfo)
    }
  }
  
  class func keyboardWillShow(#newContractController: NewContractController, notification: NSNotification)
  {
    if (contractTempData.adjustForKeyboard)
    {
//      let postedData = notification.userInfo!
//      let keyboardNSSize: NSValue = postedData[UIKeyboardFrameEndUserInfoKey]! as NSValue
//      let keyboardSize = keyboardNSSize.CGRectValue().size
//      
//      var cellBase: CGPoint
//      var cellHeight: CGFloat
//      
//      switch temporaryData.dynamicEditID
//      {
//      case "Title", "MonetaryValue":
//        let cell = table.cellForRowAtIndexPath(temporaryData.dynamicEditCell)!
//        cellBase = cell.frame.origin
//        cellHeight = cell.frame.height
//      case "Lender", "Borrower":
//        var offset: Int
//        var indexPath: NSIndexPath
//        
//        if (temporaryData.dynamicEditID == "Lender")
//        {
//          offset = newLenderInsertionOffset
//          indexPath = lenderTableIndexPath
//        }
//        else
//        {
//          offset = newBorrowerInsertionOffset
//          indexPath = borrowerTableIndexPath
//        }
//        
//        let cell = table.cellForRowAtIndexPath(indexPath)
//        var cellXOriginPoint: CGFloat = 0
//        cellXOriginPoint += 73
//        cellXOriginPoint += temporaryData.dynamicEditCell.row * 44
//        
//        if (data.mainScreenWidth < iPhone4sHeight && temporaryData.dynamicEditCell.row >= offset)
//        {
//          cellXOriginPoint += (temporaryData.dynamicEditCell.row - offset + 1) * 40
//          cellHeight = 84
//        }
//        else
//        {
//          cellHeight = 44
//        }
//        
//        cellBase = CGPointMake(cellXOriginPoint, 0)
//      default:
//        fatalError("Cell: \(temporaryData.dynamicEditID) does not contain a text field.")
//      }
//      
//      var visiblePortionOfTable = table.frame
//      visiblePortionOfTable.size.height -= keyboardSize.height
//      println("Visible Portion Of Table Height: \(visiblePortionOfTable.height)")
//      println("Cell Base X Coordinate: \(cellBase.x)")
//      
//      if (!CGRectContainsPoint(visiblePortionOfTable, cellBase))
//      {
//        let yHeight = cellBase.y - visiblePortionOfTable.size.height + cellHeight
//        println("yHeight: \(yHeight)")
//        let scrollPoint = CGPointMake(0.0, yHeight)
//        
//        temporaryData.scrollResetPoint = table.contentOffset
//        table.setContentOffset(scrollPoint, animated: true)
//      }
      
      let table = newContractController.tableView
      let postedData = notification.userInfo!
      let keyboardNSSize: NSValue = postedData["KeyboardNSSize"]! as! NSValue
      let keyboardSize = keyboardNSSize.CGRectValue().size
      
      var cellRectangle: CGRect
      
      switch contractTempData.dynamicEditID
      {
        case "Title", "MonetaryValue":
          cellRectangle = table.rectForRowAtIndexPath(contractTempData.dynamicEditCell)
        case "Lender", "Borrower":
          let contractorTable = postedData["ContractorTable"] as! UITableView
          let tableCellRectangle = contractorTable.rectForRowAtIndexPath(contractTempData.dynamicEditCell)
          cellRectangle = newContractController.view.convertRect(tableCellRectangle, fromView: table.superview)
        default:
          fatalError("Cell: \(contractTempData.dynamicEditID) does not contain a text field.")
      }
      
      var visiblePortionOfTable = newContractController.view.frame
      visiblePortionOfTable.size.height -= keyboardSize.height
      println("Visible Portion Of Table Height: \(visiblePortionOfTable.height)")
      
      if (!CGRectContainsRect(cellRectangle, visiblePortionOfTable))
      {
        println("Cell Rectangle Height: \(cellRectangle.height)")
        let scrollPoint = CGPointMake(0.0, cellRectangle.height)
        
        contractTempData.scrollResetPoint = table.contentOffset
        table.setContentOffset(scrollPoint, animated: true)
      }
    }
  }
  
  class func keyboardWillHide(table: UITableView)
  {
    if (contractTempData.scrollResetPoint != nil)
    {
      table.setContentOffset(contractTempData.scrollResetPoint, animated: true)
      contractTempData.scrollResetPoint = nil
    }
  }
}
