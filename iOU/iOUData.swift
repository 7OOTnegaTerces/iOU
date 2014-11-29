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





struct SortableDictionary<Key: Hashable, Value>
{
  typealias KeyType = Key
  typealias ValueType = Value
  private var dictionary: [Key: Value]
  private var sortedKeys: [Key]
  private var valueSortKeyID: String?
  private var valueSortKey: ((Value, Value) -> Bool)?
  private var keySortKeyID: String?
  private var keySortKey: ((Key, Key) -> Bool)?
  private var sortingByValues: Bool
  var sortByValues: Bool
  {
    get
    {
      return sortingByValues
    }
    set
    {
      if (newValue && valueSortKey == nil)
      {
        return
      }
      else if (!newValue && keySortKey == nil)
      {
        return
      }
      
      sortingByValues = newValue
      self.sort()
    }
  }
  var count: Int
  {
      return sortedKeys.count
  }
  var currentValueSort: (String?, ((Value, Value) -> Bool)?)
  {
      return (valueSortKeyID, valueSortKey)
  }
  var currentKeySort: (String?, ((Key, Key) -> Bool)?)
  {
      return (keySortKeyID, keySortKey)
  }
  var isEmpty: Bool
  {
      return sortedKeys.isEmpty
  }
  var capacity: Int
  {
      return sortedKeys.capacity
  }
  var keys: [Key]
  {
      return sortedKeys
  }
  var values: [Value]
  {
      var valuesArray: [Value] = []
      
      for i in 0..<self.count
      {
        valuesArray.append(self[i]!)
      }
      
      return valuesArray
  }
  var getDictionary: [Key: Value]
  {
      return dictionary
  }
  
  
  init(valueSortKey: (Value, Value) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.valueSortKey = valueSortKey
    sortingByValues = true
  }
  
  init(valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.valueSortKeyID = valueSortKeyID
    self.valueSortKey = valueSortKey
    sortingByValues = true
  }
  
  init(dictionary: [Key: Value], valueSortKey: (Value, Value) -> Bool)
  {
    self.dictionary = dictionary
    self.valueSortKey = valueSortKey
    sortedKeys = []
    sortingByValues = true
    self.sort()
  }
  
  init(dictionary: [Key: Value], valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool)
  {
    self.dictionary = dictionary
    self.valueSortKeyID = valueSortKeyID
    self.valueSortKey = valueSortKey
    sortedKeys = []
    sortingByValues = true
    self.sort()
  }
  
  init(keySortKey: (Key, Key) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.keySortKey = keySortKey
    sortingByValues = false
  }
  
  init(keySortKeyID: String, keySortKey: (Key, Key) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.keySortKeyID = keySortKeyID
    self.keySortKey = keySortKey
    sortingByValues = false
  }
  
  init(dictionary: [Key: Value], keySortKey: (Key, Key) -> Bool)
  {
    self.dictionary = dictionary
    self.keySortKey = keySortKey
    sortedKeys = []
    sortingByValues = false
    self.sort()
  }
  
  init(dictionary: [Key: Value], keySortKeyID: String, keySortKey: (Key, Key) -> Bool)
  {
    self.dictionary = dictionary
    self.keySortKeyID = keySortKeyID
    self.keySortKey = keySortKey
    sortedKeys = []
    sortingByValues = false
    self.sort()
  }
  
  init(sortByValues: Bool, valueSortKey: (Value, Value) -> Bool, keySortKey: (Key, Key) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.valueSortKey = valueSortKey
    self.keySortKey = keySortKey
    sortingByValues = sortByValues
  }
  
  init(sortByValues: Bool, valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool, keySortKeyID: String, keySortKey: (Key, Key) -> Bool)
  {
    dictionary = [:]
    sortedKeys = []
    self.valueSortKeyID = valueSortKeyID
    self.valueSortKey = valueSortKey
    self.keySortKeyID = keySortKeyID
    self.keySortKey = keySortKey
    sortingByValues = sortByValues
  }
  
  init(dictionary: [Key: Value], sortByValues: Bool, valueSortKey: (Value, Value) -> Bool, keySortKey: (Key, Key) -> Bool)
  {
    self.dictionary = dictionary
    self.valueSortKey = valueSortKey
    self.keySortKey = keySortKey
    sortedKeys = []
    sortingByValues = sortByValues
    self.sort()
  }
  
  init(dictionary: [Key: Value], sortByValues: Bool, valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool, keySortKeyID: String, keySortKey: (Key, Key) -> Bool)
  {
    self.dictionary = dictionary
    self.valueSortKeyID = valueSortKeyID
    self.valueSortKey = valueSortKey
    self.keySortKeyID = keySortKeyID
    self.keySortKey = keySortKey
    sortedKeys = []
    sortingByValues = sortByValues
    self.sort()
  }
  
  private init(dictionary: [Key: Value], sortByValues: Bool, valueSortKeyID: String?, valueSortKey: ((Value, Value) -> Bool)?, keySortKeyID: String?, keySortKey: ((Key, Key) -> Bool)?)
  {
    self.dictionary = dictionary
    self.valueSortKeyID = valueSortKeyID
    self.valueSortKey = valueSortKey
    self.keySortKeyID = keySortKeyID
    self.keySortKey = keySortKey
    sortedKeys = []
    sortingByValues = sortByValues
    self.sort()
  }
  
  subscript(key: Key) -> (Value?)
  {
    get
    {
      return dictionary[key]
    }
    set
    {
      insert(key: key, value: newValue)
    }
  }
  
  subscript(index: Int) -> (Value?)
  {
    get
    {
      let key = sortedKeys[index]
      return dictionary[key]
    }
    set
    {
      insert(index: index, value: newValue)
    }
  }
  
  subscript(subRange: Range<Int>) -> ([Value?])
  {
    get
    {
      let keys = sortedKeys[subRange]
      var values: [Value?] = []
      
      for key in keys
      {
        values.append(dictionary[key])
      }
      
      return values
    }
    set
    {
      let span = subRange.endIndex - subRange.startIndex
      for i in 0...span
      {
        let index = subRange.startIndex + i
        
        if (i < newValue.count)
        {
          insert(index: index, value: newValue[i])
        }
        else
        {
          insert(index: index, value: nil)
        }
      }
    }
  }
  
  mutating func newSort(valueSortKey: (Value, Value) -> Bool) -> ((Value, Value) -> Bool)?
  {
    self.valueSortKeyID = nil
    let oldValueSortKey = self.valueSortKey
    self.valueSortKey = valueSortKey
    
    self.sortingByValues = true
    
    self.sort()
    
    return oldValueSortKey
  }
  
  mutating func newSort(valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool) -> (oldValueSortKeyID: String?, oldValueSortKey: ((Value, Value) -> Bool)?)
  {
    let oldValueSortKeyID = self.valueSortKeyID
    self.valueSortKeyID = valueSortKeyID
    let oldValueSortKey = self.valueSortKey
    self.valueSortKey = valueSortKey
    
    self.sortingByValues = true
    
    self.sort()
    
    return (oldValueSortKeyID, oldValueSortKey)
  }
  
  mutating func newSort(keySortKey: (Key, Key) -> Bool) -> ((Key, Key) -> Bool)?
  {
    self.valueSortKeyID = nil
    let oldKeySortKey = self.keySortKey
    self.keySortKey = keySortKey
    
    self.sortingByValues = false
    
    self.sort()
    
    return oldKeySortKey
  }
  
  mutating func newSort(keySortKeyID: String, keySortKey: (Key, Key) -> Bool) -> (oldKeySortKeyID: String?, oldKeySortKey: ((Key, Key) -> Bool)?)
  {
    let oldKeySortKeyID = self.keySortKeyID
    self.keySortKeyID = keySortKeyID
    let oldKeySortKey = self.keySortKey
    self.keySortKey = keySortKey
    
    self.sortingByValues = false
    
    self.sort()
    
    return (oldKeySortKeyID, oldKeySortKey)
  }
  
  mutating func newSort(sortByValues: Bool, valueSortKey: (Value, Value) -> Bool, keySortKey: (Key, Key) -> Bool) -> (oldValueSortKey: ((Value, Value) -> Bool)?, oldKeySortKey: ((Key, Key) -> Bool)?)
  {
    self.valueSortKeyID = nil
    let oldValueSortKey = self.valueSortKey
    self.valueSortKey = valueSortKey
    
    self.keySortKeyID = nil
    let oldKeySortKey = self.keySortKey
    self.keySortKey = keySortKey
    
    self.sort()
    
    return (oldValueSortKey, oldKeySortKey)
  }
  
  mutating func newSort(sortByValues: Bool, valueSortKeyID: String, valueSortKey: (Value, Value) -> Bool, keySortKeyID: String, keySortKey: (Key, Key) -> Bool) -> (oldValueSortKeyID: String?, oldValueSortKey: ((Value, Value) -> Bool)?, oldKeySortKeyID: String?, oldKeySortKey: ((Key, Key) -> Bool)?)
  {
    let oldValueSortKeyID = self.valueSortKeyID
    self.valueSortKeyID = valueSortKeyID
    let oldValueSortKey = self.valueSortKey
    self.valueSortKey = valueSortKey
    
    let oldKeySortKeyID = self.keySortKeyID
    self.keySortKeyID = keySortKeyID
    let oldKeySortKey = self.keySortKey
    self.keySortKey = keySortKey
    
    sortingByValues = sortByValues
    
    self.sort()
    
    return (oldValueSortKeyID, oldValueSortKey, oldKeySortKeyID, oldKeySortKey)
  }
  
  private mutating func sort()
  {
    sortedKeys = []
    for (key, value) in dictionary
    {
      insert(key: key, value: value)
    }
  }
  
  mutating func insert(#key: Key, value: Value?) -> (Value?)
  {
    let oldValue = dictionary[key]
    
    //If the new value is nil, then delete the old value it is to replace
    if (value == nil)
    {
      dictionary.removeValueForKey(key)
      sortedKeys = sortedKeys.filter {$0 != key}
    }
    else
    {
      var index: Int
      
      //Otherwise, find the correct index depeding on whether sorting is being done on the value or the key passed in and add the key to the sortedKeys and the value to the dictionary.
      if (sortingByValues)
      {
        index = findInsertionIndex(upperBound: self.count, lowerBound: 0, value: oldValue!)
      }
      else
      {
        index = findInsertionIndex(upperBound: self.count, lowerBound: 0, key: key)
      }
      
      sortedKeys.insert(key, atIndex: index)
      dictionary[key] = value
    }
    
    return oldValue
  }
  
  mutating func insert(#index: Int, value: Value?) -> (Value?)
  {
    let key = sortedKeys[index]
    return insert(key: key, value: value)
  }
  
  private func findInsertionIndex(#upperBound: Int, lowerBound: Int, value: Value) -> (Int)
  {
    let span = upperBound - lowerBound
    
    //If there is no span insert it at the lowerbound.
    if (span == 0)
    {
      return lowerBound
    }
      //If the two bounds are right next to each other then the value to be inserted must belong adjacent to one of them.  Assign the insertion index so that it comes just after the element the value is equal to, if any, to preserve safe sort order.
    else if (span == 1)
    {
      if (valueSortKey!(self[upperBound]!, value))
      {
        return upperBound + 1
      }
      else if (valueSortKey!(value, self[lowerBound]!))
      {
        return lowerBound
      }
      else
      {
        return upperBound
      }
    }
    
    //Otherwise, find the halfway point between the two bounds...
    let halfspan = round(Double(span) / 2.0)
    let halfWay = lowerBound + Int(halfspan)
    
    //...and determine if the value to be inserted is greater than, less than, or equal to the halfway point value.  If equal, return the haflway point plus one for a safe sort, or use it to form a new set of boundaries and recursively search deeper.
    if (valueSortKey!(value, self[halfWay]!))
    {
      return findInsertionIndex(upperBound: halfWay, lowerBound: lowerBound, value: value)
    }
    else if (valueSortKey!(self[halfWay]!, value))
    {
      return findInsertionIndex(upperBound: upperBound, lowerBound: halfWay, value: value)
    }
    else
    {
      return halfWay + 1
    }
  }
  
  private func findInsertionIndex(#upperBound: Int, lowerBound: Int, key: Key) -> (Int)
  {
    let span = upperBound - lowerBound
    
    //If there is no span insert it at the lowerbound.
    if (span == 0)
    {
      return lowerBound
    }
      //If the two bounds are right next to each other then the value to be inserted must belong adjacent to one of them.  Assign the insertion index so that it comes just after the element the value is equal to, if any, to preserve safe sort order.
    else if (span == 1)
    {
      if (keySortKey!(sortedKeys[upperBound], key))
      {
        return upperBound + 1
      }
      else if (keySortKey!(key, sortedKeys[lowerBound]))
      {
        return lowerBound
      }
      else
      {
        return upperBound
      }
    }
    
    //Otherwise, find the halfway point between the two bounds...
    let halfspan = round(Double(span) / 2.0)
    let halfWay = lowerBound + Int(halfspan)
    
    //...and determine if the value to be inserted is greater than, less than, or equal to the halfway point value.  If equal, return the haflway point plus one for a safe sort, or use it to form a new set of boundaries and recursively search deeper.
    if (keySortKey!(key, sortedKeys[halfWay]))
    {
      return findInsertionIndex(upperBound: halfWay, lowerBound: lowerBound, key: key)
    }
    else if (keySortKey!(sortedKeys[halfWay], key))
    {
      return findInsertionIndex(upperBound: upperBound, lowerBound: halfWay, key: key)
    }
    else
    {
      return halfWay + 1
    }
  }
  
  mutating func remove(key: Key) -> (Value?)
  {
    let value = self[key]
    self[key] = nil
    return value
  }
  
  mutating func remove(index: Int) -> (Value)
  {
    let value = self[index]
    self[index] = nil
    return value!
  }
  
  mutating func removeLast() -> (Value)
  {
    let lastIndex = self.count - 1
    return self.remove(lastIndex)
  }
  
  mutating func removeAll(keepCapacity: Bool = false)
  {
    dictionary.removeAll(keepCapacity: keepCapacity)
    sortedKeys.removeAll(keepCapacity: keepCapacity)
  }
  
  mutating func reserveCapacity(minimumCapacity: Int)
  {
    sortedKeys.reserveCapacity(minimumCapacity)
  }
  
  func sorted(valueSortKey: (Value, Value) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortByValues: sortByValues, valueSortKeyID: valueSortKeyID, valueSortKey: valueSortKey, keySortKeyID: keySortKeyID, keySortKey: keySortKey)
  }
  
  func filter(includeElement: (Value) -> Bool) -> (SortableDictionary)
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in self.dictionary
    {
      if (includeElement(value))
      {
        newDictionary[key] = value
      }
    }
    
    return SortableDictionary(dictionary: newDictionary, sortByValues: sortByValues, valueSortKeyID: valueSortKeyID, valueSortKey: valueSortKey, keySortKeyID: keySortKeyID, keySortKey: keySortKey)
  }
  
  func filter(includeElement: (Key) -> Bool) -> (SortableDictionary)
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in self.dictionary
    {
      if (includeElement(key))
      {
        newDictionary[key] = value
      }
    }
    
    return SortableDictionary(dictionary: newDictionary, sortByValues: sortByValues, valueSortKeyID: valueSortKeyID, valueSortKey: valueSortKey, keySortKeyID: keySortKeyID, keySortKey: keySortKey)
  }
  
  func map(transform: (Value) -> Value) -> (SortableDictionary)
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in self.dictionary
    {
      let newValue = transform(value)
      newDictionary[key] = newValue
    }
    
    return SortableDictionary(dictionary: newDictionary, sortByValues: sortByValues, valueSortKeyID: valueSortKeyID, valueSortKey: valueSortKey, keySortKeyID: keySortKeyID, keySortKey: keySortKey)
  }
  
  //  func reduce<U>(initial: U, combine: (U, Value) -> U) -> U
  //  {
  //
  //  }
  
  func combine(otherSortableDictionary: SortableDictionary) -> (SortableDictionary)
  {
    var newSortableDictionary = SortableDictionary(dictionary: self.dictionary, valueSortKey: self.valueSortKey!)
    
    for (key, value) in otherSortableDictionary.dictionary
    {
      newSortableDictionary[key] = value
    }
    
    return newSortableDictionary
  }
  
  //  func print() -> String
  //  {
  //    let printString = "["
  //
  //    for i in 0..<self.count
  //    {
  //      printString += "\(sortedKeys[i]) "
  //    }
  //  }
}