//
//  MyLibrary.swift
//  iOU
//
//  Created by Tateni Urio on 1/11/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import Foundation

extension String
{
  subscript (index: Int) -> (String)
  {
    let characterAtIndex = Array(self)[index]
    return String(characterAtIndex)
  }
  
  subscript (range: Range<Int>) -> (String)
  {
    let start = advance(startIndex, range.startIndex)
    let end = advance(startIndex, range.endIndex)
    let range = Range(start: start, end: end)
    return substringWithRange(range)
  }
  
  init(_ int: Int)
  {
    self = "\(int)"
  }
  
  init(_ float: Float)
  {
    self = "\(float)"
  }
  
  init(_ double: Double)
  {
    self = "\(double)"
  }
  
  init(_ bool: Bool)
  {
    if (bool)
    {
      self = "true"
    }
    else
    {
      self = "false"
    }
  }
  
  var floatValue: Float
  {
    return (self as NSString).floatValue
  }
  
  var doubleValue: Double
  {
    return (self as NSString).doubleValue
  }
}




extension Int
{
  subscript (index: Int) -> (Int)
    {
      let greaterTenDivisor = Int(pow(Double(10), Double(index + 1)))
      let digitsAboveIndex = (self / greaterTenDivisor) * 10
      let tenDivisor = Int(pow(Double(10), Double(index)))
      let digit = self / tenDivisor
      return digit - digitsAboveIndex
  }
  subscript (range: Range<Int>) -> (Int)
    {
      let greaterTenDivisor = Int(pow(Double(10), Double(range.endIndex)))
      let digitsAboveRange = (self / greaterTenDivisor) * greaterTenDivisor
      let lesserTenDivisor = Int(pow(Double(10), Double(range.startIndex)))
      let digits = self - digitsAboveRange
      return digits / lesserTenDivisor
  }
}





enum SortType: Int
{
  case Value = 0
  case Key, Manual
  
  func toString() -> (String)
  {
    switch self
    {
    case .Value:
      return "Value"
    case .Key:
      return "Key"
    case .Manual:
      return "Manual"
    }
  }
  
  func compare(typeOther: SortType) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





struct SortableDictionary<Key: Hashable, Value>
{
  typealias KeyType = Key
  typealias ValueType = Value
  private var dictionary: [Key: Value]
  private var sortedKeys: [Key] = []
  private var sortedValues: [Value] = []
  private var valueSortID: String? //Used to identify sort used when saving to or loading from CoreData or other save structure.
  private var valueSort: ((Value, Value) -> Bool)?
  private var keySortID: String? //Used to identify sort used when saving to or loading from CoreData or other save structure.
  private var keySort: ((Key, Key) -> Bool)?
  private var sortingType: SortType
  var sortType: SortType
    {
    get
    {
      return sortingType
    }
    set
    {
      if (newValue == SortType.Value && valueSort == nil)
      {
        return
      }
      else if (newValue == SortType.Key && keySort == nil)
      {
        return
      }
      
      sortingType = newValue
      sort()
    }
  }
  var count: Int
    {
      return dictionary.count
  }
  var currentValueSort: (valueSortID: String?, valueSort: ((Value, Value) -> Bool)?)
    {
      return (valueSortID, valueSort)
  }
  var currentKeySort: (keySortID: String?, keySort:((Key, Key) -> Bool)?)
    {
      return (keySortID, keySort)
  }
  var isEmpty: Bool
    {
      return dictionary.isEmpty
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
      return sortedValues
  }
  var unsortedDictionary: [Key: Value]
    {
      return dictionary
  }
  var saveStateData: (dictionary: [Key: Value], valueSortID: String?, keySortID: String?)
    {
      return (dictionary, valueSortID, keySortID)
  }
  
  init(dictionary: [Key: Value] = [:])
  {
    self = SortableDictionary(dictionary: dictionary, sortType: SortType.Manual, valueSortID: nil, valueSort: nil, keySortID: nil, keySort: nil)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType = SortType.Value, valueSortID: String = "", valueSort: (Value, Value) -> Bool)
  {
    if (sortType == SortType.Key)
    {
      fatalError("Cannot set sort type to Key without specifying a key sort.")
    }
    
    let sortID: String? = (valueSortID == "") ? nil : valueSortID
    
    self = SortableDictionary(dictionary: dictionary, sortType: sortType, valueSortID: sortID, valueSort: valueSort, keySortID: nil, keySort: nil)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType = SortType.Key, keySortID: String = "", keySort: (Key, Key) -> Bool)
  {
    if (sortType == SortType.Value)
    {
      fatalError("Cannot set sort type to Value without specifying a value sort.")
    }
    
    let sortID: String? = (keySortID == "") ? nil : keySortID
    
    self = SortableDictionary(dictionary: dictionary, sortType: SortType.Key, valueSortID: nil, valueSort: nil, keySortID: sortID, keySort: keySort)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType, valueSortID: String = "", valueSort: (Value, Value) -> Bool, keySortID: String = "", keySort: (Key, Key) -> Bool)
  {
    let sortIDValue: String? = (valueSortID == "") ? nil : valueSortID
    let sortIDKey: String? = (keySortID == "") ? nil : keySortID
    
    self = SortableDictionary(dictionary: dictionary, sortType: sortType, valueSortID: sortIDValue, valueSort: valueSort, keySortID: sortIDKey, keySort: keySort)
  }
  
  init(sortedDictionary: SortableDictionary, includeDictionary: Bool = true)
  {
    if (includeDictionary)
    {
      self = SortableDictionary(dictionary: sortedDictionary.dictionary, sortType: sortedDictionary.sortType, valueSortID: sortedDictionary.valueSortID, valueSort: sortedDictionary.valueSort, keySortID: sortedDictionary.keySortID, keySort: sortedDictionary.keySort)
    }
    else
    {
      self = SortableDictionary(dictionary: [:], sortType: sortedDictionary.sortType, valueSortID: sortedDictionary.valueSortID, valueSort: sortedDictionary.valueSort, keySortID: sortedDictionary.keySortID, keySort: sortedDictionary.keySort)
    }
  }
  
  private init(dictionary: [Key: Value], sortType: SortType, valueSortID: String?, valueSort: ((Value, Value) -> Bool)?, keySortID: String?, keySort: ((Key, Key) -> Bool)?)
  {
    self.dictionary = dictionary
    
    self.valueSortID = valueSortID
    self.valueSort = valueSort
    self.keySortID = keySortID
    self.keySort = keySort
    
    sortingType = sortType
    
    sort()
  }
  
  subscript(key: Key) -> (Value?)
  {
    get
    {
      return dictionary[key]
    }
    set
    {
      edit(addUpdateOrRemoveKey: key, withNewOrNilValue: newValue)
    }
  }
  
  subscript(index: Int) -> ((key: Key, value: Value))
  {
    get
    {
      return (sortedKeys[index], sortedValues[index])
    }
  }
  
  subscript(subRange: Range<Int>) -> ([(key: Key, value: Value)])
  {
    get
    {
      var range: [(key: Key, value: Value)] = []
      
      for i in subRange.startIndex...subRange.endIndex
      {
        let key = sortedKeys[i]
        let value = sortedValues[i]
        let keyValue = (key: key, value: value)
        range.append(keyValue)
      }
      
      return range
    }
  }
  
  mutating func newSort(sortType: SortType = SortType.Value, valueSortID: String = "", valueSort: (Value, Value) -> Bool)
    -> (oldValueSortID: String?, oldValueSort: ((Value, Value) -> Bool)?)
  {
    if (sortType == SortType.Key && keySort == nil)
    {
      fatalError("Cannot set sort type to Key without specifying a key sort.")
    }
    
    let sortID: String? = (valueSortID == "") ? nil : valueSortID
    
    let results = newSort(SortType.Value, valueSortID: sortID, valueSort: valueSort, keySortID: nil, keySort: nil)
    return (results.oldValueSortID, results.oldValueSort)
  }
  
  mutating func newSort(sortType: SortType = SortType.Key, keySortID: String = "", keySort: (Key, Key) -> Bool)
    -> (oldKeySortID: String?, oldKeySort: ((Key, Key) -> Bool)?)
  {
    if (sortType == SortType.Value && valueSort == nil)
    {
      fatalError("Cannot set sort type to Value without specifying a value sort.")
    }
    
    let sortID: String? = (keySortID == "") ? nil : keySortID
    
    let results = newSort(SortType.Key, valueSortID: nil, valueSort: nil, keySortID: sortID, keySort: keySort)
    return (results.oldKeySortID, results.oldKeySort)
  }
  
  mutating func newSort(valueSortID: String = "", valueSort: (Value, Value) -> Bool, keySortID: String = "", keySort: (Key, Key) -> Bool)
    -> (oldValueSortID: String?, oldValueSort: ((Value, Value) -> Bool)?, oldKeySortID: String?, oldKeySort: ((Key, Key) -> Bool)?)
  {
    let sortIDValue: String? = (valueSortID == "") ? nil : valueSortID
    let sortIDKey: String? = (keySortID == "") ? nil : keySortID
    
    return newSort(sortType, valueSortID: sortIDValue, valueSort: valueSort, keySortID: sortIDKey, keySort: keySort)
  }
  
  mutating func newSort(sortType: SortType, valueSortID: String = "", valueSort: (Value, Value) -> Bool, keySortID: String = "", keySort: (Key, Key) -> Bool)
    -> (oldValueSortID: String?, oldValueSort: ((Value, Value) -> Bool)?, oldKeySortID: String?, oldKeySort: ((Key, Key) -> Bool)?)
  {
    let sortIDValue: String? = (valueSortID == "") ? nil : valueSortID
    let sortIDKey: String? = (keySortID == "") ? nil : keySortID
    
    return newSort(sortType, valueSortID: sortIDValue, valueSort: valueSort, keySortID: sortIDKey, keySort: keySort)
  }
  
  private mutating func newSort(sortType: SortType, valueSortID: String?, valueSort: ((Value, Value) -> Bool)?, keySortID: String?, keySort: ((Key, Key) -> Bool)?)
    -> (oldValueSortID: String?, oldValueSort: ((Value, Value) -> Bool)?, oldKeySortID: String?, oldKeySort: ((Key, Key) -> Bool)?)
  {
    var oldValueSortID: String?
    var oldValueSort: ((Value, Value) -> Bool)?
    
    if (valueSort != nil)
    {
      oldValueSortID = self.valueSortID
      self.valueSortID = valueSortID
      oldValueSort = self.valueSort
      self.valueSort = valueSort
    }
    
    var oldKeySortID: String?
    var oldKeySort: ((Key, Key) -> Bool)?
    
    if (keySort != nil)
    {
      oldKeySortID = self.keySortID
      self.keySortID = keySortID
      oldKeySort = self.keySort
      self.keySort = keySort
    }
    
    sortingType = sortType
    var reSort: Bool
    
    if (sortType == SortType.Value && valueSort != nil)
    {
      reSort = true
    }
    else if (sortType == SortType.Key && keySort != nil)
    {
      reSort = true
    }
    else
    {
      reSort = false
    }
    
    if (reSort)
    {
      sort()
    }
    
    return (oldValueSortID, oldValueSort, oldKeySortID, oldKeySort)
  }
  
  mutating func newDictionary(dictionary: [Key: Value] = [:]) -> ([Key: Value])
  {
    let oldDictionary = self.dictionary
    self.dictionary = dictionary
    
    sort()
    
    return oldDictionary
  }
  
  private mutating func sort()
  {
    if (sortingType == SortType.Manual)
    {
      return
    }
    
    let oldSortedValues = sortedValues
    sortedValues = []
    let oldSortedKeys = sortedKeys
    sortedKeys = []
    
    if (oldSortedValues.count == 0)
    {
      for (key, value) in dictionary
      {
        addNewValueArraysOnly(key: key, value: value)
      }
    }
    else
    {
      for i in 0..<count
      {
        let value = oldSortedValues[i]
        let key = oldSortedKeys[i]
        addNewValueArraysOnly(key: key, value: value)
      }
    }
  }
  
  private mutating func addNewValueArraysOnly(#key: Key, value: Value)
  {
    var index: Int
    
    //If sortedKeys and sortedValues is empyt, insert the new key and value at  the begining of the indexes.  Otherwise, find the correct index depeding on the sort type, then add them to sotedValues, sortedKeys, the dictionary.
    if (sortedValues.count == 0)
    {
      index = 0
    }
    else
    {
      index = findInsertionIndex(upperBound: sortedValues.count - 1, lowerBound: 0, value: value, key: key)
    }
    
    sortedValues.insert(value, atIndex: index)
    sortedKeys.insert(key, atIndex: index)
  }
  
  private mutating func addNewValue(#key: Key, value: Value)
  {
    addNewValueArraysOnly(key: key, value: value)
    dictionary[key] = value
  }
  
  private func findInsertionIndex(#upperBound: Int, lowerBound: Int, value: Value, key: Key) -> (Int)
  {
    //If sorting manually, insert at end of the sorted dictionary.
    if (sortingType == SortType.Manual)
    {
      return upperBound + 1
    }
    
    let span = upperBound - lowerBound
    
    //If there are only one or two already sorted elements, determine if the new element to be added is less than either boundry element, or belongs after both of them.
    if (span <= 1)
    {
      if (sortingType == SortType.Value && valueSort!(value, sortedValues[lowerBound]))
      {
        return lowerBound
      }
      else if (sortingType == SortType.Value && valueSort!(value, sortedValues[upperBound]))
      {
        return upperBound
      }
      else if (sortingType == SortType.Key && keySort!(key, sortedKeys[lowerBound]))
      {
        return lowerBound
      }
      else if (sortingType == SortType.Key && keySort!(key, sortedKeys[upperBound]))
      {
        return upperBound
      }
      else
      {
        return upperBound + 1
      }
    }
    
    //Otherwise, find the halfway point between the two bounds...
    let halfspan = round(Double(span) / 2.0)
    let halfWay = lowerBound + Int(halfspan)
    
    //...and determine if the element to be inserted is greater than, less than, or equal to the halfway point element. If equal, return the haflway point plus one for a safe sort, or use it to form a new set of boundaries and recursively search deeper.
    if (sortingType == SortType.Value && valueSort!(value, sortedValues[halfWay]))
    {
      return findInsertionIndex(upperBound: halfWay, lowerBound: lowerBound, value: value, key: key)
    }
    else if (sortingType == SortType.Value && valueSort!(sortedValues[halfWay], value))
    {
      return findInsertionIndex(upperBound: upperBound, lowerBound: halfWay, value: value, key: key)
    }
    else if (sortingType == SortType.Key && keySort!(key, sortedKeys[halfWay]))
    {
      return findInsertionIndex(upperBound: halfWay, lowerBound: lowerBound, value: value, key: key)
    }
    else if (sortingType == SortType.Key && keySort!(sortedKeys[halfWay], key))
    {
      return findInsertionIndex(upperBound: upperBound, lowerBound: halfWay, value: value, key: key)
    }
    else
    {
      return halfWay + 1
    }
  }
  
  mutating func insert(#key: Key, value: Value)
  {
    if (hasKey(key))
    {
      fatalError("Key: \(key) already exsists in this sorted dictionary.")
    }
    
    addNewValue(key: key, value: value)
    dictionary[key] = value
  }
  
  mutating func insert(#element: (key: Key, value: Value))
  {
    insert(key: element.key, value: element.value)
  }
  
  mutating func insert(#keys: [Key], values: [Value])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    for i in 0..<count
    {
      insert(key: keys[i], value: values[i])
    }
  }
  
  mutating func insert(#elements: [(key: Key, value: Value)])
  {
    for element in elements
    {
      insert(element: element)
    }
  }
  
  mutating func insert(#dictionary: [Key: Value])
  {
    for (key, value) in dictionary
    {
      insert(key: key, value: value)
    }
  }
  
  mutating func insert(insertAtIndex index: Int, key: Key, value: Value)
  {
    if (index > count)
    {
      fatalError("Index out of bounds!")
    }
    else if (sortingType != SortType.Manual)
    {
      fatalError("Can not insert a (Key, Value) pair at a specific index unless using Manual sort.")
    }
    else if (hasKey(key))
    {
      fatalError("cannot insert a prexsisting Key. Key: \(key)")
    }
    
    sortedValues.insert(value, atIndex: index)
    sortedKeys.insert(key, atIndex: index)
    dictionary.updateValue(value, forKey: key)
  }
  
  mutating func insert(insertAtIndex index: Int, element: (key: Key, value: Value))
  {
    insert(insertAtIndex: index, key: element.key, value: element.value)
  }
  
  mutating func insert(insertAtIndex index: Int, keys: [Key], values: [Value])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    for i in 0..<count
    {
      insert(insertAtIndex: i + index, key: keys[i], value: values[i])
    }
  }
  
  mutating func insert(var insertAtIndex index: Int, elements: [(key: Key, value: Value)])
  {
    for element in elements
    {
      insert(insertAtIndex: index, element: element)
      index++
    }
  }
  
  mutating func insert(insertAtIndex index: Int, dictionary: [Key: Value])
  {
    for (key, value) in dictionary
    {
      insert(insertAtIndex: index, key: key, value: value)
    }
  }
  
  mutating func update(overwriteValueAtIndex index: Int, withNewValue value: Value) -> (Value)
  {
    if (index >= count)
    {
      fatalError("Index out of bounds!")
    }
    
    let oldValue = sortedValues[index]
    
    if (sortingType == SortType.Value)
    {
      let key = sortedKeys[index]
      remove(index: index)
      insert(key: key, value: value)
    }
    else
    {
      sortedValues[index] = value
    }
    
    return oldValue
  }
  
  mutating func update(overwriteValueForKey key: Key, withNewValue value: Value) -> (Value?)
  {
    let index = getIndex(forKey: key)
    
    if (index == nil)
    {
      return nil
    }
    else
    {
      let oldValue = update(overwriteValueAtIndex: index!, withNewValue: value)
      return oldValue
    }
  }
  
  mutating func update(overwriteWithNewElement element: (key: Key, value: Value)) -> (Value?)
  {
    return update(overwriteValueForKey: element.key, withNewValue: element.value)
  }
  
  mutating func update(overwriteKeyAtIndex index: Int, withExistingKey key: Key) -> (key: Key, value: Value)
  {
    if (sortingType != SortType.Manual)
    {
      fatalError("Indexs can only be updated while in Manual sort.")
    }
    else if (index >= count)
    {
      fatalError("Index out of bounds!")
    }
    else if (!hasKey(key))
    {
      fatalError("Key: \(key) does not already exsist.")
    }
    else if (key == sortedKeys[index])
    {
      fatalError("Key: \(key) already located at index: \(index).")
    }
    
    let value = self[key]!
    let oldValue = sortedValues[index]
    let oldKey = sortedKeys[index]
    remove(key: key)
    remove(key: oldKey)
    insert(insertAtIndex: index, key: key, value: value)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(overwriteKeyAtIndex index: Int, withNewKey key: Key) -> (key: Key, value: Value)
  {
    if (sortingType != SortType.Manual)
    {
      fatalError("Indexs can only be updated while in Manual sort.")
    }
    else if (index >= count)
    {
      fatalError("Index out of bounds!")
    }
    else if (hasKey(key))
    {
      fatalError("Key: \(key) already exsist.")
    }
    
    let oldValue = sortedValues[index]
    let oldKey = sortedKeys[index]
    remove(key: oldKey)
    insert(insertAtIndex: index, key: key, value: oldValue)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(overwriteKey oldKey: Key, withExistingKey key: Key) -> (key: Key, value: Value)
  {
    if (!hasKey(oldKey))
    {
      fatalError("OldKey: \(oldKey) does not already exsist at another index.")
    }
    
    let index = getIndex(forKey: oldKey)!
    return update(overwriteKeyAtIndex: index, withExistingKey: key)
  }
  
  mutating func update(overwriteKey oldKey: Key, withNewKey key: Key) -> (key: Key, value: Value)
  {
    if (!hasKey(oldKey))
    {
      fatalError("OldKey: \(oldKey) does not already exsist at another index.")
    }

    let index = getIndex(forKey: oldKey)!
    return update(overwriteKeyAtIndex: index, withNewKey: key)
  }
  
  mutating func update(overwriteElementAtIndex index: Int, withNewKey key: Key, andNewValue value: Value) -> (key: Key, value: Value)
  {
    if (sortingType != SortType.Manual)
    {
      fatalError("Indexs can only be updated while in Manual sort.")
    }
    else if (index >= count)
    {
      fatalError("Index out of bounds!")
    }
    else if (hasKey(key))
    {
      let keyIndex = getIndex(forKey: key)!
      
      if (index != keyIndex)
      {
        fatalError("Key: \(key) already exsist at another index.")
      }
    }
    
    let oldValue = sortedValues[index]
    let oldKey = sortedKeys[index]
    remove(key: oldKey)
    insert(insertAtIndex: index, key: key, value: value)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(overwriteValuesForKeys keys: [Key], withNewValues values: [Value]) -> ([Value?])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    var oldValues: [Value?] = []
    
    for i in 0..<count
    {
      let oldValue = update(overwriteValueForKey: keys[i], withNewValue: values[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(overwriteWithNewElements elements: [(key: Key, value: Value)]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for i in 0..<elements.count
    {
      let oldValue = update(overwriteWithNewElement: elements[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(updateWithNewDictionary dictionary: [Key: Value]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for element in dictionary
    {
      let oldValue = update(overwriteWithNewElement: element)
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(overwriteElementAtIndex index: Int, withNewElement element: (key: Key, value: Value)) -> (key: Key, value: Value)
  {
    return update(overwriteElementAtIndex: index, withNewKey: element.key, andNewValue: element.value)
  }
  
  mutating func update(overwriteKeysStartingAtIndex index: Int, withExistingKeys keys: [Key]) -> ([(key: Key, value: Value)])
  {
    var oldValues: [(key: Key, value: Value)] = []
    
    for i in 0..<keys.count
    {
      let oldValue = update(overwriteKeyAtIndex: i + index, withExistingKey: keys[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(overwriteElementsStartingAtIndex index: Int, withNewElements elements: [(key: Key, value: Value)]) -> ([(key: Key, value: Value)])
  {
    var oldValues: [(key: Key, value: Value)] = []
    
    for i in 0..<elements.count
    {
      let oldValue = update(overwriteElementAtIndex: index + i, withNewElement: elements[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(var overwriteElementsStartingAtIndex index: Int, withNewDictionary dictionary: [Key: Value]) -> ([(key: Key, value: Value)])
  {
    var oldValues: [(key: Key, value: Value)] = []
    
    for element: (Key, Value) in dictionary
    {
      let oldValue = update(overwriteElementAtIndex: index, withNewElement: element)
      oldValues.append(oldValue)
      index++
    }
    
    return oldValues
  }
  
  mutating func remove(#key: Key) -> (Value?)
  {
    let index = getIndex(forKey: key)
    
    if (index == nil)
    {
      return nil
    }
    else
    {
      let element = remove(index: index!)
      return element.value
    }
  }
  
  mutating func remove(#index: Int) -> (key: Key, value: Value)
  {
    let value = sortedValues.removeAtIndex(index)
    let key = sortedKeys.removeAtIndex(index)
    dictionary.removeValueForKey(key)
    return (key: key, value: value)
  }
  
  mutating func remove(#keys: [Key]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for key in keys
    {
      let oldValue = remove(key: key)
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func removeAll(keepCapacity: Bool = false)
  {
    sortedKeys.removeAll(keepCapacity: keepCapacity)
    sortedValues.removeAll(keepCapacity: keepCapacity)
    dictionary.removeAll(keepCapacity: keepCapacity)
  }
  
  mutating func edit(addUpdateOrRemoveKey key: Key, withNewOrNilValue value: Value?) -> (Value)
  {
    let index = getIndex(forKey: key)
    
    if (index == nil)
    {
      if (value != nil)
      {
        addNewValue(key: key, value: value!)
        return value!
      }
      else
      {
        fatalError("Cannot add a new key with a nil value to the dictionary.")
      }
    }
    else
    {
      return edit(updateOrRemoveAtIndex: index!, withNewOrNilValue: value)
    }
  }
  
  mutating func edit(updateOrRemoveAtIndex index: Int, withNewOrNilValue value: Value?) -> (Value)
  {
    let oldValue = sortedValues[index]
    let key = sortedKeys[index]
    
    if (value == nil)
    {
      remove(index: index)
    }
    else
    {
      update(overwriteValueForKey: key, withNewValue: value!)
    }
    
    return oldValue
  }
  
  mutating func edit(#index: Int, key: Key?, value: Value?) -> (key: Key?, value: Value?)
  {
    if (sortingType == SortType.Manual)
    {
      if (key != nil)
      {
        if (hasKey(key!))
        {
          let keyIndex = getIndex(forKey: key!)!
          
          if (index == keyIndex)
          {
            let oldValue = edit(addUpdateOrRemoveKey: key!, withNewOrNilValue: value)
            return (key: nil, value: oldValue)
          }
          else if (value != nil)
          {
            let oldValue = edit(addUpdateOrRemoveKey: key!, withNewOrNilValue: value)
            return (key: nil, value: oldValue)
          }
          else if (index < count)
          {
            let tuple = update(overwriteKeyAtIndex: index, withExistingKey: key!)
            
            var key: Key? = tuple.key
            var value: Value? = tuple.value
            return (key: key, value: value)
          }
          else
          {
            let oldValue = remove(key: key!)
            return (key: nil, value: oldValue)
          }
        }
        else if (value != nil)
        {
          insert(insertAtIndex: index, key: key!, value: value!)
          return (key: nil, value: nil)
        }
        else
        {
          fatalError("Cannot insert a Key with no Value.")
        }
      }
      else if (value != nil)
      {
        let oldValue = edit(updateOrRemoveAtIndex: index, withNewOrNilValue: value)
        return (key: nil, value: oldValue)
      }
      else
      {
        fatalError("Both Key and Value are nil.")
      }
    }
    else
    {
      fatalError("Cannot edit at a specific index unless using Manual sort.")
    }
  }
  
  mutating func edit(#element: (key: Key, value: Value)) -> (Value?)
  {
    return edit(addUpdateOrRemoveKey: element.key, withNewOrNilValue: element.value)
  }
  
  mutating func edit(#dictionary: [Key: Value]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for (key, value) in dictionary
    {
      let oldValue = edit(addUpdateOrRemoveKey: key, withNewOrNilValue: value)
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func overwrite(#index: Int, key: Key, value: Value) -> (key: Key, value: Value)
  {
    if (index >= count)
    {
      fatalError("Index out of bounds!")
    }
    else if (hasKey(key))
    {
      fatalError("Key: \(key) already exsists at another index.")
    }
    
    let oldValue = sortedValues[index]
    let oldKey = sortedKeys[index]
    remove(index: index)
    insert(insertAtIndex: index, key: key, value: value)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func overwrite(#index: Int, element: (key: Key, value: Value)) -> (key: Key, value: Value)
  {
    return overwrite(index: index, key: element.key, value: element.value)
  }
  
  mutating func shift(#index: Int, key: Key)
  {
    if (!hasKey(key))
    {
      fatalError("Key: \(key) does not already exsist at another index.")
    }
    
    let value = self[key]!
    remove(key: key)
    insert(insertAtIndex: index, key: key, value: value)
  }
  
  mutating func swap(#index1: Int, index2: Int)
  {
    if (index1 >= count || index2 >= count)
    {
      fatalError("Index out of bounds!")
    }
    else if (index1 == index2)
    {
      fatalError("Cannot swap, indexes are identical.")
    }
    
    let element1 = self[index1]
    let element2 = self[index2]
    remove(key: element1.key)
    remove(key: element2.key)
    
    if (index1 < index2)
    {
      insert(insertAtIndex: index1, element: element2)
      insert(insertAtIndex: index2, element: element1)
    }
    else
    {
      insert(insertAtIndex: index2, element: element1)
      insert(insertAtIndex: index1, element: element2)
    }
  }
  
  mutating func swap(key1: Key, key2: Key)
  {
    if (!hasKey(key1))
    {
      fatalError("Cannot swap, Key: \(key1) missing")
    }
    else if (!hasKey(key2))
    {
      fatalError("Cannot swap, Key: \(key2) missing")
    }
    
    let index1 = getIndex(forKey: key1)!
    let index2 = getIndex(forKey: key2)!
    return swap(index1: index1, index2: index2)
  }
  
  func getIndex(#forKey: Key) -> (Int?)
  {
    for i in 0..<sortedKeys.count
    {
      if (forKey == sortedKeys[i])
      {
        return i
      }
    }
    
    return nil
  }
  
  func hasKey(key: Key) -> (Bool)
  {
    return dictionary.indexForKey(key) != nil
  }
  
  func getElementIndex(element: (key: Key, value: Value)) -> (Int?)
  {
    return getIndex(forKey: element.key)
  }
  
  func hasElement(element: (key: Key, value: Value)) -> (Bool)
  {
    return hasKey(element.key)
  }
  
  mutating func removeLast() -> (key: Key, value: Value)
  {
    let lastIndex = count - 1
    return remove(index: lastIndex)
  }
  
  mutating func reserveCapacity(minimumCapacity: Int)
  {
    sortedKeys.reserveCapacity(minimumCapacity)
    sortedValues.reserveCapacity(minimumCapacity)
  }
  
  func sorted(valueSort: (Value, Value) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: SortType.Value, valueSortID: nil, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func sorted(valueSortID: String, valueSort: (Value, Value) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: SortType.Value, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func sorted(keySort: (Key, Key) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: SortType.Key, valueSortID: valueSortID, valueSort: valueSort, keySortID: nil, keySort: keySort)
  }
  
  func sorted(keySortID: String, keySort: (Key, Key) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: SortType.Key, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func sorted(sortType: SortType, valueSort: (Value, Value) -> Bool, keySort: (Key, Key) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: sortType, valueSortID: nil, valueSort: valueSort, keySortID: nil, keySort: keySort)
  }
  
  func sorted(sortType: SortType, valueSortID: String, valueSort: (Value, Value) -> Bool, keySortID: String, keySort: (Key, Key) -> Bool) -> (SortableDictionary)
  {
    return SortableDictionary(dictionary: dictionary, sortType: sortType, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func filter(includeElement: (Value) -> Bool) -> (SortableDictionary)
  {
    let newDictionary = filterDictionaryOnly(includeElement)
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func filter(includeElement: (Key) -> Bool) -> (SortableDictionary)
  {
    let newDictionary = filterDictionaryOnly(includeElement)
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func filterDictionaryOnly(includeElement: (Value) -> Bool) -> ([Key: Value])
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in dictionary
    {
      if (includeElement(value))
      {
        newDictionary[key] = value
      }
    }
    
    return newDictionary
  }
  
  func filterDictionaryOnly(includeElement: (Key) -> Bool) -> ([Key: Value])
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in dictionary
    {
      if (includeElement(key))
      {
        newDictionary[key] = value
      }
    }
    
    return newDictionary
  }
  
  func map(transform: (Value) -> Value) -> (SortableDictionary)
  {
    let newDictionary = mapDictionaryOnly(transform)
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSortID: valueSortID, valueSort: valueSort, keySortID: keySortID, keySort: keySort)
  }
  
  func mapDictionaryOnly(transform: (Value) -> Value) -> ([Key: Value])
  {
    var newDictionary: [Key: Value] = [:]
    
    for (key, value) in dictionary
    {
      let newValue = transform(value)
      newDictionary[key] = newValue
    }
    
    return newDictionary
  }
  
  //     func reduce<U>(initial: U, combine: (U, Value) -> U) -> U
  //     {
  //
  //     }
  
  func combine(otherSortableDictionary: SortableDictionary, overwriteOther: Bool = true) -> (SortableDictionary)
  {
    if (overwriteOther)
    {
      var newSortedDictionary = SortableDictionary(sortedDictionary: self)
      newSortedDictionary.insert(dictionary: otherSortableDictionary.dictionary)
      return newSortedDictionary
    }
    else
    {
      var newSortedDictionary = SortableDictionary(sortedDictionary: otherSortableDictionary)
      newSortedDictionary.insert(dictionary: self.dictionary)
      return newSortedDictionary
    }
  }
  
  func combineDictionaryOnly(otherSortableDictionary: SortableDictionary, overwriteOther: Bool = true) -> ([Key: Value])
  {
    return combine(otherSortableDictionary, overwriteOther: overwriteOther).dictionary
  }
  
  //     func print() -> String
  //     {
  //     let printString = "["
  //
  //     for i in 0..<count
  //     {
  //     printString += "\(sortedKeys[i]) "
  //     }
  //     }
}

func ==<Key: Equatable, Value: Equatable>(lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>) -> (Bool)
{
  return lhs.dictionary == rhs.dictionary
}

func !=<Key: Equatable, Value: Equatable>(lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>) -> (Bool)
{
  return lhs.dictionary != rhs.dictionary
}

func +<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>) -> (SortableDictionary<Key, Value>)
{
  var newSortedDictionary = lhs
  newSortedDictionary.insert(dictionary: rhs.dictionary)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>)
{
  lhs = lhs + rhs
}

func -<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>) -> (SortableDictionary<Key, Value>)
{
  var newSortedDictionary = lhs
  //  newSortedDictionary.remove(rhs.dictionary)
  return newSortedDictionary
}

func -=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>)
{
  lhs = lhs - rhs
}

func +<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: (key: Key, value: Value)) -> (SortableDictionary<Key, Value>)
{
  var newSortedDictionary = lhs
  newSortedDictionary.insert(element: rhs)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: (key: Key, value: Value))
{
  lhs.insert(element: rhs)
}

func -<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: (key: Key, value: Value)) -> (SortableDictionary<Key, Value>)
{
  var newSortedDictionary = lhs
  newSortedDictionary.remove(key: rhs.key)
  return newSortedDictionary
}

func -=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: (key: Key, value: Value))
{
  lhs.remove(key: rhs.key)
}

func ==<Key: Equatable, Value: Equatable>(lhs: SortableDictionary<Key, Value>, rhs: [Key: Value]) -> (Bool)
{
  return lhs.dictionary == rhs
}

func !=<Key: Equatable, Value: Equatable>(lhs: SortableDictionary<Key, Value>, rhs: [Key: Value]) -> (Bool)
{
  return lhs.dictionary != rhs
}

func +<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: [Key: Value]) -> (SortableDictionary<Key, Value>)
{
  var newSortedDictionary = lhs
  newSortedDictionary.insert(dictionary: rhs)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: [Key: Value])
{
  lhs = lhs + rhs
}