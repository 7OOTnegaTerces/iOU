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
  var listType: Type
  {
    get
    {
      let temporaryExtractedDatum = mainData.valueForKey("listType")! as Int
      return Type(rawValue: temporaryExtractedDatum)!
      
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
  
  var temporaryData: [Any]
  var newContractTitle: String
  var newContractType: Type
  var newContractMonetaryValue: Float
  var newContractLenders: [String: Float]
  
  private init()
  {
    //Initalize Temporary Data and New Contract data values.
    self.temporaryData = []
    self.newContractTitle = ""
    self.newContractType = Type(rawValue: 0)!
    self.newContractMonetaryValue = 0.0
    self.newContractLenders = [:]
    
    //Set it up so that we can save and load variables.
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName:"MainData")
    var error: NSError?
    
    if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    {
      if (fetchedResults == [])
      {
        //Create mainData Core Data storage object to save all main app data values.
        let entity =  NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)
        mainData = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        //Initialize variables that do get saved.
        listType = Type(rawValue: 0)!
        currency = Currency.USD
      }
      else
      {
        //Initialize mainData.
        mainData = fetchedResults[0]
      }
    }
    else
    {
      println("Could not fetch \(error), \(error!.userInfo)")
      
      //TODO - Figure out how to throw an error here instead of assinging a bogus value to an undefined variable or constant.
      mainData = NSManagedObject(entity: NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
    }
  }
  
  func resetNewContractData()
  {
    self.temporaryData = []
    self.newContractTitle = ""
    self.newContractType = Type(rawValue: 0)!
    self.newContractMonetaryValue = 0.0
    self.newContractLenders = [:]
  }
  
  private func saveToMainData(key: String, dataValue: AnyObject)
  {
    mainData.setValue(dataValue, forKey: key)
    var error: NSError?
    
    if (!managedObjectContext.save(&error))
    {
      println("Could not save \(error), \(error?.userInfo)")
    }
  }
  
  func mostPopularContractType() -> (Type)
  {
    //TODO - Finish this method...
    return Type.Item
  }
  
}

enum Type: Int
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
  
  func compare(typeOther: Type) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
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

class Contract
{
  var title: String
  var type: Type
  var monetaryValue: Float
  var lenders: [String: Float]
  
  var photo: [String]
  var video: [String]
  var sound: [String]
  var remindDate: NSDate
  var remindTime: NSDate
  var remindTimeSpan: NSTimeInterval
  var useTimeSpan: Bool
  var borrowers: [String: Float]
  var tags: [String]
  var dateCreated: NSDate
  var dateDue: NSDate
  var notes: String
  var simplifyGroupDebts: Bool
  var locationCreated: AnyObject
  var locationDue: AnyObject
  var priority: Int
  var isStarred: Bool
  var incompleteContractReminder: NSDate
  var reoccurringContractRate: NSTimeInterval
  var reoccurringContractDurration: NSDate
  var remindContractees: [String: NSDate]
  var itemDescription: String
  var itemConditionReceived: String
  var itemConditionReturning: String
  var contractExpectationsMinimum: String
  var contractExpectationsMaximum: String
  
  init(title: String, photo: [String], video: [String], sound: [String],remindDate: NSDate, remindTime: NSDate, remindTimeSpan: NSTimeInterval, useTimeSpan: Bool, type: Type, lenders: [String: Float], borrowers: [String: Float], monetaryValue: Float, tags: [String], dateCreated: NSDate, dateDue: NSDate, notes: String,simplifyGroupDebts: Bool, locationCreated: AnyObject, locationDue: AnyObject, priority: Int, isStarred: Bool, incompleteContractReminder: NSDate, reoccurringContractRate: NSTimeInterval, reoccurringContractDurration: NSDate, remindContractees: [String: NSDate], itemDescription: String, itemConditionReceived: String, itemConditionReturning: String, contractExpectationsMinimum: String, contractExpectationsMaximum: String)
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
    self.monetaryValue = monetaryValue
    self.tags = tags
    self.dateCreated = dateCreated
    self.dateDue = dateDue
    self.notes = notes
    self.simplifyGroupDebts = simplifyGroupDebts
    self.locationCreated = locationCreated
    self.locationDue = locationDue
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
}

extension String
{
  subscript (i: Int) -> (String)
  {
    let characterAtI = Array(self)[i]
    return String(characterAtI)
  }
  
  subscript (r: Range<Int>) -> (String)
  {
    let start = advance(startIndex, r.startIndex)
    let end = advance(startIndex, r.endIndex)
    let range = Range(start: start, end: end)
    return substringWithRange(range)
  }
  
  var floatValue: Float
  {
    return (self as NSString).floatValue
  }
}