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
  let managedObjectContext: NSManagedObjectContext
  let mainData: NSManagedObject
  var listType: Type
  
  class Contract
  {
    var photo: [String]
    var video: [String]
    var sound: [String]
    var remindDate: NSDate
    var remindTime: NSDate
    var remindTimeSpan: NSTimeInterval
    var useTimeSpan: Bool
    var type: Type
    var lenders: [String: Float]
    var borrowers: [String: Float]
    var monetaryValue: Float
    var category: String
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
    var name: String
    
    init(name: String, var photo: [String], video: [String], sound: [String],remindDate: NSDate, remindTime: NSDate, remindTimeSpan: NSTimeInterval, useTimeSpan: Bool, type: Type, lenders: [String: Float], borrowers: [String: Float], monetaryValue: Float, category: String, dateCreated: NSDate, dateDue: NSDate, notes: String,simplifyGroupDebts: Bool, locationCreated: AnyObject, locationDue: AnyObject, priority: Int, isStarred: Bool, incompleteContractReminder: NSDate, reoccurringContractRate: NSTimeInterval, reoccurringContractDurration: NSDate, remindContractees: [String: NSDate], itemDescription: String, itemConditionReceived: String, itemConditionReturning: String, contractExpectationsMinimum: String, contractExpectationsMaximum: String)
    {
      self.name = name
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
      self.category = category
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
  
  private init()
  {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName:"MainData")
    var error: NSError?
    
    if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    {
      if (fetchedResults == [])
      {
        //Initialize App constants and variables
        listType = Type.Money
        
        //Create mainData Core Data storage object to save all main data values
        let entity =  NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)
        mainData = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        mainData.setValue(listType.rawValue, forKey: "listType")
        var error: NSError?
        
        if !managedObjectContext.save(&error)
        {
          println("Could not save \(error), \(error?.userInfo)")
        }
      }
      else
      {
        //Load saved data
        mainData = fetchedResults[0]
        let temporaryExtractedDatum = mainData.valueForKey("listType")! as Int
        listType = Type(rawValue: temporaryExtractedDatum)!
      }
    }
    else
    {
      //TODO - Figure out how to throw an error here instead of assinging a bogus value to an undefined variable or constant.
      mainData = NSManagedObject(entity: NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
      listType = Type.Money
      println("Could not fetch \(error), \(error!.userInfo)")
    }
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
  
  func compare(typeOther: Type) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}