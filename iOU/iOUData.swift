//
//  iOUData.swift
//  iOU
//
//  Created by Tateni Urio on 11/19/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private let iOUDataSharedInstance = iOUData()

class iOUData
{
  class var sharedInstance: iOUData
  {
    return iOUDataSharedInstance
  }
  private let managedObjectContext: NSManagedObjectContext
  private let mainData: NSManagedObject
  var listType: ListType
  {
    get
    {
      let temporaryExtractedDatum = mainData.valueForKey("listType")! as Int
      return ListType(rawValue: temporaryExtractedDatum)!
    }
    set
    {
      saveToMainData("listType", dataValue: newValue.rawValue)
    }
  }
  var currency: Currency
  {
    get
    {
      let temporaryExtractedDatum = mainData.valueForKey("currency")! as String
      return Currency(rawValue: temporaryExtractedDatum)!
    }
    set
    {
      saveToMainData("currency", dataValue: newValue.rawValue)
    }
  }
  var standardTip: Int
  {
    get
    {
      return mainData.valueForKey("standardTip")! as Int
    }
    set
    {
      saveToMainData("standardTip", dataValue: newValue)
    }
  }
  
  var temporaryData = TemporaryData()
  var newContract = Contract()
  var moneyContracts: [Contract] = []
  var itemContracts: [Contract] = []
  var serviceContracts: [Contract] = []
  let loopRadius: Int = 25
  var digits = [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]]
  
  
  private init()
  {
    //Initalize Temporary Data and New Contract data values.
    //Set it up so that we can save and load variables.
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName:"MainData")
    var error: NSError?
    
    if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    {
      if (fetchedResults == [])
      {
        //If this is the first time this app has ever run, create mainData Core Data storage object to save all main app data values.
        let entity =  NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)
        mainData = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        //Initialize variables that do get saved.
        listType = ListType(rawValue: 0)!
        currency = Currency.USD
        standardTip = 15
      }
      else
      {
        //Otherwise, initialize mainData from saved data.
        mainData = fetchedResults[0]
      }
    }
    else
    {
      fatalError("Could not fetch \(error), \(error!.userInfo)")
    }
  }
  
  func totalLenderPercentageUsed() -> (Int)
  {
    var percentage: Int = 0
    let lenders = temporaryData.contract.lenders
    let count = lenders.count
    let lenderBeingEdited = temporaryData.dynamicEditContractor
    let dynamicEditIndex = lenders.getIndex(forKey: lenderBeingEdited.key)
    
    for i in 0..<count
    {
      if (i != dynamicEditIndex)
      {
        let lender = lenders[i]
        percentage += Int(lender.value)
      }
    }
    
    return percentage
  }
  
  func totalBorrowerPercentageUsed() -> (Int)
  {
    var percentage: Int = 0
    let borrowers = temporaryData.contract.borrowers
    let count = borrowers.count
    let borrowerBeingEdited = temporaryData.dynamicEditContractor
    let dynamicEditIndex = borrowers.getIndex(forKey: borrowerBeingEdited.key)
    
    for i in 0..<count
    {
      if (i != dynamicEditIndex)
      {
        let borrower = borrowers[i]
        percentage += Int(borrower.value)
      }
    }
    
    return percentage
  }
  
  func resetNewContractData()
  {
    temporaryData.reset()
    newContract = Contract()
  }
  
  private func saveToMainData(key: String, dataValue: AnyObject)
  {
    mainData.setValue(dataValue, forKey: key)
    var error: NSError?
    
    if (!managedObjectContext.save(&error))
    {
      fatalError("Could not save \(error), \(error?.userInfo)")
    }
  }
  
  func mostPopularContractType() -> (Type)
  {
    //TODO - Finish this method...
    return Type.Item
  }
}





class TemporaryData
{
  var dynamicEdit = (id: "", cell: NSIndexPath())
  var dynamicallyEditing = false
  var warnSource = ""
  var contract = Contract()
  var takeUpSlackRow = Int()
  var dynamicEditContractor = (key: "", value: (parts: Int(0), percent: Int(0), fixed: Double(0)))
  var lendersTemporary = SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>()
  var borrowersTemporary = SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>()
  var displayLenders = false
  var displayBorrowers = false
  var includeTip = false
  var tip = 15
  var displayCalculator = false
  var calculatorValue: Double? = nil
  var calculatorOperator = Operation.Add
  
  func reset()
  {
    dynamicEdit = (id: "", cell: NSIndexPath())
    dynamicallyEditing = false
    warnSource = ""
    contract = Contract()
    takeUpSlackRow = Int()
    dynamicEditContractor = (key: "", value: (parts: Int(0), percent: Int(0), fixed: Double(0)))
    lendersTemporary = SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>()
    borrowersTemporary = SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)>()
    displayLenders = false
    displayBorrowers = false
    includeTip = false
    tip = iOUData.sharedInstance.standardTip
    displayCalculator = false
    calculatorValue = nil
    calculatorOperator = Operation.Add
  }
}





enum Type: Int
{
  case Money = 0
  case Item, Service
  
  func toString() -> (String)
  {
    switch self
    {
    case .Money:
      return "Money"
    case .Item:
      return "Item"
    case .Service:
      return "Service"
    }
  }
  
  func toAlternateString() -> (String)
  {
    switch self
    {
    case .Money:
      return "Monetary"
    case .Item:
      return "Item"
    case .Service:
      return "Service"
    }
  }
  
  func compare(typeOther: Type) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func convert() -> (ListType)
  {
    return ListType(rawValue: self.rawValue)!
  }
}





enum ListType: Int
{
  case Money = 0
  case Item, Service, Starred
  
  func toString() -> (String)
  {
    switch self
    {
    case .Money:
      return "Money"
    case .Item:
      return "Item"
    case .Service:
      return "Service"
    case .Starred:
      return "Starred"
    }
  }
  
  func compare(typeOther: ListType) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func convert() -> (Type)
  {
    if (self == ListType.Starred)
    {
      fatalError("Cannot convert from ListType Starred to Type.")
    }
    
    return Type(rawValue: self.rawValue)!
  }
}





enum Currency: String
{
  case USD = "USD"
  
  
  func compare(typeOther: Currency) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func compare(typeOther: String) -> (Bool)
  {
    return self.rawValue == typeOther
  }
}





enum Shares: Int
{
  case Equal = 0
  case Parts, Percentage, Fixed
  
  func toString() -> (String)
  {
    switch self
    {
      case .Equal:
        return "Equal"
      case .Parts:
        return "Parts"
      case .Percentage:
        return "Percentage"
      case .Fixed:
        return "Fixed"
    }
  }
  
  func compare(typeOther: Shares) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}




enum Operation: Int
{
  case Add = 0
  case Subtract, Multiply, Divide
  
  func compare(typeOther: Operation) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





class Contract
{
  var title: String
  var type: Type
  var monetaryValue: Double
  var lenders: SortableDictionary<String, Double>
  var lenderShares = Shares.Equal
  var borrowers: SortableDictionary<String, Double>
  var borrowerShares = Shares.Equal
  
  var photo: [String]
  var video: [String]
  var sound: [String]
  var remindDate: NSDate
  var remindTime: NSDate
  var remindTimeSpan: NSTimeInterval
  var useTimeSpan: Bool
  var tags: [String]
  var dateCreated: NSDate
  var dateDue: NSDate
  var notes: String
  var simplifyGroupDebts: Bool
//  var locationCreated: AnyObject
//  var locationDue: AnyObject
  var priority: Int
  var isStarred: Bool
  var incompleteContractReminder: NSDate
  var reoccurringContractRate: NSTimeInterval
  var reoccurringContractDurration: NSDate
  var remindContractees: SortableDictionary<String, NSDate>
  var itemDescription: String
  var itemConditionReceived: String
  var itemConditionReturning: String
  var contractExpectationsMinimum: String
  var contractExpectationsMaximum: String
  
  
  init(title: String = "", photo: [String] = [], video: [String] = [], sound: [String] = [],remindDate: NSDate = NSDate(), remindTime: NSDate = NSDate(), remindTimeSpan: NSTimeInterval = NSTimeInterval(), useTimeSpan: Bool = false, type: Type = Type.Money, lenders: SortableDictionary<String, Double> = SortableDictionary(), borrowers: SortableDictionary<String, Double> = SortableDictionary(), lenderShares: Shares = Shares.Equal, borrowerShares: Shares = Shares.Equal, monetaryValue: Double = 0, tags: [String] = [], dateCreated: NSDate = NSDate(), dateDue: NSDate = NSDate(), notes: String = "", simplifyGroupDebts: Bool = false,
//    locationCreated: AnyObject, locationDue: AnyObject,
    priority: Int = 0, isStarred: Bool = false, incompleteContractReminder: NSDate = NSDate(), reoccurringContractRate: NSTimeInterval = NSTimeInterval(), reoccurringContractDurration: NSDate = NSDate(), remindContractees: SortableDictionary<String, NSDate> = SortableDictionary(), itemDescription: String = "", itemConditionReceived: String = "", itemConditionReturning: String = "", contractExpectationsMinimum: String = "", contractExpectationsMaximum: String = "")
  {
    self.title = title
    self.photo = photo
    self.video = video
    self.sound = sound
    self.remindDate = remindDate
    self.remindTime = remindTime
    self.remindTimeSpan = remindTimeSpan
    self.useTimeSpan = useTimeSpan
    self.type = type
    self.lenders = lenders
    self.borrowers = borrowers
    self.lenderShares = lenderShares
    self.borrowerShares = borrowerShares
    self.monetaryValue = monetaryValue
    self.tags = tags
    self.dateCreated = dateCreated
    self.dateDue = dateDue
    self.notes = notes
    self.simplifyGroupDebts = simplifyGroupDebts
//    self.locationCreated = locationCreated
//    self.locationDue = locationDue
    self.priority = priority
    self.isStarred = isStarred
    self.incompleteContractReminder = incompleteContractReminder
    self.reoccurringContractRate = reoccurringContractRate
    self.reoccurringContractDurration = reoccurringContractDurration
    self.remindContractees = remindContractees
    self.itemDescription = itemDescription
    self.itemConditionReceived = itemConditionReceived
    self.itemConditionReturning = itemConditionReturning
    self.contractExpectationsMinimum = contractExpectationsMinimum
    self.contractExpectationsMaximum = contractExpectationsMaximum
  }
  
  func overWrite(contract: Contract)
  {
    title  = contract.title
    photo  = contract.photo
    video  = contract.video
    sound  = contract.sound
    remindDate  = contract.remindDate
    remindTime  = contract.remindTime
    remindTimeSpan  = contract.remindTimeSpan
    useTimeSpan  = contract.useTimeSpan
    type  = contract.type
    lenders  = contract.lenders
    borrowers  = contract.borrowers
    lenderShares = contract.lenderShares
    borrowerShares = contract.borrowerShares
    monetaryValue  = contract.monetaryValue
    tags  = contract.tags
    dateCreated  = contract.dateCreated
    dateDue  = contract.dateDue
    notes  = contract.notes
    simplifyGroupDebts  = contract.simplifyGroupDebts
//    locationCreated  = contract.locationCreated
//    locationDue  = contract.locationDue
    priority  = contract.priority
    isStarred  = contract.isStarred
    incompleteContractReminder  = contract.incompleteContractReminder
    reoccurringContractRate  = contract.reoccurringContractRate
    reoccurringContractDurration  = contract.reoccurringContractDurration
    remindContractees  = contract.remindContractees
    itemDescription  = contract.itemDescription
    itemConditionReceived  = contract.itemConditionReceived
    itemConditionReturning  = contract.itemConditionReturning
    contractExpectationsMinimum  = contract.contractExpectationsMinimum
    contractExpectationsMaximum  = contract.contractExpectationsMaximum
  }
}





protocol PercentagePicker
{
  var percentage: UIPickerView! { get }
  var saved: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!) { get set }
  var current: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!) { get set }
}





protocol Segueable
{
  func performSegue(#segueFrom: String, segueTo: String)
}





protocol Refreshable
{
  func reloadData()
  func refreshView(notification: NSNotification)
}





protocol MonetaryValue
{
  var monetaryValue: UITextField! { get }
}




protocol MonetaryValueAdjustableWidth
{
  var monetaryValueWidthConstraint: NSLayoutConstraint! { get }
}