//
//  EditContractLogic.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import Foundation
import UIKit

class EditContractLogic
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
  }
  class var dynamicEditValues: [String: Any]
  {
    get
    {
      return contractTempData.dynamicEditValues
    }
    set
    {
      contractTempData.dynamicEditValues = newValue
    }
  }
  class var toggles: [String: Bool]
  {
    get
    {
      return contractTempData.toggles
    }
    set
    {
      contractTempData.toggles = newValue
    }
  }
  class var debugData: DebugData
  {
    get
    {
      return data.debugData
    }
  }
  class var debugging: Bool
  {
    get
    {
    return debugData.debugging
    }
    set
    {
      debugData.debugging = newValue
    }
  }
  
  
  
  //MARK: - New Contract Controller Logic
  
  //MARK: General Logic Functions
  class func segueToNewContract(sender: MainInterfaceController)
  {
    data.eraseNewContractData()
    
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
  
  class func newContractViewDidLoad(view: EditContractController)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(NewContractors.refreshTable), name: "RefreshNewContract", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(EditContractController.refreshCells), name: "RefreshNewContractCells", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(NewContractors.keyboardWillShow), name: "NewContractKeyboardWillShow", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(self.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    
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
  
  class func newContractViewWillDisappear(view: EditContractController)
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
  
  class func newContractEdited(sender sender: EditContractController, save: Bool)
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
        if (contractTempData.dynamicEditTable == "Lender")
        {
          if (contractTempData.lendersTemporary.count > temporaryContract.lenders.count)
          {
            contractTempData.lendersTemporary.remove(index: 0)
            
            if (contractTempData.lenderSlackRow >= 0)
            {
              contractTempData.lenderSlackRow -= 1
            }
          }
        }
        else if (contractTempData.dynamicEditTable == "Borrower")
        {
          if (contractTempData.borrowersTemporary.count > temporaryContract.borrowers.count)
          {
            contractTempData.borrowersTemporary.remove(index: 0)
            
            if (contractTempData.borrowerSlackRow >= 0)
            {
              contractTempData.borrowerSlackRow -= 1
            }
          }
        }
      }
      
      temporaryContract.overWrite(newContract)
    }
    
    if (contractTempData.dynamicallyEditing)
    {
      //If dynamic cell editing was taking place, end it and reload the table to update the changes.
      if (contractTempData.dynamicEditTable == "Lender")
      {
        resetDynamicEditing()
        refreshNewContractorTable("Lender")
      }
      else if (contractTempData.dynamicEditTable == "Borrower")
      {
        resetDynamicEditing()
        refreshNewContractorTable("Borrower")
      }
      else
      {
//        TODO: Return here...
//        if (contractTempData.dynamicEditCell.)
//        {
//          refreshNewContractors()
//        }
        
        let refreshRows = [contractTempData.dynamicEditCell]
        resetDynamicEditing()
        refreshNewContractCells(refreshRows)
      }
    }
    else
    {
      //Return to the Main Interface
      data.eraseNewContractData()
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
        count = EditContractLogic.newContractMoneyRowCount(section)
      case Type.Item:
        count = EditContractLogic.newContractItemRowCount(section)
      case Type.Service:
        count = EditContractLogic.newContractServiceRowCount(section)
    }
    
    return count
  }

  
  class func newContractCreateCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    var cell: UITableViewCell?
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        cell = EditContractLogic.newContractMoneyCreateCell(tableView: tableView, indexPath: indexPath)
      case Type.Item:
        cell = EditContractLogic.newContractItemCreateCell(tableView: tableView, indexPath: indexPath)
      case Type.Service:
        cell = EditContractLogic.newContractServiceCreateCell(tableView: tableView, indexPath: indexPath)
    }
    
    return cell
  }
  
  class func newContractSelectRow(tableView tableView: UITableView, indexPath: NSIndexPath)
  {
    let type = iOUData.sharedInstance.newContract.type
    
    switch type
    {
      case Type.Money:
        EditContractLogic.newContractMoneyRowSelection(tableView: tableView, indexPath: indexPath)
      case Type.Item:
        EditContractLogic.newContractItemRowSelection(tableView: tableView, indexPath: indexPath)
      case Type.Service:
        EditContractLogic.newContractServiceRowSelection(tableView: tableView, indexPath: indexPath)
    }
  }
  
  
  
  //MARK: New Money Contract Logic
  class func newContractMoneyViewDidLoad(view: EditContractController)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(EditContractController.lenderNameWarning), name: "LenderNameWarning", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(EditContractController.borrowerNameWarning), name: "BorrowerNameWarning", object: nil)
    
    //Initialzie the Table.
    var nib = UINib(nibName: "EditMonetaryValueCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueCell")
    nib = UINib(nibName: "EditMonetaryValueWithCalculatorCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditMonetaryValueWithCalculatorCell")
    nib = UINib(nibName: "EditTitleCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditTitleCell")
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
    nib = UINib(nibName: "EditPickerSwitchCell", bundle: nil)
    view.tableView.registerNib(nib, forCellReuseIdentifier: "EditPickerSwitchCell")
  }
  
  class func newContractMoneyViewWillDisappear(view: EditContractController)
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
        if (toggles["DisplayingLenders"]!)
        {
          count = 2
        }
        else
        {
          count = 1
        }
      case 3:
        if (toggles["DisplayingBorrowers"]!)
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
        
        if (toggles["DisplayAlertSettings"]!)
        {
          count += 5
          
          if (toggles["DisplayAlertRepeatSettings"]!)
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
        if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
        {
          height = 84
        }
      case (1, 0):
        if (dynamicallyEditingThisCell(indexPath, inTable: "Money") && toggles["DisplayCalculator"]!)
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
        if (toggles["DisplayDueCalender"]!)
        {
          //TODO: Finish when calender is implented.
        }
        else if (data.mainScreenWidth < iPhone6Width)
        {
          height = 72
        }
        else if (dynamicallyEditingThisCell(indexPath, inTable: "Money") && data.mainScreenWidth > iPhone6Width)
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
  
  class func newContractMoneyCreateCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    var cell: UITableViewCell?
    
    if (indexPath == contractTempData.dynamicEditCell)
    {
      switch indexPath.section
      {
        case 0:
          cell = tableView.dequeueReusableCellWithIdentifier("EditTitleCell")
        case 1:
          switch indexPath.row
          {
            case 0:
              if (toggles["DisplayCalculator"]!)
              {
                cell = (tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueWithCalculatorCell"))
              }
              else
              {
                cell = tableView.dequeueReusableCellWithIdentifier("EditMonetaryValueCell")
              }
            case 1:
              cell = tableView.dequeueReusableCellWithIdentifier("EditPickerSwitchCell")
            case 2:
              cell = tableView.dequeueReusableCellWithIdentifier("EditPickerSwitchCell")
            default:
              fatalError("There is no dynamic edit cell at row: \(indexPath.row) in section:\(indexPath.section)")
          }
        case 4:
          switch indexPath.row
          {
            case 0:
              var cellID = "EditDate"
              
              if (toggles["DisplayDueCalender"]!)
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
              cell = tableView.dequeueReusableCellWithIdentifier(cellID)
            case 1:
              cell = tableView.dequeueReusableCellWithIdentifier("EditTimeCell")
            default:
              fatalError("There is no dynamic edit cell at row: \(indexPath.row) in section:\(indexPath.section)")
          }
        case 5:
          switch indexPath.row
          {
            case 1:
              var cellID = "EditDate"
              
              if (toggles["DisplayAlertCalender"]!)
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
              cell = tableView.dequeueReusableCellWithIdentifier(cellID)
            case 2:
              cell = tableView.dequeueReusableCellWithIdentifier("EditTimeCell")
            case 3:
              cell = tableView.dequeueReusableCellWithIdentifier("EditToneCell")
            case 4:
              cell = tableView.dequeueReusableCellWithIdentifier("EditPickerCell")
            case 6:
              switch temporaryContract.alertRepeatType
              {
                case AlertRepeatType.Simple:
                  cell = tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatSimpleCell")
                case AlertRepeatType.Month:
                  cell = tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatCell")
                case AlertRepeatType.Days:
                  let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
                  
                  if (cellType.isPattern())
                  {
                    cell = tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatDaysCell")
                  }
                  else
                  {
                    cell = tableView.dequeueReusableCellWithIdentifier("EditAlertRepeatCell")
                  }
              }
            case 7:
              var cellID = "EditDate"
              
              if (toggles["DisplayAlertRepeatCalender"]!)
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
              cell = tableView.dequeueReusableCellWithIdentifier(cellID)
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
  
  class func newContractMoneyUpdateCell(cell cell: UITableViewCell, indexPath: NSIndexPath)
  {
    //Debugging tool to make sure cells only get updated once per refresh.
    trackRowRefreshes(table: "Contract", index: indexPath)
    
    switch indexPath.section
    {
      case 0:
        if (indexPath.row == 0)
        {
          if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
          {
            let tempTitleCell = cell as! EditTitleCell
            tempTitleCell.contractTitle.text = temporaryContract.title
            tempTitleCell.contractType.selectedSegmentIndex = temporaryContract.type.rawValue
            data.currentFocus = tempTitleCell
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
            
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              let tempMoneyCell = cell as! EditMonetaryValueCell
              tempMoneyCell.contractCurrency.setTitle(currency, forState: UIControlState.Normal)
              let monetaryValue = temporaryContract.monetaryValue
              tempMoneyCell.monetaryValue.text = String(format: "%.2f", monetaryValue)
              data.currentFocus = tempMoneyCell
            }
            else
            {
              let status = toggles["IncludeTip"]!
              
              if (status)
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
            var tempSwitchCell = cell as! SwitchCell
            
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              let tempPickerCell = cell as! EditPickerSwitchCell
              tempPickerCell.pickerPreLabel.text = "Include Tip:"
              tempPickerCell.pickerPostLabel.text = "%"
              
              //Initialize percentage picker.
              let tip = dynamicEditValues["Tip"] as! Int
              initializePercentagePicker(tempPickerCell, percentage: tip)
            }
            else
            {
              tempSwitchCell.switchLabel.text = "\(temporaryContract.tip)%"
            }
            
            let toggleID = "IncludeTip"
            let status = toggles[toggleID]!
            tempSwitchCell.toggle.setOn(status, animated: false)
            tempSwitchCell.toggleID = toggleID
          case 2:
            var tempSwitchCell = cell as! SwitchCell
            
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              let tempPickerCell = cell as! EditPickerSwitchCell
              tempPickerCell.pickerPreLabel.text = "Interest:"
              tempPickerCell.pickerPostLabel.text = "%"
              tempPickerCell.pickerWidthConstraint.constant = CGFloat(175)
             
              //Initialize picker.
              let interest = dynamicEditValues["Interest"] as! Double
              initializePercentagePicker(tempPickerCell, percentage: interest)
            }
            else
            {
              tempSwitchCell.switchLabel.text = "\(temporaryContract.interest)%"
            }
            
            let toggleID = "IncludeInterest"
            let status = toggles[toggleID]!
            tempSwitchCell.toggle.setOn(status, animated: false)
            tempSwitchCell.toggleID = toggleID
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
            if (contractTempData.dynamicEditTable == "Contract" && indexPath.row == 0)
            {
              if (toggles["DisplayDueCalender"]!)
              {
//                let tempCalenderCell = cell as! EditDateCalenderCell
//                TODO: Finish when calender is working!!!
              }
              
              dateCell = cell as! EditDatePickerCell
            }
            else if (contractTempData.dynamicEditTable == "Contract" && indexPath.row == 1)
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
            dynamicEditValues["DueDate"] = date
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
            var tempSwitchCell = cell as! SwitchCell
            let toggleID = "UseAlert"
            let status = toggles[toggleID]!
            tempSwitchCell.toggle.setOn(status, animated: false)
            tempSwitchCell.toggleID = toggleID
          case 1, 2:
            let date = temporaryContract.alertDate
            var dateCell: EditDateCell!
            
            if (contractTempData.dynamicallyEditing == true)
            {
              if (contractTempData.dynamicEditTable == "Contract" && indexPath.row == 1)
              {
                if (toggles["DisplayAlertCalender"]!)
                {
//                  let tempCalenderCell = cell as! EditDateCalenderCell
//                  TODO: Finish when calender is working!!!
                }
                
                dateCell = (cell as! EditDateCell)
              }
              else if (contractTempData.dynamicEditTable == "Contract" && indexPath.row == 2)
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
              dynamicEditValues["AlertDueDate"] = date
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
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              let tempPickerCell = cell as! EditPickerCell
              tempPickerCell.pickerPreLabel.text = "Alert Tone"
              tempPickerCell.picker.selectRow(temporaryContract.alertTone.rawValue, inComponent: 0, animated: false)
            }
            else
            {
              cell.detailTextLabel?.text = temporaryContract.alertNagRate.toString()
            }
            break //TODO: Finish!!!
          case 4:
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              let tempPickerCell = cell as! EditPickerCell
              tempPickerCell.pickerPreLabel.text = "Alert Nag Rate"
              tempPickerCell.picker.selectRow(temporaryContract.alertNagRate.rawValue, inComponent: 0, animated: false)
            }
            else
            {
              cell.detailTextLabel?.text = temporaryContract.alertNagRate.toString()
            }
          case 5:
            var tempSwitchCell = cell as! SwitchCell
            let toggleID = "RepeatAlert"
            let status = toggles[toggleID]!
            tempSwitchCell.toggle.setOn(status, animated: false)
            tempSwitchCell.toggleID = toggleID
          case 6:
            let date = temporaryContract.dateDue
            
            if (dynamicallyEditingThisCell(indexPath, inTable: "Money"))
            {
              var repeatPattern = ""
              var repeatRate = "Every "
              
              switch temporaryContract.alertRepeatType
              {
                case AlertRepeatType.Simple:
                  let tempSimpleCell = cell as! EditAlertRepeatSimpleCell
                  
                  tempSimpleCell.fromCompleation.setOn(temporaryContract.repeatFromCompleation, animated: false)
                  
                  let rate = temporaryContract.alertRepeatRate
                  let interval = temporaryContract.alertRepeatInterval as! TimeInterval
                  tempSimpleCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  tempSimpleCell.picker.selectRow(interval.rawValue, inComponent: 1, animated: false)
                  
                  if (rate == 1)
                  {
                    repeatRate += interval.toString()
                  }
                  else
                  {
                    repeatRate += rate + " " + interval.toString() + "s"
                    
                    if (interval != TimeInterval.Day)
                    {
                      repeatRate += " on "
                      
                      switch interval
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
                  
                  tempSimpleCell.repeatRate.titleLabel?.text = repeatRate
                case AlertRepeatType.Month:
                  let tempMonthCell = cell as! EditAlertRepeatCell
                  let pattern = temporaryContract.alertRepeatPattern as! Int
                  let interval = temporaryContract.alertRepeatInterval as! Days
                  let rate = temporaryContract.alertRepeatRate
                  let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
                  
                  if (cellType.isPattern())
                  {
                    
                    tempMonthCell.picker.selectRow(pattern, inComponent: 0, animated: false)
                    tempMonthCell.picker.selectRow(interval.rawValue, inComponent: 1, animated: false)
                  }
                  else
                  {
                    tempMonthCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  }
                  
                  repeatPattern = "The " + pattern + numberSuffix(pattern) + " " + interval.toString()
                  tempMonthCell.repeatPattern.titleLabel?.text = repeatPattern
                  
                  if (temporaryContract.alertRepeatRate == 1)
                  {
                    repeatRate += "Month"
                  }
                  else
                  {
                    repeatRate += temporaryContract.alertRepeatRate + "Months"
                  }
                  
                  tempMonthCell.repeatPattern.titleLabel?.text = repeatPattern
                  tempMonthCell.repeatRate.titleLabel?.text = repeatRate
                case AlertRepeatType.Days:
                  let tempDaysCell = cell as! EditAlertRepeatCell

                  if (alertBoolFor("Monday"))
                  {
                    repeatPattern += "Mon, "
                  }
                  
                  if (alertBoolFor("Tuesday"))
                  {
                    repeatPattern += "Tue, "
                  }
                  
                  if (alertBoolFor("Wednesday"))
                  {
                    repeatPattern += "Wed, "
                  }
                  
                  if (alertBoolFor("Thursday"))
                  {
                    repeatPattern += "Thu, "
                  }
                  
                  if (alertBoolFor("Friday"))
                  {
                    repeatPattern += "Fri, "
                  }
                  
                  if (alertBoolFor("Saturday"))
                  {
                    repeatPattern += "Sat, "
                  }
                  
                  if (alertBoolFor("Sunday"))
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
                  
                  tempDaysCell.repeatPattern.titleLabel?.text = repeatPattern
                  
                  if (temporaryContract.alertRepeatRate == 1)
                  {
                    repeatRate += "Week"
                  }
                  else
                  {
                    repeatRate += temporaryContract.alertRepeatRate + "Weeks"
                  }
                  
                  tempDaysCell.repeatRate.titleLabel?.text = repeatRate
                  let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
                  
                  if (cellType.isPattern())
                  {
                    let daysCell = cell as! EditAlertRepeatDaysCell
                    
                    setCheckboxImage(state: alertBoolFor("Monday"), button: daysCell.monday)
                    setCheckboxImage(state: alertBoolFor("Tuesday"), button: daysCell.tuesday)
                    setCheckboxImage(state: alertBoolFor("Wednesday"), button: daysCell.wednesday)
                    setCheckboxImage(state: alertBoolFor("Thursday"), button: daysCell.thursday)
                    setCheckboxImage(state: alertBoolFor("Friday"), button: daysCell.friday)
                    setCheckboxImage(state: alertBoolFor("Sunday"), button: daysCell.saturday)
                    setCheckboxImage(state: alertBoolFor("Sunday"), button: daysCell.sunday)
                  }
                  else
                  {
                    let rate = temporaryContract.alertRepeatRate
                    tempDaysCell.picker.selectRow(rate, inComponent: 0, animated: false)
                  }
              }
            }
          case 7:
            let date = temporaryContract.alertRepeatDate
            
            if (contractTempData.dynamicallyEditing == true && contractTempData.dynamicEditTable == "Contract")
            {
              if (toggles["DisplayAlertCalender"]!)
              {
//                let tempCalenderCell = cell as! EditDateCalenderCell
//                TODO: Finish when calender is working!!!
              }
              
              let tempDateCell = cell as! EditDateCell
              
              if (tempDateCell.dateLabel != nil)
              {
                if (indexPath.row == 1)
                {
                  tempDateCell.dateLabel.text = "Alert Date"
                }
                else
                {
                  tempDateCell.dateLabel.text = "Alert Time"
                }
              }
              
              tempDateCell.datePicker.setDate(date, animated: false)
              dynamicEditValues["AlertDueDate"] = date
            }
            else
            {
              data.dateFormatter.dateFormat = "E MMM dd, yyyy"
              cell.detailTextLabel?.text = data.dateFormatter.stringFromDate(date)
            }
          case 8:
            var tempSwitchCell = cell as! SwitchCell
            tempSwitchCell.toggle.setOn(temporaryContract.autoCompleteAlert, animated: false)
          default:
            return
        }
      default:
        return
    }
  }
  
  class func newContractMoneyRowSelection(tableView tableView: UITableView, indexPath: NSIndexPath)
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
        
        if (contractTempData.dynamicEditTable == "Lender")
        {
          resetDynamicEditing()
          refreshNewContractorTable("Lender")
        }
        else if (contractTempData.dynamicEditTable == "Borrower")
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
      contractTempData.dynamicEditTable = "Contract"
      
      switch indexPath.section
      {
        case 0:
          if (indexPath.row == 0)
          {
            contractTempData.beginDynamicEditing()
            dynamicEditValues["Title"] = temporaryContract.title
            dynamicEditValues["Type"] = temporaryContract.type
            contractTempData.dynamicEditCell = indexPath
          }
          else
          {
            fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 1:
          switch indexPath.row
          {
            case 0:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["MonetaryValue"] = temporaryContract.monetaryValue
              contractTempData.dynamicEditCell = indexPath
            case 1:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["Tip"] = temporaryContract.tip
              contractTempData.dynamicEditCell = indexPath
            case 2:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["Interest"] = temporaryContract.interest
              contractTempData.dynamicEditCell = indexPath
            default:
              fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        case 2:
          if (indexPath.row == 0)
          {
            //If displaing the lenders, update temporary and new contract and stop displaying lenders.  Otherwise update contracteeTemporary and start displaying lenders.
            let row: [NSIndexPath] = [lenderTableIndexPath]
            
            if (toggles["DisplayingLenders"]!)
            {
              toggles["DisplayingLenders"] = false
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
              
              toggles["DisplayingLenders"] = true
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
            let row: [NSIndexPath] = [borrowerTableIndexPath]
            
            if (toggles["DisplayingBorrowers"]!)
            {
              toggles["DisplayingBorrowers"] = false
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
              
              toggles["DisplayingBorrowers"] = true
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
          if (indexPath.row =| [0, 1])
          {
            contractTempData.beginDynamicEditing()
            dynamicEditValues["DueDate"] = temporaryContract.dateDue
            contractTempData.dynamicEditCell = indexPath
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
              var rows: [NSIndexPath] = []
              var count = 5
              
              if (toggles["DisplayAlertRepeatSettings"]!)
              {
                count += 3
              }
              
              for i in 1...count
              {
                rows.append(NSIndexPath(forRow: i, inSection: 5))
              }
              
              if (toggles["DisplayAlertSettings"]!)
              {
                toggles["DisplayAlertSettings"] = false
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
              else
              {
                toggles["DisplayAlertSettings"] = true
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
            case 1, 2:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["AlertDueDate"] = temporaryContract.alertDate
              contractTempData.dynamicEditCell = indexPath
            case 3:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["AlertTone"] = temporaryContract.alertTone
              contractTempData.dynamicEditCell = indexPath
            case 4:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["AlertNagRate"] = temporaryContract.alertNagRate
              contractTempData.dynamicEditCell = indexPath
            case 5:
              //If displaing the alert Repeat settings, update temporary and new contract and stop displaying alert settings.  Otherwise update contracteeTemporary and start displaying alert Repeat settings.
              var rows: [NSIndexPath] = []
              
              for i in 6...8
              {
                rows.append(NSIndexPath(forRow: i, inSection: 5))
              }
              
              if (toggles["DisplayAlertRepeatSettings"]!)
              {
                toggles["DisplayAlertRepeatSettings"] = false
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
              else
              {
                toggles["DisplayAlertRepeatSettings"] = true
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(rows, withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
              }
            case 6:
              contractTempData.beginDynamicEditing()
              contractTempData.dynamicEditCell = indexPath
              dynamicEditValues["AlertRepeatType"] = temporaryContract.alertRepeatType
              
              switch temporaryContract.alertRepeatType
              {
                case AlertRepeatType.Simple:
                  dynamicEditValues["AlertRepeatSimpleInterval"] = temporaryContract.alertRepeatInterval
                  dynamicEditValues["AlertRepeatSimpleRate"] = temporaryContract.alertRepeatRate
                case AlertRepeatType.Month:
                  dynamicEditValues["AlertRepeatMonthPattern"] = temporaryContract.alertRepeatPattern
                  dynamicEditValues["AlertRepeatMonthInterval"] = temporaryContract.alertRepeatInterval
                  dynamicEditValues["AlertRepeatMonthRate"] = temporaryContract.alertRepeatRate
                case AlertRepeatType.Days:
                  let pattern = temporaryContract.alertRepeatPattern as! (monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, suday: Bool)

                  dynamicEditValues["Monday"] = pattern.monday
                  dynamicEditValues["Tuesday"] = pattern.tuesday
                  dynamicEditValues["Wednesday"] = pattern.wednesday
                  dynamicEditValues["Thursday"] = pattern.thursday
                  dynamicEditValues["Friday"] = pattern.friday
                  dynamicEditValues["Saturday"] = pattern.saturday
                  dynamicEditValues["Sunday"] = pattern.suday
                    
                  dynamicEditValues["AlertRepeatDaysRate"] = temporaryContract.alertRepeatRate
              }
            case 7:
              contractTempData.beginDynamicEditing()
              dynamicEditValues["AlertRepeatDate"] = temporaryContract.alertRepeatDate
              contractTempData.dynamicEditCell = indexPath
            default:
              fatalError("There is no row \(indexPath.row) in section \(indexPath.section) in New Contract \(type)'s form.")
          }
        default:
          fatalError("there are only 3 sections, not \(indexPath.section), in New Contract \(type)'s form.")
      }
      
      refreshRows.append(indexPath)
      refreshNewContractCells(refreshRows)
    }
  }
  
  
  
  //MARK: New Item Contract Logic
  class func newContractItemViewDidLoad(view: EditContractController)
  {
    
  }
  
  class func newContractItemViewWillDisapear(view: EditContractController)
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
  
  class func newContractItemCreateCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractItemUpdateCell(cell cell: UITableViewCell, indexPath: NSIndexPath)
  {
    
  }
  
  class func newContractItemRowSelection(tableView tableView: UITableView, indexPath: NSIndexPath)
  {
    
  }
  
  
  
  //MARK: New Service Contract Logic
  class func newContractServiceViewDidLoad(view: EditContractController)
  {
    
  }
  
  class func newContractServiceViewWillDisappear(view: EditContractController)
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
  
  class func newContractServiceCreateCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> (UITableViewCell?)
  {
    return nil
  }
  
  class func newContractServiceUpdateCell(cell cell: UITableViewCell, indexPath: NSIndexPath)
  {
    
  }
  
  class func newContractServiceRowSelection(tableView tableView: UITableView, indexPath: NSIndexPath)
  {
    
  }
  
  
  
  //MARK: New Contract Lender And Borrower Logic
  class func newContractorViewDidLoad(view view: UIViewController, table: UITableView, contractorType: String)
  {
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(NewContractors.refreshTable), name:"RefreshNew" + contractorType + "Table", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(view, selector: #selector(NewContractors.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    
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
  
  class func newContractorViewWillDisappear(view view: UIViewController, contractorType: String)
  {
    NSNotificationCenter.defaultCenter().removeObserver(view, name:"RefreshNew" + contractorType + "Table", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(view, name: UIKeyboardWillShowNotification, object: nil)
  }
  
  class func updateShares(sender sender: UISegmentedControl, contractorType: String)
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
  
  class func newContractRowCount(section section: Int, contractorType: String) -> (Int)
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
        count += 1
      }
    }
    else
    {
      count = 1 + contractTempData.borrowersTemporary.count
      
      if (!contractTempData.borrowersTemporary.hasKey("@User@"))
      {
        count += 1
      }
    }
    
    return count
  }
  
  class func newContractorRowHeight(indexPath indexPath: NSIndexPath, contractorType: String) -> (CGFloat)
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
      cell = tableView.dequeueReusableCellWithIdentifier("NewSelfCell")!
    }
    else if (isNewContractorHeaderRow(contractorType, indexPath))
    {
      cell = tableView.dequeueReusableCellWithIdentifier("NewContractorCell")!
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
      
      if (dynamicallyEditingThisCell(indexPath, inTable: contractorType))
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
      
      cell = tableView.dequeueReusableCellWithIdentifier(cellID)!
    }
    
    newContractorsUpdateCell(cell, indexPath, contractorType)
    
    return cell
  }
  
  class func newContractorsUpdateCell(cell: UITableViewCell, _ indexPath: NSIndexPath, _ contractorType: String)
  {
    //Debugging tool to make sure cells only get updated once per refresh.
    trackRowRefreshes(table: "Contract", index: indexPath)
    
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
      
      if (dynamicallyEditingThisCell(indexPath, inTable: contractorType))
      {
        contractor = dynamicEditValues["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
        
        switch shares
        {
          case Shares.Equal:
            var tempMoneyCell: MonetaryCell
            
            if (isUser)
            {
              tempMoneyCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! EditContractorEqualCell
              contractorCell.contractorName.text = contractor.key
              data.currentFocus = contractorCell
              tempMoneyCell = contractorCell
            }
            
            let calculatedValues = equalSharesMonetaryValue(contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              tempMoneyCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack)
            }
            else
            {
              tempMoneyCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Part:
            var tempPartCell: EditPartCell
            
            if (isUser)
            {
              tempPartCell = cell as! EditSelfPartCell
            }
            else
            {
              let contractorCell = cell as! EditContractorPartCell
              contractorCell.contractorName.text = contractor.key
              tempPartCell = contractorCell
            }
            
            
            let parts = contractor.value.parts
            tempPartCell.monetaryShare.text = String(parts)
            let calculatedValues = partSharesMonetaryValue(Double(parts), contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              if (calculatedValues.noSharesYet)
              {
                tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack) + " (0.00)"
              }
              else
              {
                tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack)
              }
            }
            else
            {
              tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Percentage:
            var tempPercentageCell: EditPercentagesCell
            
            if (isUser)
            {
              tempPercentageCell = cell as! EditSelfPercentageCell
            }
            else
            {
              let contractorCell = cell as! EditContractorPercentageCell
              contractorCell.contractorName.text = contractor.key
              data.currentFocus = contractorCell
              tempPercentageCell = contractorCell
            }
            
            //Initialize percentage picker.
            let monetaryPercentage = contractor.value.percent
            initializePercentagePicker(tempPercentageCell, percentage: monetaryPercentage)
            
            let calculatedValues = percentageSharesMonetaryValue(monetaryPercentage, contractorType, indexPath)
            
            tempPercentageCell.monetaryLabel.text = String(format: " %.2f", calculatedValues.given.value)
          case Shares.Fixed:
            var tempMoneyCell: EditMonetaryCell
            
            if (isUser)
            {
              tempMoneyCell = cell as! EditSelfFixedCell
            }
            else
            {
              let contractorCell = cell as! EditContractorFixedCell
              contractorCell.contractorName.text = contractor.key
              tempMoneyCell = contractorCell
            }
            
            let calculatedValues = fixedSharesMonetaryValue(contractor, contractorType, indexPath)
            tempMoneyCell.monetaryValue.text = String(format: "%.2f", calculatedValues.given)
            
            data.currentFocus = tempMoneyCell
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
            var tempMoneyCell: MonetaryCell
            
            if (isUser)
            {
              tempMoneyCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! ContractorEqualFixedCell
              contractorCell.contractorName.text = contractor.key
              tempMoneyCell = contractorCell
            }
            
            let calculatedValues = equalSharesMonetaryValue(contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              tempMoneyCell.monetaryLabel.text = String(format: " %.2f", calculatedValues.slack)
            }
            else
            {
              tempMoneyCell.monetaryLabel.text = String(format: " %.2f", calculatedValues.given)
            }
          case Shares.Part:
            var tempPartCell: PartPercentageCell
            
            if (isUser)
            {
              tempPartCell = cell as! SelfPartPercentageCell
            }
            else
            {
              let contractorCell = cell as! ContractorPartPercentageCell
              contractorCell.contractorName.text = contractor.key
              tempPartCell = contractorCell
            }
            
            let parts = contractor.value.parts
            let calculatedValues = partSharesMonetaryValue(Double(parts), contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath))
            {
              if (calculatedValues.noSharesYet)
              {
                tempPartCell.monetaryShare.text = "1 (0)"
                tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack) + " (0.00)"
              }
              else
              {
                tempPartCell.monetaryShare.text = String(parts)
                tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack)
              }
            }
            else
            {
              tempPartCell.monetaryShare.text = String(parts)
              tempPartCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.given)
            }
          case Shares.Percentage:
            var tempPercentageCell: PartPercentageCell
            
            if (isUser)
            {
              tempPercentageCell = cell as! SelfPartPercentageCell
            }
            else
            {
              let contractorCell = cell as! ContractorPartPercentageCell
              contractorCell.contractorName.text = contractor.key
              tempPercentageCell = contractorCell
            }
            
            let monetaryPercentage = contractor.value.percent
            let calculatedValues = percentageSharesMonetaryValue(monetaryPercentage, contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath) && calculatedValues.slack.percentage != calculatedValues.given.percentage)
            {
              tempPercentageCell.monetaryShare.text = "\(calculatedValues.slack.percentage) (\(calculatedValues.given.percentage)) %"
              tempPercentageCell.monetaryLabel.text = String(format: " %.2f", calculatedValues.slack.value) + String(format: " (%.2f", calculatedValues.given.value) + ")"
            }
            else
            {
              tempPercentageCell.monetaryShare.text = String(calculatedValues.given.percentage) + "%"
              tempPercentageCell.monetaryLabel.text = String(format: " %.2f", calculatedValues.given.value)
            }
          case Shares.Fixed:
            var tempMoneyCell: MonetaryCell
            
            if (isUser)
            {
              tempMoneyCell = cell as! SelfEqualFixedCell
            }
            else
            {
              let contractorCell = cell as! ContractorEqualFixedCell
              contractorCell.contractorName.text = contractor.key
              tempMoneyCell = contractorCell
            }
            
            let calculatedValues = fixedSharesMonetaryValue(contractor, contractorType, indexPath)
            
            if (isSlackRow(contractorType, indexPath) && calculatedValues.slack != calculatedValues.given)
            {
              tempMoneyCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.slack) + String(format: " (%.2f", calculatedValues.given) + ")"
            }
            else
            {
              tempMoneyCell.monetaryLabel.text = String(format: "%.2f", calculatedValues.given)
            }
        }
      }
      
      //Set the currency button's text, then determine if this is the cell contains the contractor marked as the designated "Slack Taker" (includes unallocated monetaryValue on top of their own value, if any), by compare this cell's row against temporaryData.takeUpSlackRow.
      let tempContractorCell = cell as! ContractorCell
      let currency = data.currency.rawValue
      tempContractorCell.currency.setTitle(currency, forState: UIControlState.Normal)
      
      if (contractorType == "Lender")
      {
        tempContractorCell.isLenderCell = true
        tempContractorCell.row = indexPath.row - newLenderInsertionOffset
      }
      else
      {
        tempContractorCell.isLenderCell = false
        tempContractorCell.row = indexPath.row - newBorrowerInsertionOffset
      }
      
      if (isSlackRow(contractorType, indexPath))
      {
        if let image = UIImage(named: "Radio Button On.png")
        {
          tempContractorCell.takeUpSlack.setImage(image, forState: UIControlState.Normal)
        }
      }
      else
      {
        if let image = UIImage(named: "Radio Button Off.png")
        {
          tempContractorCell.takeUpSlack.setImage(image, forState: UIControlState.Normal)
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
    
    toggles["AdjustForKeyboard"] = contractTempData.dynamicallyEditing
    
    if (contractTempData.dynamicallyEditing)
    {
      if (contractTempData.dynamicEditTable != contractorType)
      {
        if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
        {
          resetDynamicEditing()
          refreshNewContractorTable(contractTempData.dynamicEditTable)
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
    contractTempData.beginDynamicEditing()
    contractTempData.dynamicEditTable = contractorType
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
      
      let row: [NSIndexPath] = [contractTempData.dynamicEditCell]
      tableView.beginUpdates()
      tableView.insertRowsAtIndexPaths(row, withRowAnimation: UITableViewRowAnimation.None)
      tableView.endUpdates()
    }
    else
    {
      //Otherwise, if an exsisting contractor has been seleced, set the dynamicEditCell to the current indexPath.
      contractTempData.dynamicEditCell = indexPath
      var contractor: (key: String, value: (parts: Int, percent: Int, fixed: Double))
      
      if (contractorType == "Lender")
      {
        contractor = contractors[indexPath.row - newLenderInsertionOffset]
      }
      else
      {
        contractor = contractors[indexPath.row - newBorrowerInsertionOffset]
      }
      
      dynamicEditValues["DynamicEditContractor"] = contractor
    }
    
    refreshNewContractorTable(contractorType)
  }
  
  class func addContractor(contractorType: String, _ contractor: (key: String, value: (parts: Int, percent: Int, fixed: Double)), _ contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>)
  {
    var contractors = contractors
    
    //Update dynamicEditValue, dynamicEditCell, and either lendersTemporary and lenderSlackRow or BorrowersTemporary and borrowerSlackRow
    dynamicEditValues["DynamicEditContractor"] = contractor
    contractors.insert(atIndex: 0, newElement: contractor)
    
    if (contractorType == "Lender")
    {
      contractTempData.lendersTemporary = contractors
      contractTempData.dynamicEditCell = newLenderInsertionIndexPath
      contractTempData.lenderSlackRow += 1
    }
    else
    {
      contractTempData.borrowersTemporary = contractors
      contractTempData.dynamicEditCell = newBorrowerInsertionIndexPath
      contractTempData.borrowerSlackRow += 1
    }
  }
  
  
  
  //MARK: Contract Alert Repeat Functions
  class func changeRepeatType(sender: UISegmentedControl)
  {
    contractTempData.dynamicEditValues["AlertRepeatType"] = AlertRepeatType(rawValue: sender.selectedSegmentIndex)!
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func editRepeatPattern()
  {
    let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
    
    if (cellType.isRate())
    {
      swapAlertRepeatType()
    }
  }
  
  class func editRepeatRate()
  {
    let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
    
    if (cellType.isPattern())
    {
      swapAlertRepeatType()
    }
  }
  
  private class func swapAlertRepeatType()
  {
    let cellType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
    dynamicEditValues["AlertRepeatCellType"] = cellType.swapPatternRate()
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleFromCompleation(sender: UISwitch)
  {
    temporaryContract.repeatFromCompleation = sender.on
  }
  
  class func toggleWeekdays(sender: EditAlertRepeatDaysCell)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Monday")
    invertBool(inDictionary: &dynamicEditValues, withKey: "Tuesday")
    invertBool(inDictionary: &dynamicEditValues, withKey: "Wednesday")
    invertBool(inDictionary: &dynamicEditValues, withKey: "Thursday")
    invertBool(inDictionary: &dynamicEditValues, withKey: "Friday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleWeekends(sender: EditAlertRepeatDaysCell)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Saturday")
    invertBool(inDictionary: &dynamicEditValues, withKey: "Sunday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleMonday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Monday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleTuesday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Tuesday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleWednesday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Wednesday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleThursday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Thursday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleFriday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Friday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleSaturday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Saturday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func toggleSunday(sender: UIButton)
  {
    invertBool(inDictionary: &dynamicEditValues, withKey: "Sunday")
    refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
  }
  
  class func alertBoolFor(day: String) -> (Bool)
  {
    return dynamicEditValues[day] as! Bool
  }
  
  
  
  //MARK: - Utility Functions
  
  //MARK: Dynamic Editing Functions
  
  //This function attemtps to save the new values from the dynamically edited cell.  It is ment to be used in an if statement (hence the odd name), with the body of the if statement containing the code to deal with instances where in the save process failed due to invalid states for any of the new values in the dynamically edited cell (such as two lenders or borrowers with the same name).  Any and all errors of invaild data are to be caught by this function and then dealt with.  Whenever shifting from dynamically editing one cell to another it is imperitave that this function be called and DynamicEditValues be reset.
  class func failedToSaveDynamicChanges() -> (Bool)
  {
    //If dynamically editing make sure temporaryContract is uptodate.
    if (contractTempData.dynamicallyEditing)
    {
      let type = temporaryContract.type
      let section = contractTempData.dynamicEditCell.section
      let row = contractTempData.dynamicEditCell.row
      
      if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
      {
        //If dynamically editing lenders or borrowers, update contracteeTemporary and the appropirate list in temporaryContract. Check if the user attempted to use the same name twice.  If they did, ignore all other actions and request that they make the name unique.
        if (row > 0)
        {
          if (updateContractors())
          {
            return true
          }
        }
      }
      else
      {
        
        switch section
        {
          case 0:
            if (row == 0)
            {
              //Check if the new contract title is blank, and if so, set it to the default.
              if (temporaryContract.title == "")
              {
                temporaryContract.title = "Title (" + type.toAlternateString() + " iOU)"
              }
            }
            else
            {
              fatalError("There is no row \(row) in section \(section) in New Contract \(type)'s form.")
            }
          case 1:
            switch row
            {
              case 0:
                calculateValue()
              case 1:
                temporaryContract.tip = dynamicEditValues["Tip"] as! Int
                calculateValue()
              case 2:
                temporaryContract.interest = dynamicEditValues["Interest"] as! Double
              default:
                fatalError("There is no row \(row) in section \(section) in New Contract \(type)'s form.")
            }
          case 2, 3:
            break
          case 4:
            if (row =| [0, 1])
            {
              temporaryContract.dateDue = dynamicEditValues["DueDate"] as! NSDate
            }
            else
            {
              fatalError("There is no row \(row) in section \(section) in New Contract \(type)'s form.")
            }
          case 5:
            switch row
            {
              case 0:
                break
              case 1, 2:
                temporaryContract.alertDate = dynamicEditValues["AlertDueDate"] as! NSDate
              case 3:
                temporaryContract.alertTone = dynamicEditValues["AlertTone"] as! AlertTone
              case 4:
                temporaryContract.alertNagRate = dynamicEditValues["AlertNagRate"] as! AlertNagRate
              case 5:
                break
              case 6:
                let pattern: Any
                let interval: Any
                let rate: Int
              
                switch temporaryContract.alertRepeatType
                {
                  case AlertRepeatType.Simple:
                    pattern = 0
                    interval = dynamicEditValues["AlertRepeatSimpleInterval"]
                    rate = dynamicEditValues["AlertRepeatSimpleRate"] as! Int
                  case AlertRepeatType.Month:
                    pattern = dynamicEditValues["AlertRepeatMonthPattern"]
                    interval = dynamicEditValues["AlertRepeatMonthInterval"]
                    rate = dynamicEditValues["AlertRepeatMonthRate"] as! Int
                  case AlertRepeatType.Days:
                    pattern =
                    (
                      monday: alertBoolFor("Monday"),
                      tuesday: alertBoolFor("Tuesday"),
                      wednesday: alertBoolFor("Wednesday"),
                      thursday: alertBoolFor("Thursday"),
                      friday: alertBoolFor("Friday"),
                      saturday: alertBoolFor("Saturday"),
                      sunday: alertBoolFor("Sunday")
                    )
                
                    interval = 0
                    rate = dynamicEditValues["AlertRepeatDaysRate"] as! Int
                }
              
                temporaryContract.alertRepeatPattern = pattern
                temporaryContract.alertRepeatInterval = interval
                temporaryContract.alertRepeatRate = rate
              case 7:
                temporaryContract.alertRepeatDate = dynamicEditValues["AlertRepeat Date"] as! NSDate
              default:
                fatalError("There is no row \(row) in section \(section) in New Contract \(type)'s form.")
          }
        default:
          fatalError("there are only 3 sections, not \(section), in New Contract \(type)'s form.")
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
    if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
    {
      var index: Int
      var contractors: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>
      
      if (contractTempData.dynamicEditTable == "Lender")
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
      let contractor = dynamicEditValues["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
      let keyIndex = contractors.getIndex(forKey: contractor.key)
      
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
        contractTempData.warnFromID = contractTempData.dynamicEditTable + "NameWarning"
        contractTempData.warnToID = "NewContract"
        NSNotificationCenter.defaultCenter().postNotificationName(contractTempData.warnFromID, object: nil)
        
        return true
      }
      
      //Make sure the contractor lists in temporaryContract are updated properly.
      if (contractTempData.dynamicEditTable == "Lender")
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
    contractTempData.endDynamicEditing()
    data.currentFocus = nil
  }
  
  
  
  //MARK: Monetary Functions
  class func totalMonetaryValue() -> (Double)
  {
    var monetaryValue = temporaryContract.monetaryValue
    let status = toggles["IncludeTip"]!
    
    if (status)
    {
      var tip = Double(temporaryContract.tip)
      tip /= 100
      monetaryValue *= (1 + tip)
    }
    
    return monetaryValue
  }
  
  class func equalSharesMonetaryValue(contractorType: String, _ indexPath: NSIndexPath)-> (given: Double, slack: Double)
  {
    let monetaryValue = totalMonetaryValue()
    
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
    let monetaryValue = totalMonetaryValue()
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
    let numerator = updateNumericalValue(sender: sender.monetaryShare, includeDecimal: false, inTable: contractTempData.dynamicEditTable)
    dynamicEditValues["ContractorPartValue"] = Int(numerator)
    var denomenator: Int
    
    if (contractTempData.dynamicEditTable == "Lender")
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
    
    sender.monetaryLabel.text = String(format: "%.2f", monetaryFraction)
    var contractor = dynamicEditValues["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
    contractor.value.parts = Int(numerator)
    dynamicEditValues["DynamicEditContractor"] = contractor
    
    refreshNewContractorTable(contractTempData.dynamicEditTable)
  }
  
  class func updateMonetaryValue(sender: UITextField)
  {
    temporaryContract.monetaryValue = updateNumericalValue(sender: sender, includeDecimal: true, inTable: "Contract")
  }
  
  class func updateFixedMonetaryValue(sender sender: UITextField, contractorType: String)
  {
    var contractor = dynamicEditValues["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
    
    contractor.value.fixed = updateNumericalValue(sender: sender, includeDecimal: true, inTable: contractorType)
    
    dynamicEditValues["DynamicEditContractor"] = contractor
  }
  
  private class func updateNumericalValue(sender sender: UITextField, includeDecimal: Bool, inTable: String) -> (Double)
  {
    //Whenever the user changes the contract monetary value, update temporaryContract.monetaryValue.
    
    //First, eliminate any characters that are not numbers from contractMonetaryValue.text. (Note: Since this is being done in real time, this effectively prevents the user from inputing any non-number characters.)
    var textualNumericalValue = ""
    
    for character in sender.text!.characters
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
      if (inTable =| ["Lender", "Borrower"])
      {
        var totalMonetaryValueUsed: Double
        
        if (inTable == "Lender")
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
      
      sender.text = String(format: "%.2f", numericalValue)
    }
    else
    {
      sender.text = String(Int(numericalValue))
    }
    
    return numericalValue
  }
  
  class func displayCalculator(shouldDisplay: Bool)
  {
    toggles["DisplayCalculator"] = shouldDisplay
    
    if (!shouldDisplay)
    {
      calculateValue()
    }
    
    refreshNewContractCells([contractTempData.dynamicEditCell])
  }
  
  class func performOperation(operation: Operation) -> (String)
  {
    if (dynamicEditValues["CalculatorValue"] != nil)
    {
      calculateValue()
    }
    
    dynamicEditValues["CalculatorValue"] = temporaryContract.monetaryValue
    temporaryContract.monetaryValue = Double(0)
    dynamicEditValues["CalculatorOperator"] = operation
    return "0.00"
  }
  
  class func calculateValue() -> (String)
  {
    if let previousValue = dynamicEditValues["CalculatorValue"] as? Double
    {
      let currentValue = temporaryContract.monetaryValue
      var newValue: Double
      
      switch dynamicEditValues["CalculatorOperator"] as! Operation
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
      
      dynamicEditValues["CalculatorValue"] = nil
      temporaryContract.monetaryValue = newValue
      return String(format: "%.2f", newValue)
    }
    else
    {
      let monetaryValue = temporaryContract.monetaryValue
      return String(format: "%.2f", monetaryValue)
    }
  }
  
  class func flipToggle(toggle toggle: UISwitch, toggleID: String)
  {
    if (failedToSaveDynamicChanges())
    {
      toggle.setOn(!toggle.on, animated: true)
      return
    }
    
    resetDynamicEditing()
    
    if (toggles[toggleID] != nil)
    {
      toggles[toggleID] = toggle.on
      
      switch toggleID
      {
        case "UseAlert":
          temporaryContract.useAlert = toggle.on
        case "RepeatAlert":
          temporaryContract.repeatAlert = toggle.on
        default:
          break
      }
    }
    else
    {
      fatalError("There is no toggle with ID: \(toggleID)")
    }
    
    refreshNewContract()
  }
  
  class func updateTip(picker picker: PercentagePicker, didSelectRow row: Int, inComponent component: Int)
  {
    temporaryContract.tip = percentagePicker(didSelectRow: row, forComponent: component, forPercentagePicker: picker, withCap: -1)
    let refreshRows = [NSIndexPath(forRow: 0, inSection: 1)]
    refreshNewContractCells(refreshRows)
  }
  
  
  
  //MARK: Picker Cell Functions
  class func pickerCellComponentCount() -> (Int)
  {
    trackRowRefreshes(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell)
    trackFunctionCalls(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell, function: "pickerCellComponentCount")
    
    if (!contractTempData.dynamicallyEditing)
    {
      fatalError("There should be no active pickers if no cell is being dynamically edited.")
    }
    
    if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
    {
      return 3
    }
    else
    {
      let tableSection = contractTempData.dynamicEditCell.section
      let tableRow = contractTempData.dynamicEditCell.row
      
      switch (tableSection)
      {
        case 1:
          switch (tableRow)
          {
            case 1: //Tip
              return 3
            case 2: //Interest
              return 6
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        case 5:
          switch (tableRow)
          {
            case 3, 4: //Alert Tone, Nag Rate
              return 1
            case 6:
              let repeatType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
              
              switch repeatType
              {
                case AlertRepeatCellType.Simple, AlertRepeatCellType.MonthPattern:
                  return 2
                case AlertRepeatCellType.MonthRate, AlertRepeatCellType.DaysRate:
                  return 1
                default:
                  fatalError("There are no pickers in \(repeatType.toString()).")
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        default:
          fatalError("There are no pickers in section: \(tableSection).")
      }
    }
  }
  
  class func pickerCell(rowCountForComponent component: Int) -> (Int)
  {
    trackRowRefreshes(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell)
    trackFunctionCalls(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell, function: "rowCountForComponent")
    
    if (!contractTempData.dynamicallyEditing)
    {
      fatalError("There should be no active pickers if no cell is being dynamically edited.")
    }
    
    if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
    {
      let loopRadius = iOUData.sharedInstance.loopRadius
      let loop = loopRadius * 2 + 1
      return 10 * loop
    }
    else
    {
      let tableSection = contractTempData.dynamicEditCell.section
      let tableRow = contractTempData.dynamicEditCell.row
      
      switch (tableSection)
      {
        case 1:
          switch (tableRow)
          {
            case 1: //Tip
              let loopRadius = iOUData.sharedInstance.loopRadius
              let loop = loopRadius * 2 + 1
              return 10 * loop
            case 2: //Interest
              if (component == 3)
              {
                return 1
              }
              else
              {
                return 10
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        case 5:
          switch (tableRow)
          {
           case 3: //Alert Tone
              return 93
            case 4: //Nag Rate
              return 5
            case 6:
              let repeatType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
          
              switch repeatType
              {
                case AlertRepeatCellType.Simple:
                  switch component
                  {
                    case 0:
                      return 100
                    case 1:
                      return 4
                    default:
                      fatalError("There is no component \(component) in AlertRepeatSimple.")
                  }
                case AlertRepeatCellType.MonthPattern:
                  if (component == 0)
                  {
                    switch dynamicEditValues["AlertMonthPattern"] as! Days
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
                case AlertRepeatCellType.MonthRate, AlertRepeatCellType.DaysRate:
                  return 100
                default:
                  fatalError("There are no pickers in \(repeatType.toString()).")
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        default:
          fatalError("There are no pickers in section: \(tableSection).")
      }
    }
  }
  
  class func pickerCell(titleForRow row: Int, inComponent component: Int) -> (String!)
  {
    trackRowRefreshes(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell)
    trackFunctionCalls(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell, function: "titleForRow")
    
    if (!contractTempData.dynamicallyEditing)
    {
      fatalError("There should be no active pickers if no cell is being dynamically edited.")
    }
    
    if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
    {
      return String(row % 10)
    }
    else
    {
      let tableSection = contractTempData.dynamicEditCell.section
      let tableRow = contractTempData.dynamicEditCell.row
      
      switch (tableSection)
      {
        case 1:
          switch (tableRow)
          {
            case 1: //Tip
              return String(row % 10)
            case 2: //Interest
              if (component == 3)
              {
                return "."
              }
              else
              {
                return String(row)
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        case 5:
          switch (tableRow)
          {
            case 3: //Alert Tone
              return AlertTone(rawValue: row)!.toString()
            case 4: //Nag Rate
              return AlertNagRate(rawValue: row)!.toString()
            case 6:
              let repeatType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
          
              switch repeatType
              {
                case AlertRepeatCellType.Simple:
                  switch component
                  {
                    case 0:
                      return String(row + 1)
                    case 1:
                      return TimeInterval(rawValue: row)!.toString()
                    default:
                      fatalError("There is no component \(component) in AlertRepeatSimple.")
                  }
                case AlertRepeatCellType.MonthPattern:
                  if (component == 0)
                  {
                    let lastRow = pickerCell(rowCountForComponent: component) - 1
                    
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
                case AlertRepeatCellType.MonthRate, AlertRepeatCellType.DaysRate:
                  return String(row + 1)
                default:
                  fatalError("There are no pickers in \(repeatType.toString()).")
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        default:
        fatalError("There are no pickers in section: \(tableSection).")
      }
    }
  }
  
  class func pickerCell(didSelectRow row: Int, inComponent component: Int, fromPicker cell: UITableViewCell)
  {
    trackRowRefreshes(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell)
    trackFunctionCalls(table: contractTempData.dynamicEditTable, index: contractTempData.dynamicEditCell, function: "didSelectRow")
    
    if (!contractTempData.dynamicallyEditing)
    {
      fatalError("There should be no active pickers if no cell is being dynamically edited.")
    }
    
    if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
    {
      let editCell = cell as! EditPercentagesCell
      percentagePicker(rowSelected: row, forComponent: component, forPercentagePicker: editCell)
    }
    else
    {
      let tableSection = contractTempData.dynamicEditCell.section
      let tableRow = contractTempData.dynamicEditCell.row
      
      switch (tableSection)
      {
        case 1:
          switch (tableRow)
          {
          case 1: //Tip
            let percentageCell = cell as! PercentagePicker
            dynamicEditValues["Tip"] = percentagePicker(didSelectRow: row, forComponent: component, forPercentagePicker: percentageCell, withCap: -1)
          case 2: //Interest
            let pickerCell = cell as! EditPickerCell
            let picker = pickerCell.picker
            
            let hundreds = Double(picker.selectedRowInComponent(0))
            let tens = Double(picker.selectedRowInComponent(1))
            let ones = Double(picker.selectedRowInComponent(2))
            let tenths = Double(picker.selectedRowInComponent(4))
            let hundredths = Double(picker.selectedRowInComponent(5))
            
            let interest = hundreds * 100 + tens * 10 + ones + tenths / 10 + hundredths / 100
            dynamicEditValues["Interest"] = interest
          default:
            fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        case 5:
          switch (tableRow)
          {
            case 3: //Alert Tone
              dynamicEditValues["Tip"] = AlertTone(rawValue: row)!
            case 4: //Nag Rate
              dynamicEditValues["AlertNagRate"] = AlertNagRate(rawValue: row)!
            case 6:
              let repeateType = dynamicEditValues["AlertRepeatCellType"] as! AlertRepeatCellType
          
              switch repeateType
              {
                case AlertRepeatCellType.Simple:
                  switch component
                  {
                    case 0:
                      dynamicEditValues["AlertRepeatSimpleRate"] = row
                    case 1:
                      dynamicEditValues["AlertRepeatSimpleInterval"] = TimeInterval(rawValue: row)!
                    default:
                      fatalError("There is no component \(component) in AlertRepeatSimple.")
                 }
                case AlertRepeatCellType.MonthPattern:
                  switch component
                  {
                    case 0:
                      dynamicEditValues["AlertRepeatMonthRate"] = row
                    case 1:
                      dynamicEditValues["AlertRepeatMonthInterval"] = Days(rawValue: row)!
                      let newMaximum = pickerCell(rowCountForComponent: component)
                
                      if (dynamicEditValues["AlertRepeatMonthRate"] as! Int > newMaximum)
                      {
                        dynamicEditValues["AlertRepeatMonthRate"] = newMaximum
                        let pickerCell = cell as! EditPickerCell
                        let picker = pickerCell.picker
                        picker.selectRow(newMaximum, inComponent: 0, animated: true)
                      }
                    default:
                      fatalError("There is no component \(component) in AlertRepeatMonthPattern.")
                  }
                
                  refreshNewContractCells([NSIndexPath(forRow: 6, inSection: 5)])
                case AlertRepeatCellType.MonthRate:
                  dynamicEditValues["AlertRepeatMonthRate"] = row
                case AlertRepeatCellType.DaysRate:
                  dynamicEditValues["AlertRepeatDaysRate"] = row
                default:
                  fatalError("There are no pickers in \(repeateType.toString()).")
              }
            default:
              fatalError("There are no pickers in row: \(tableRow) of section: \(tableSection).")
          }
        default:
          fatalError("There are no pickers in section: \(tableSection).")
      }
    }
  }
  
  
  
  //MARK: Percentage Picker Functions
  class func initializePercentagePicker(pickerCell: PercentagePicker, percentage: Int)
  {
    var pickerCell = pickerCell
    
    pickerCell.current.hundredsDigit = percentage[2]
    pickerCell.current.tensDigit = percentage[1]
    pickerCell.current.onesDigit = percentage[0]
    
    pickerCell.saved.hundredsDigit = percentage[2]
    pickerCell.saved.tensDigit = percentage[1]
    pickerCell.saved.onesDigit = percentage[0]
    
    let hundreds = percentage[2] + 10 * data.loopRadius
    let tens = percentage[1] + 10 * data.loopRadius
    let ones = percentage[0] + 10 * data.loopRadius
    
    pickerCell.picker.selectRow(hundreds, inComponent: 0, animated: false)
    pickerCell.picker.selectRow(tens, inComponent: 1, animated: false)
    pickerCell.picker.selectRow(ones, inComponent: 2, animated: false)
  }
  
  class func initializePercentagePicker(pickerCell: PercentagePicker, percentage: Double)
  {
    var pickerCell = pickerCell
    let integer = Int(percentage)
    initializePercentagePicker(pickerCell, percentage: integer)
    
    let tenths = percentage[3] + 10 * data.loopRadius
    let hundredths = percentage[4] + 10 * data.loopRadius
    
    pickerCell.picker.selectRow(tenths, inComponent: 4, animated: false)
    pickerCell.picker.selectRow(hundredths, inComponent: 5, animated: false)

  }
  
  class func percentagePicker(rowSelected row: Int, forComponent component: Int, forPercentagePicker pickerCell: EditPercentagesCell)
  {
    let cap = dynamicContractorPercentageCap()
    let monetaryPercentage = percentagePicker(didSelectRow: row, forComponent: component, forPercentagePicker: pickerCell, withCap: cap)
    
    let monetaryTotal = contractTempData.contract.monetaryValue
    let monetaryFraction = (Double(monetaryPercentage) / 100.0) * monetaryTotal
    
    pickerCell.pickerPreLabel.text = String(format: "%.2f", monetaryFraction)
    dynamicEditValues["ContractorPercentValue"] = monetaryPercentage
  }
  
  class func dynamicContractorPercentageCap() -> (Int)
  {
    var contractorPercentageUnused: Int
    
    if (contractTempData.dynamicEditTable == "Lender")
    {
      contractorPercentageUnused = 100 - Int(data.totalLenderPercentageUsed())
    }
    else
    {
      contractorPercentageUnused = 100 - Int(data.totalBorrowerPercentageUsed())
    }
    
    return contractorPercentageUnused
  }
  
  class func percentagePicker(didSelectRow row: Int, forComponent component: Int, forPercentagePicker pickerCell: PercentagePicker, withCap cap: Int) -> (Int)
  {
    var pickerCell = pickerCell
    
    //Define the padding and the uppper and lower limits for the range to keep the picker within whenever a value is selected.
    let padding = 10 //The size of the range of values.
    let lowerBound = padding * data.loopRadius
    let upperBound = padding * (data.loopRadius + 1)
    
    //If the user has selected a row outside of the middle range of the pesudo-infinite percentage picker, teleport back within the range.  Provided the user does not scroll continuously without letup, this will give the illusion of an infinite picker wheel.
    if ((row < lowerBound) || (row >= upperBound))
    {
      let toZero = row % padding  //Find the position with the same value as the current selection within the first range.
      let shiftTo = toZero + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
      pickerCell.picker.selectRow(shiftTo, inComponent: component, animated: false)
    }
    
    //Once at the correct location, calculate the percentage.
    var percent: Int
    
    //If cap is greater than or equal to zero, then do not allow any value over the cap.  If the user goes over the cap, shift down to the cap, but save the digit values.  If the user adjusts back below the cap, return to the previous value before they moved above the cap the first time.  If they adust over th cap, set the higher digit(s) to zero and accept the new digit values. If the cap is -1, ignore it.
    
    //Then, find the hundreds, tens, and ones digits.
    var hundredsDigit = pickerCell.picker.selectedRowInComponent(0)
    var tensDigit = pickerCell.picker.selectedRowInComponent(1)
    var onesDigit = pickerCell.picker.selectedRowInComponent(2)
    
    //Convert from picker row number to digit.
    hundredsDigit %= padding
    tensDigit %= padding
    onesDigit %= padding
    
    if (cap >= 0)
    {
      let hundredsCap = (cap / 100)
      let tensCap = (cap / 10) - (hundredsCap * 10)
      let onesCap = cap - (hundredsCap * 100) - (tensCap * 10)
      let currentValue = pickerCell.current.hundredsDigit * 100 + pickerCell.current.tensDigit * 10 + pickerCell.current.onesDigit
      
      if (hundredsCap < hundredsDigit)
      {
        if (component == 0 && cap == currentValue)
        {
          hundredsDigit = pickerCell.saved.hundredsDigit
          tensDigit = pickerCell.saved.tensDigit
          onesDigit = pickerCell.saved.onesDigit
        }
        else
        {
          //Save and cap the digits
          pickerCell.saved.hundredsDigit = pickerCell.current.hundredsDigit
          pickerCell.saved.tensDigit = pickerCell.current.tensDigit
          pickerCell.saved.onesDigit = pickerCell.current.onesDigit
          
          hundredsDigit = hundredsCap
          tensDigit = tensCap
          onesDigit = onesCap
        }
        
        let hundredsRow = hundredsDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        let tensRow = tensDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
        
        pickerCell.picker.selectRow(hundredsRow, inComponent: 0, animated: true)
        pickerCell.picker.selectRow(tensRow, inComponent: 1, animated: true)
        pickerCell.picker.selectRow(onesRow, inComponent: 2, animated: true)
      }
      else if (hundredsCap == hundredsDigit)
      {
        if (tensCap < tensDigit)
        {
          if (component == 1)
          {
            hundredsDigit = 0
            pickerCell.picker.selectRow(lowerBound, inComponent: 0, animated: true)
            
            if (cap == currentValue)
            {
              if (hundredsCap == 0)
              {
                tensDigit = pickerCell.saved.tensDigit
                onesDigit = pickerCell.saved.onesDigit
              }
              else
              {
                pickerCell.saved.hundredsDigit = hundredsDigit
                pickerCell.saved.tensDigit = tensDigit
                pickerCell.saved.onesDigit = onesDigit
              }
            }
            else
            {
              //Save the tens and ones digits
              pickerCell.saved.hundredsDigit = pickerCell.current.hundredsDigit
              pickerCell.saved.tensDigit = pickerCell.current.tensDigit
              pickerCell.saved.onesDigit = pickerCell.current.onesDigit
              
              tensDigit = tensCap
              onesDigit = onesCap
            }
          }
          else
          {
            //Save the tens and ones digits
            pickerCell.saved.hundredsDigit = pickerCell.current.hundredsDigit
            pickerCell.saved.tensDigit = pickerCell.current.tensDigit
            pickerCell.saved.onesDigit = pickerCell.current.onesDigit
            
            tensDigit = tensCap
            onesDigit = onesCap
          }
          
          let tensRow = tensDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
          let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
          
          pickerCell.picker.selectRow(tensRow, inComponent: 1, animated: true)
          pickerCell.picker.selectRow(onesRow, inComponent: 2, animated: true)
        }
        else if (tensCap == tensDigit)
        {
          if (onesCap < onesDigit)
          {
            if (component == 2)
            {
              hundredsDigit = 0
              tensDigit = 0
              
              pickerCell.picker.selectRow(lowerBound, inComponent: 0, animated: true)
              pickerCell.picker.selectRow(lowerBound, inComponent: 1, animated: true)
              
              if (cap == currentValue)
              {
                if (hundredsCap == 0 && tensCap == 0)
                {
                  onesDigit = pickerCell.saved.onesDigit
                }
                else
                {
                  pickerCell.saved.hundredsDigit = hundredsDigit
                  pickerCell.saved.tensDigit = tensDigit
                  pickerCell.saved.onesDigit = onesDigit
                }
              }
              else
              {
                //Save the ones digits
                pickerCell.saved.hundredsDigit = pickerCell.current.hundredsDigit
                pickerCell.saved.tensDigit = pickerCell.current.tensDigit
                pickerCell.saved.onesDigit = pickerCell.current.onesDigit
                
                onesDigit = onesCap
              }
            }
            else
            {
              //Save the tens and ones digits
              pickerCell.saved.hundredsDigit = pickerCell.current.hundredsDigit
              pickerCell.saved.tensDigit = pickerCell.current.tensDigit
              pickerCell.saved.onesDigit = pickerCell.current.onesDigit
              
              onesDigit = onesCap
            }
            
            let onesRow = onesDigit + padding * data.loopRadius //Add suffecint padding to move the value to within the middle range.
            pickerCell.picker.selectRow(onesRow, inComponent: 2, animated: true)
          }
          else
          {
            pickerCell.saved.hundredsDigit = hundredsDigit
            pickerCell.saved.tensDigit = tensDigit
            pickerCell.saved.onesDigit = onesDigit
          }
        }
        else
        {
          pickerCell.saved.hundredsDigit = hundredsDigit
          pickerCell.saved.tensDigit = tensDigit
          pickerCell.saved.onesDigit = onesDigit
        }
      }
      else
      {
        pickerCell.saved.hundredsDigit = hundredsDigit
        pickerCell.saved.tensDigit = tensDigit
        pickerCell.saved.onesDigit = onesDigit
      }
      
      pickerCell.current.hundredsDigit = hundredsDigit
      pickerCell.current.tensDigit = tensDigit
      pickerCell.current.onesDigit = onesDigit
    }
    else
    {
      //If the percentage cap was not activated, find the hundreds, tens, and ones digits.
      var hundredsDigit = pickerCell.picker.selectedRowInComponent(0)
      var tensDigit = pickerCell.picker.selectedRowInComponent(1)
      var onesDigit = pickerCell.picker.selectedRowInComponent(2)
      
      //(Don't forget to remove the row location padding!)
      hundredsDigit %= padding
      tensDigit %= padding
      onesDigit %= padding
    }
    
    //Calculate the percentage.
    percent = hundredsDigit * 100 + tensDigit * 10 + onesDigit
    return percent
  }
  
  
  
  //MARK: New Contract Cell Functions
  class func updateDynamicDate(sender: EditDateCell)
  {
    let key = sender.dateLabel.text!
    dynamicEditValues[key] = sender.datePicker.date
    //TODO: Get Calender Working!!! (Of course, then you will need to add CVCalender functionality to this method as well...)
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
  
  class func dynamicallyEditingThisCell(indexPath: NSIndexPath, inTable table: String) -> (Bool)
  {
    if (contractTempData.dynamicallyEditing)
    {
      if (contractTempData.dynamicEditTable =| ["Lender", "Borrower"])
      {
        if (contractTempData.dynamicEditTable == table)
        {
          return (contractTempData.dynamicEditCell == indexPath)
        }
      }
      else if (table !=| ["Lender", "Borrower"])
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
  
  class func setCheckboxImage(state state: Bool, button: UIButton)
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
  
  class func toggleCalender()
  {
    //TODO: Finish once you get the calender working!!!
  }
  
  
  
  //MARK: Refresh New Contract View Functions
  class func refreshNewContract()
  {
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshNewContract", object: nil)
  }
  
  class func refreshNewContractCells(rows: [NSIndexPath])
  {
    var postedData: [NSObject : AnyObject] = [:]
    
    for i in 0 ..< rows.count
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
        postedData[i] = indexPath
      }
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("RefreshNewContractCells", object: nil, userInfo: postedData)
    
    if (data.currentFocus != nil)
    {
      data.currentFocus.setFocus()
    }
  }
  
  class func refreshNewContractCells(view view: EditContractController, notification: NSNotification)
  {
    let table = view.tableView
    var refreshRows: [NSIndexPath] = []
    var doSecondLoad: Bool = false
    var reloadRows: [NSIndexPath] = []
    
    for datum in notification.userInfo!.values
    {
      let index = datum as! NSIndexPath
      if (index =| [lenderTableIndexPath, borrowerTableIndexPath])
      {
        doSecondLoad = true
        reloadRows.append(index)
      }
      
      refreshRows.append(index)
    }
    
    table.reloadRowsAtIndexPaths(refreshRows, withRowAnimation: UITableViewRowAnimation.None)

    //FIXME: reloadRowsAtIndexPaths is a bit glitchy when dealing with some static table cells that change their size, a double call to it seems to ensure that it always updates properly. If Apple ever fixes it, this section may need adjusting...
    if (doSecondLoad)
    {
      table.reloadRowsAtIndexPaths(reloadRows, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    if (debugging)
    {
      if (debugData.debugCellReloads)
      {
        let reloads = debugData.reloadedCells
        
        for i in 0 ..< reloads.count
        {
          print(reloads[i].key.toString() + " was loaded \(reloads[i].value) times.")
        }
        
        debugData.reloadedCells.newDictionary()
      }
      
      if (debugData.debugFunctionCalls)
      {
        let calls = debugData.functionCalls
        
        for i in 0 ..< calls.count
        {
          print(calls[i].key.toString() + " was loaded \(calls[i].value) times.")
        }
        
        debugData.functionCalls.newDictionary()
      }
    }
  }
  
  class func refreshNewContractors()
  {
    if (toggles["DisplayingLenders"]!)
    {
      refreshNewContractorTable("Lender")
    }
    
    if (toggles["DisplayingBorrowers"]!)
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
  
  class func refreshNewContractorTable(sharesController shares: UISegmentedControl, table: UITableView, contractorType: String)
  {
    table.reloadData()
    var postedData: [NSObject : AnyObject]
    
    if (contractorType == "Lender")
    {
      shares.selectedSegmentIndex = temporaryContract.lenderShares.rawValue
      postedData = [0: lenderTableIndexPath]
    }
    else
    {
      shares.selectedSegmentIndex = temporaryContract.borrowerShares.rawValue
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
  
  class func keyboardWillShow(newContractor newContractor: NewContractors, notification: NSNotification)
  {
    if (toggles["AdjustForKeyboard"]!)
    {
      let postedData = notification.userInfo!
      let keyboardNSSize: NSValue = postedData[UIKeyboardFrameEndUserInfoKey]! as! NSValue
      
      var userInfo: [NSObject : AnyObject] = [:]
      userInfo["KeyboardNSSize"] = keyboardNSSize
      userInfo["ContractorView"] = newContractor
      userInfo["ContractorTable"] = newContractor.contractorsList
      
      NSNotificationCenter.defaultCenter().postNotificationName("NewContractKeyboardWillShow", object: nil, userInfo: userInfo)
    }
  }
  
  class func keyboardWillShow(editContractController controller: EditContractController, notification: NSNotification)
  {
    if (toggles["AdjustForKeyboard"]!)
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
      
      let table = controller.tableView
      let postedData = notification.userInfo!
      let keyboardNSSize: NSValue = postedData["KeyboardNSSize"]! as! NSValue
      let keyboardSize = keyboardNSSize.CGRectValue().size
      
      var cellRectangle: CGRect
      
      switch contractTempData.dynamicEditTable
      {
        case "Title", "MonetaryValue":
          cellRectangle = table.rectForRowAtIndexPath(contractTempData.dynamicEditCell)
        case "Lender", "Borrower":
          let contractorTable = postedData["ContractorTable"] as! UITableView
          let tableCellRectangle = contractorTable.rectForRowAtIndexPath(contractTempData.dynamicEditCell)
          cellRectangle = controller.view.convertRect(tableCellRectangle, fromView: table.superview)
        default:
          fatalError("Cell: \(contractTempData.dynamicEditTable) does not contain a text field.")
      }
      
      var visiblePortionOfTable = controller.view.frame
      visiblePortionOfTable.size.height -= keyboardSize.height
      print("Visible Portion Of Table Height: \(visiblePortionOfTable.height)")
      
      if (!CGRectContainsRect(cellRectangle, visiblePortionOfTable))
      {
        print("Cell Rectangle Height: \(cellRectangle.height)")
        let scrollPoint = CGPointMake(0.0, cellRectangle.height)
        
        dynamicEditValues["ScrollResetPoint"] = table.contentOffset
        table.setContentOffset(scrollPoint, animated: true)
      }
    }
  }
  
  @objc class func keyboardWillHide(table: UITableView)
  {
    if (dynamicEditValues["ScrollResetPoint"] != nil)
    {
      let point = dynamicEditValues["ScrollResetPoint"] as! CGPoint
      table.setContentOffset(point, animated: true)
      dynamicEditValues["ScrollResetPoint"] = nil
    }
  }
  
  
  
  //MARK: - Debug Logic
  //Debugging tool to make sure cells only get updated once per refresh.  This just monitors total changes made to a particular row in a table.
  class func trackRowRefreshes(table table: String, index: NSIndexPath)
  {
    if !(debugging && debugData.debugCellReloads)
    {
      return
    }
    
    var reloadedCells = data.debugData.reloadedCells
    let loadedCell = TableAndIndex(table: table, index: index)
    
    if (reloadedCells.hasKey(loadedCell))
    {
      //Increase count for loadedCell
      reloadedCells[loadedCell]! += 1
    }
    else
    {
      reloadedCells[loadedCell] = 1
    }
    
    data.debugData.reloadedCells = reloadedCells
  }
  
  //Debugging tool to make sure cells only get updated once per refresh. This monitors the number of times a function is called and for which row in what table.
  class func trackFunctionCalls(table table: String, index: NSIndexPath, function: String)
  {
    if !(debugging && debugData.debugFunctionCalls)
    {
      return
    }
    
    var functionCalls = data.debugData.functionCalls
    let currentCall = FunctionAndIndex(table: table, index: index, function: function)
    
    if (functionCalls.hasKey(currentCall))
    {
      //Increase count for currentCall
      functionCalls[currentCall]! += 1
    }
    else
    {
      functionCalls[currentCall] = 1
    }
    
    data.debugData.functionCalls = functionCalls
  }
}
