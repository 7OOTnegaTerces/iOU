//
//  MyLibrary.swift
//  iOU
//
//  Created by Tateni Urio on 1/11/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import Foundation
import UIKit


//MARK: - Extensions
extension String
{
  var floatValue: Float
  {
    return (self as NSString).floatValue
  }
  
  var doubleValue: Double
  {
    return (self as NSString).doubleValue
  }
  
  var integerValue: Int
  {
    return (self as NSString).integerValue
  }
  
  var count: Int
  {
    return Array(self.characters).count
  }
  
  var lastCharacter: Character
  {
    return self[self.count - 1]
  }
  
  var allButLastCharacter: String
  {
    return self[0..<self.count - 1]
  }
  
  var firstCharacter: Character
  {
    return self[0]
  }
  
  var allButFirstCharacter: String
  {
    return self[1..<self.count]
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
  
  subscript (index: Int) -> (Character)
  {
    return Array(self.characters)[index]
  }
  
  subscript (range: Range<Int>) -> (String)
  {
    let start = startIndex.advancedBy(range.startIndex)
    let end = startIndex.advancedBy(range.endIndex)
    let range = Range(start..<end)
    return substringWithRange(range)
  }
  
  mutating func replaceCharacter(atIndex index: String.CharacterView.Index, withCharacter character: Character)
  {
    removeAtIndex(index)
    insert(character, atIndex: index)
  }
  
  mutating func replaceCharacter(atIndex index: Int, withCharacter character: Character)
  {
    let characerIndex = startIndex.advancedBy(index)
    replaceCharacter(atIndex: characerIndex, withCharacter: character)
  }
}




extension Int
{
  var count: Int
  {
    get
    {
      let stringForm = String(self)
      let count = stringForm.count
      return count
    }
  }
  
  init (_ string: String)
  {
    self = string.integerValue
  }
  
  init (_ character: Character)
  {
    let string = String(Character)
    self = string.integerValue
  }
  
  subscript (index: Int) -> (Int)
  {
    if (index < 0)
    {
      return 0
    }
    else if (index > 18)
    {
      return 0
    }
    else if (index >= self.count)
    {
      return 0
    }
      
    let stringForm = String(self)
    let characterAtIndex = stringForm[index]
      
    return Int(characterAtIndex)
  }
  
  subscript (range: Range<Int>) -> (Int)
  {
    var range = range
    if (range.startIndex < 0)
    {
      range.startIndex = 0
    }
    else if ((range.startIndex > 18) || (range.startIndex >= self.count))
    {
      return 0
    }
    
    if (range.endIndex < 0)
    {
      return 0
    }
    else if (range.endIndex > 18)
    {
      range.endIndex = 18
    }
    else if (range.endIndex > self.count)
    {
      range.endIndex = self.count
    }
    
    let stringForm = String(self)
    let charactersAtIndex = stringForm[range]
    
    return Int(charactersAtIndex)
  }
}





extension Double
{
  var count: Int
  {
    get
    {
      let stringForm = String(self)
      let count = stringForm.count - 1
      return count
    }
  }
  var decimalLocation: Int
  {
    get
    {
      let integer = Int(self)
      let location = integer.count
      
      return location
    }
  }
  var decimalIndex: String.CharacterView.Index
  {
    get
    {
      let stringForm = String(self)
      let startIndex = stringForm.startIndex
      let decimalIndex = startIndex.advancedBy(decimalLocation)
      
      return decimalIndex
    }
  }
  
  init (_ string: String)
  {
    self = string.doubleValue
  }
  
  init (_ character: Character)
  {
    let string = String(Character)
    self = string.doubleValue
  }
  
  subscript (index: Int) -> (Int)
  {
    if (index < 0)
    {
      return 0
    }
    else if (index > 18)
    {
      return 0
    }
    else if (index >= self.count)
    {
      return 0
    }
    
    let stringForm = toStringWithoutDecimal()
    let characterAtIndex = stringForm[index]
    
    return Int(characterAtIndex)
  }
  
  subscript (range: Range<Int>) -> (Double)
  {
    var range = range
    if (range.startIndex < 0)
    {
      range.startIndex = 0
    }
    else if ((range.startIndex > 18) || (range.startIndex >= self.count))
    {
      return 0
    }
    
    if (range.endIndex < 0)
    {
      return 0
    }
    else if (range.endIndex > 18)
    {
      range.endIndex = 18
    }
    else if (range.endIndex > self.count)
    {
      range.endIndex = self.count
    }
    
    let stringForm = toStringWithoutDecimal()
    var charactersAtIndex = stringForm[range]
      
    if (range.contains(decimalLocation))
    {
      let startIndex = stringForm.startIndex
      let adjustedDecimalLocation = startIndex.advancedBy(decimalLocation - range.startIndex)
        charactersAtIndex.insert(".", atIndex: adjustedDecimalLocation)
    }
    else if (range.startIndex > decimalLocation)
    {
      let differnce = range.startIndex - decimalLocation
      var padding = "."
        
      for _ in 0 ..< differnce
      {
        padding += "0"
      }
        
      charactersAtIndex =+ padding
    }
    else if (range.endIndex < decimalLocation)
    {
      let differnce = decimalLocation - range.endIndex
      var padding = "."
        
      for _ in 0 ..< differnce
      {
        padding =+ "0"
      }
      
      charactersAtIndex += padding
    }
      
    return Double(charactersAtIndex)
  }
  
  func toStringWithoutDecimal() -> (String)
  {
    var stringForm = String(self)
    stringForm.removeAtIndex(decimalIndex)
    return stringForm
  }
}





extension NSIndexPath
{
  var coordinates: (section: Int, row: Int)
  {
    get
    {
      return (section: section, row: row)
    }
  }
}





//MARK: - Operators

//MARK: Exponent Operations
infix operator ^* { associativity left precedence 150 }

func ^*(lhs: Int, rhs: Int) -> (Double)
{
  return pow(Double(lhs), Double(rhs))
}

func ^*(lhs: Int, rhs: Float) -> (Double)
{
  return pow(Double(lhs), Double(rhs))
}

func ^*(lhs: Int, rhs: Double) -> (Double)
{
  return pow(Double(lhs), rhs)
}

func ^*(lhs: Float, rhs: Int) -> (Double)
{
  return pow(Double(lhs), Double(rhs))
}

func ^*(lhs: Float, rhs: Float) -> (Double)
{
  return pow(Double(lhs), Double(rhs))
}

func ^*(lhs: Float, rhs: Double) -> (Double)
{
  return pow(Double(lhs), rhs)
}

func ^*(lhs: Double, rhs: Int) -> (Double)
{
  return pow(lhs, Double(rhs))
}

func ^*(lhs: Double, rhs: Float) -> (Double)
{
  return pow(lhs, Double(rhs))
}

func ^*(lhs: Double, rhs: Double) -> (Double)
{
  return pow(lhs, rhs)
}



//MARK: Inverted Subractor Operations
infix operator =- { associativity right precedence 90 }

func =-(inout lhs: Int, rhs: Int)
{
  lhs = rhs - lhs
}

func =-(inout lhs: Float, rhs: Int)
{
  lhs = Float(rhs) - lhs
}

func =-(inout lhs: Float, rhs: Float)
{
  lhs = rhs - lhs
}

func =-(inout lhs: Double, rhs: Int)
{
  lhs = Double(rhs) - lhs
}

func =-(inout lhs: Double, rhs: Float)
{
  lhs = Double(rhs) - lhs
}

func =-(inout lhs: Double, rhs: Double)
{
  lhs = rhs - lhs
}



//MARK: Inverted Divisor Operations
infix operator =/ { associativity right precedence 90 }

func =/(inout lhs: Int, rhs: Int)
{
  lhs = rhs / lhs
}

func =/(inout lhs: Float, rhs: Int)
{
  lhs = Float(rhs) / lhs
}

func =/(inout lhs: Float, rhs: Float)
{
  lhs = rhs / lhs
}

func =/(inout lhs: Double, rhs: Int)
{
  lhs = Double(rhs) / lhs
}

func =/(inout lhs: Double, rhs: Float)
{
  lhs = Double(rhs) / lhs
}

func =/(inout lhs: Double, rhs: Double)
{
  lhs = rhs / lhs
}



//MARK: Int! Operations
func -=(inout lhs: Int!, rhs: Int)
{
  lhs = lhs - rhs
}

func +=(inout lhs: Int!, rhs: Int)
{
  lhs = lhs + rhs
}

func *=(inout lhs: Int!, rhs: Int)
{
  lhs = lhs * rhs
}

func /=(inout lhs: Int!, rhs: Int)
{
  lhs = lhs / rhs
}

func -=(inout lhs: Int, rhs: Int!)
{
  lhs = lhs - rhs
}

func +=(inout lhs: Int, rhs: Int!)
{
  lhs = lhs + rhs
}

func *=(inout lhs: Int, rhs: Int!)
{
  lhs = lhs * rhs
}

func /=(inout lhs: Int, rhs: Int!)
{
  lhs = lhs / rhs
}



//MARK: Modulus Operations
infix operator %= { associativity left precedence 150 }

func %=(inout lhs: Int, rhs: Int)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Int!, rhs: Int)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Int, rhs: Int!)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Float, rhs: Float)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Float!, rhs: Float)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Float, rhs: Float!)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Double, rhs: Double)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Double!, rhs: Double)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Double, rhs: Double!)
{
  lhs = lhs % rhs
}

func %=(inout lhs: Float, rhs: Int)
{
  lhs = lhs % Float(rhs)
}

func %=(inout lhs: Float!, rhs: Int)
{
  lhs = lhs % Float(rhs)
}

func %=(inout lhs: Float, rhs: Int!)
{
  lhs = lhs % Float(rhs)
}

func %=(inout lhs: Float!, rhs: Int!)
{
  lhs = lhs % Float(rhs)
}

func %=(inout lhs: Double, rhs: Int)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double!, rhs: Int)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double, rhs: Int!)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double!, rhs: Int!)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double, rhs: Float)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double!, rhs: Float)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double, rhs: Float!)
{
  lhs = lhs % Double(rhs)
}

func %=(inout lhs: Double!, rhs: Float!)
{
  lhs = lhs % Double(rhs)
}



//MARK: CGFloat Operations
func -=(inout lhs: CGFloat?, rhs: CGFloat)
{
  if (lhs == nil)
  {
    lhs = -rhs
  }
  else
  {
    lhs = lhs! - rhs
  }
}

func +=(inout lhs: CGFloat?, rhs: CGFloat)
{
  if (lhs == nil)
  {
    lhs = rhs
  }
  else
  {
    lhs = lhs! + rhs
  }
}

func *=(inout lhs: CGFloat?, rhs: CGFloat)
{
  lhs = lhs! * rhs
}

func /=(inout lhs: CGFloat?, rhs: CGFloat)
{
  lhs = lhs! / rhs
}

func -=(inout lhs: CGFloat, rhs: Int)
{
  lhs = lhs - rhs
}

func +=(inout lhs: CGFloat, rhs: Int)
{
  lhs = lhs + rhs
}

func *=(inout lhs: CGFloat, rhs: Int)
{
  lhs = lhs * rhs
}

func /=(inout lhs: CGFloat, rhs: Int)
{
  lhs = lhs / rhs
}

func =-(inout lhs: CGFloat, rhs: Int)
{
  lhs = rhs - lhs
}

func =/(inout lhs: CGFloat, rhs: Int)
{
  lhs = rhs / lhs
}

func =-(inout lhs: CGFloat, rhs: Float)
{
  lhs = rhs - lhs
}

func =/(inout lhs: CGFloat, rhs: Float)
{
  lhs = rhs / lhs
}

func +(lhs: CGFloat, rhs: Int) -> (CGFloat)
{
  return lhs + CGFloat(rhs)
}

func +(lhs: Int, rhs: CGFloat) -> (CGFloat)
{
  return CGFloat(lhs) + rhs
}

func -(lhs: CGFloat, rhs: Int) -> (CGFloat)
{
  return lhs - CGFloat(rhs)
}

func -(lhs: Int, rhs: CGFloat) -> (CGFloat)
{
  return CGFloat(lhs) - rhs
}

func -(lhs: Float, rhs: CGFloat) -> (CGFloat)
{
  return lhs - rhs
}

func *(lhs: CGFloat, rhs: Int) -> (CGFloat)
{
  return lhs * CGFloat(rhs)
}

func *(lhs: Int, rhs: CGFloat) -> (CGFloat)
{
  return CGFloat(lhs) * rhs
}

func /(lhs: CGFloat, rhs: Int) -> (CGFloat)
{
  return lhs / CGFloat(rhs)
}

func /(lhs: Int, rhs: CGFloat) -> (CGFloat)
{
  return CGFloat(lhs) / rhs
}

func /(lhs: Float, rhs: CGFloat) -> (CGFloat)
{
  return lhs / rhs
}



//MARK CGPoint Operations
func +(lhs: CGPoint, rhs: CGPoint) -> (CGPoint)
{
  let x = lhs.x + rhs.x
  let y = lhs.y + rhs.y
  
  return CGPointMake(x, y)
}

func -(lhs: CGPoint, rhs: CGPoint) -> (CGPoint)
{
  let x = lhs.x - rhs.x
  let y = lhs.y - rhs.y
  
  return CGPointMake(x, y)
}

func +=(inout lhs: CGPoint, rhs: CGPoint)
{
  let x = lhs.x + rhs.x
  let y = lhs.y + rhs.y
  
  lhs = CGPointMake(x, y)
}

func -=(inout lhs: CGPoint, rhs: CGPoint)
{
  let x = lhs.x - rhs.x
  let y = lhs.y - rhs.y
  
  lhs = CGPointMake(x, y)
}

func =-(inout lhs: CGPoint, rhs: CGPoint)
{
  let x = rhs.x - lhs.x
  let y = rhs.y - lhs.y
  
  lhs = CGPointMake(x, y)
}



//MARK: String Operators
infix operator =+ { associativity right precedence 90 }

func =+(inout lhs: String, rhs: String)
{
  lhs = rhs + lhs
}


func +(lhs: String, rhs: Int) -> (String)
{
  return lhs + String(rhs)
}

func +(lhs: Int, rhs: String) -> (String)
{
  return String(lhs) + rhs
}

func +(lhs: String, rhs: Float) -> (String)
{
  return lhs + String(rhs)
}

func +(lhs: Float, rhs: String) -> (String)
{
  return String(lhs) + rhs
}

func +(lhs: String, rhs: Double) -> (String)
{
  return lhs + String(rhs)
}

func +(lhs: Double, rhs: String) -> (String)
{
  return String(lhs) + rhs
}



//MARK: Logic Operators
infix operator =| { associativity none precedence 130 }

func =|<Value: Equatable>(lhs: Value, rhs: [Value]) -> (Bool)
{
  for value in rhs
  {
    if (lhs == value)
    {
      return true
    }
  }
  
  return false
}

infix operator !=| { associativity none precedence 130 }

func !=|<Value: Equatable>(lhs: Value, rhs: [Value]) -> (Bool)
{
  for value in rhs
  {
    if (lhs == value)
    {
      return false
    }
  }
  
  return true
}

//infix operator =& { associativity none precedence 130 }
//
//func =&<Value: Equatable>(lhs: Value, rhs: [Value]) -> (Bool)
//{
//  for value in rhs
//  {
//    if (lhs != value)
//    {
//      return false
//    }
//  }
//
//  return true
//}
//
//infix operator !=& { associativity none precedence 130 }
//
//func !=&<Value: Equatable>(lhs: Value, rhs: [Value]) -> (Bool)
//{
//  for value in rhs
//  {
//    if (lhs != value)
//    {
//      return true
//    }
//  }
//
//  return false
//}





//MARK: Other Operators
postfix operator =! {}

postfix func =!(inout bool: Bool) -> (Bool)
{
  let oldValue = bool
  bool = !oldValue
  return oldValue
}





//MARK: - Math Functions
func round(value value: Double, decimals: Int) -> (Double)
{
  var value = value
  value *= 10 ^* decimals
  value = round(value)
  value /= 10 ^* decimals
  return value
}

func round(value value: Float, decimals: Int) -> (Double)
{
  var result = Double(value) * (10 ^* decimals)
  result = round(result)
  result /= 10 ^* decimals
  return result
}

func roundf(value value: Double, decimals: Int) -> (Float)
{
  var value = value
  value *= 10 ^* decimals
  value = round(value)
  value /= 10 ^* decimals
  return Float(value)
}

func roundf( value value: Float, decimals: Int) -> (Float)
{
  var result = Double(value) * (10 ^* decimals)
  result = round(result)
  result /= 10 ^* decimals
  return Float(result)
}

func floor(value value: Double, decimals: Int) -> (Double)
{
  var value = value
  value *= 10 ^* decimals
  value = floor(value)
  value /= 10 ^* decimals
  return value
}

func floor(value value: Float, decimals: Int) -> (Double)
{
  var result = Double(value) * (10 ^* decimals)
  result = floor(result)
  result /= 10 ^* decimals
  return result
}

func floorf(value value: Double, decimals: Int) -> (Float)
{
  var value = value
  value *= 10 ^* decimals
  value = floor(value)
  value /= 10 ^* decimals
  return Float(value)
}

func floorf( value value: Float, decimals: Int) -> (Float)
{
  var result = Double(value) * (10 ^* decimals)
  result = floor(result)
  result /= 10 ^* decimals
  return Float(result)
}

func ceil(value value: Double, decimals: Int) -> (Double)
{
  var value = value
  value *= 10 ^* decimals
  value = ceil(value)
  value /= 10 ^* decimals
  return value
}

func ceil(value value: Float, decimals: Int) -> (Double)
{
  var result = Double(value) * (10 ^* decimals)
  result = ceil(result)
  result /= 10 ^* decimals
  return result
}

func ceilf(value value: Double, decimals: Int) -> (Float)
{
  var value = value
  value *= 10 ^* decimals
  value = ceil(value)
  value /= 10 ^* decimals
  return Float(value)
}

func ceilf(value value: Float, decimals: Int) -> (Float)
{
  var result = Double(value) * (10 ^* decimals)
  result = ceil(result)
  result /= 10 ^* decimals
  return Float(result)
}





//MARK: - Other Functions
func numberSuffix(digit: String) -> (String)
{
  let number = digit.integerValue
  return numberSuffix(number)
}

func numberSuffix(digit: Int) -> (String)
{
  var digit = digit
  
  if (digit > -10 && digit < 0)
  {
    digit *= -1
  }
  else if (digit < 0 || digit > 9)
  {
    let stringFormat = String(digit)
    let lastCharater = stringFormat.lastCharacter
    digit = String(lastCharater).integerValue
  }
  
  switch digit
  {
    case 1:
      return "st"
    case 2:
      return "nd"
    case 3:
      return "rd"
    default:
      return "th"
  }
}

func invertBool(inout inDictionary dictionary: [String: Bool], withKey key: String)
{
  var value = dictionary.removeValueForKey(key)!
  dictionary[key]! = (value=!)
}

func invertBool(inout inDictionary dictionary: [String: AnyObject], withKey key: String)
{
  var value = dictionary.removeValueForKey(key) as! Bool
  dictionary.updateValue(value=!, forKey: key)
}

func invertBool(inout inDictionary dictionary: [String: Any], withKey key: String)
{
  var value = dictionary.removeValueForKey(key) as! Bool
  dictionary.updateValue(value=!, forKey: key)
}




//MARK: - Constants
let iPhone4sWidth: CGFloat = 320
let iPhone5Width: CGFloat = 320
let iPhone5sWidth: CGFloat = iPhone5Width
let iPhone6Width: CGFloat = 375
let iPhone6PlusWidth: CGFloat = 414

let iPhone4sHeight: CGFloat = 480
let iPhone5Height: CGFloat = 568
let iPhone5sHeight: CGFloat = iPhone5Width
let iPhone6Height: CGFloat = 667
let iPhone6PlusHeight: CGFloat = 736





//MARK: - Sortable Dictionary
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
  private var dictionary: [Key: Value]
  private var sortedKeys: [Key] = []
  private var sortedValues: [Value] = []
  private var valueSort: ((Value, Value) -> Bool)?
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
  var currentValueSort: (((Value, Value) -> Bool)?)
  {
    return valueSort
  }
  var currentKeySort: (((Key, Key) -> Bool)?)
  {
    return keySort
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
  
  init(dictionary: [Key: Value] = [:])
  {
    self = SortableDictionary(dictionary: dictionary, sortType: SortType.Manual, valueSort: nil, keySort: nil)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType = SortType.Value, valueSort: (Value, Value) -> Bool)
  {
    if (sortType == SortType.Key)
    {
      fatalError("Cannot set sort type to Key without specifying a key sort.")
    }
    
    self = SortableDictionary(dictionary: dictionary, sortType: sortType, valueSort: valueSort, keySort: nil)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType = SortType.Key, keySort: (Key, Key) -> Bool)
  {
    if (sortType == SortType.Value)
    {
      fatalError("Cannot set sort type to Value without specifying a value sort.")
    }
    
    self = SortableDictionary(dictionary: dictionary, sortType: SortType.Key, valueSort: nil, keySort: keySort)
  }
  
  init(dictionary: [Key: Value] = [:], sortType: SortType, valueSort: (Value, Value) -> Bool, keySort: (Key, Key) -> Bool)
  {
    self = SortableDictionary(dictionary: dictionary, sortType: sortType, valueSort: valueSort, keySort: keySort)
  }
  
  init(sortedDictionary: SortableDictionary, includeDictionary: Bool = true)
  {
    if (includeDictionary)
    {
      self = SortableDictionary(dictionary: sortedDictionary.dictionary, sortType: sortedDictionary.sortType, valueSort: sortedDictionary.valueSort, keySort: sortedDictionary.keySort)
    }
    else
    {
      self = SortableDictionary(dictionary: [:], sortType: sortedDictionary.sortType, valueSort: sortedDictionary.valueSort, keySort: sortedDictionary.keySort)
    }
  }
  
  private init(dictionary: [Key: Value], sortType: SortType, valueSort: ((Value, Value) -> Bool)?, keySort: ((Key, Key) -> Bool)?)
  {
    self.dictionary = dictionary
    self.valueSort = valueSort
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
  
  mutating func newSort(sortType: SortType? = nil, valueSort: ((Value, Value) -> Bool)? = nil, keySort: ((Key, Key) -> Bool)? = nil)
    -> (oldValueSort: ((Value, Value) -> Bool)?, oldKeySort: ((Key, Key) -> Bool)?)
  {
    let oldValueSort = self.valueSort
    self.valueSort = valueSort
    
    let oldKeySort = self.keySort
    self.keySort = keySort

    if (sortType != nil)
    {
      sortingType = sortType!
    }
    
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
    
    return (oldValueSort, oldKeySort)
  }
  
  mutating func newDictionary(dictionary: [Key: Value] = [:]) -> ([Key: Value])
  {
    let oldDictionary = self.dictionary
    self.dictionary = dictionary
    sortedKeys = []
    sortedValues = []
    
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
  
  private mutating func addNewValueArraysOnly(key key: Key, value: Value)
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
  
  private mutating func addNewValue(key key: Key, value: Value)
  {
    addNewValueArraysOnly(key: key, value: value)
    dictionary[key] = value
  }
  
  private func findInsertionIndex(upperBound upperBound: Int, lowerBound: Int, value: Value, key: Key) -> (Int)
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
  
  mutating func insert(newKey key: Key, andNewValue value: Value)
  {
    if (hasKey(key))
    {
      fatalError("Key: \(key) already exsists in this sorted dictionary.")
    }
    
    addNewValue(key: key, value: value)
    dictionary[key] = value
  }
  
  mutating func insert(newElement element: (key: Key, value: Value))
  {
    insert(newKey: element.key,andNewValue: element.value)
  }
  
  mutating func insert(newKeys keys: [Key], andNewValues values: [Value])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    for i in 0..<count
    {
      insert(newKey: keys[i], andNewValue: values[i])
    }
  }
  
  mutating func insert(newElements elements: [(key: Key, value: Value)])
  {
    for element in elements
    {
      insert(newElement: element)
    }
  }
  
  mutating func insert(elementsFromDictionary dictionary: [Key: Value])
  {
    for (key, value) in dictionary
    {
      insert(newKey: key, andNewValue: value)
    }
  }
  
  mutating func insert(atIndex index: Int, newKey key: Key, andNewValue value: Value)
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
  
  mutating func insert(atIndex index: Int, newElement element: (key: Key, value: Value))
  {
    insert(atIndex: index, newKey: element.key, andNewValue: element.value)
  }
  
  mutating func insert(atIndex index: Int, newKeys keys: [Key], andNewValues values: [Value])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    for i in 0..<count
    {
      insert(atIndex: i + index, newKey: keys[i], andNewValue: values[i])
    }
  }
  
  mutating func insert(insertAtIndex index: Int, newElements elements: [(key: Key, value: Value)])
  {
    var index = index
    
    for element in elements
    {
      insert(atIndex: index, newElement: element)
      index += 1
    }
  }
  
  mutating func insert(atIndex index: Int, dictionary: [Key: Value])
  {
    for (key, value) in dictionary
    {
      insert(atIndex: index, newKey: key, andNewValue: value)
    }
  }
  
  mutating func update(valueAtIndex index: Int, withNewValue value: Value) -> (Value)
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
      insert(newKey: key, andNewValue: value)
    }
    else
    {
      sortedValues[index] = value
    }
    
    return oldValue
  }
  
  mutating func update(valueForKey key: Key, withNewValue value: Value) -> (Value?)
  {
    let index = getIndex(forKey: key)
    
    if (index == nil)
    {
      return nil
    }
    else
    {
      let oldValue = update(valueAtIndex: index!, withNewValue: value)
      return oldValue
    }
  }
  
  mutating func update(usingElement element: (key: Key, value: Value)) -> (Value?)
  {
    return update(valueForKey: element.key, withNewValue: element.value)
  }
  
  mutating func update(moveKey key: Key, toIndex index: Int) -> (Value)
  {
    if (!hasKey(key))
    {
      fatalError("Key: \(key) does not already exsist at another index.")
    }
    else if (getIndex(forKey: key) == index)
    {
      fatalError("Key: \(key) already exsist at index: \(index).")
    }
    
    let value = self[key]!
    remove(key: key)
    insert(atIndex: index, newKey: key, andNewValue: value)
    
    return value
  }
  
  mutating func update(moveKey shiftKey: Key, toBeforeKey key: Key) -> (Value)
  {
    if (!hasKey(key))
    {
      fatalError("Key: \(key) does not already exsist.")
    }
    
    let index = getIndex(forKey: key)!
    let oldValue = update(moveKey: shiftKey, toIndex: index)
    
    return oldValue
  }
  
  mutating func update(keyAndValueAtIndex index: Int, withNewKey key: Key, andNewValue value: Value) -> (key: Key, value: Value)
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
    insert(atIndex: index, newKey: key, andNewValue: value)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(elementAtIndex index: Int, withNewElement element: (key: Key, value: Value)) -> (key: Key, value: Value)
  {
    return update(keyAndValueAtIndex: index, withNewKey: element.key, andNewValue: element.value)
  }
  
  mutating func update(replaceKey oldKey: Key, withExistingKey key: Key) -> (Value)
  {
    if (!hasKey(oldKey))
    {
      fatalError("Replaceing Key: \(oldKey) does not already exsist.")
    }
    else if (!hasKey(key))
    {
      fatalError("Replacement Key: \(key) does not already exsist.")
    }
    
    let oldValue = remove(key: oldKey)!
    update(valueForKey: key, withNewValue: oldValue)
    
    return oldValue
  }
  
  mutating func update(keyAtIndex index: Int, withExistingKey key: Key) -> (key: Key, value: Value)
  {
    if (sortingType != SortType.Manual)
    {
      fatalError("Indexs can only be updated while in Manual sort.")
    }
    else if (index >= count || index < 0)
    {
      fatalError("Index out of bounds!")
    }
    else if (key == sortedKeys[index])
    {
      fatalError("Key: \(key) already located at index: \(index).")
    }
    
    let oldKey = sortedKeys[index]
    let oldValue = update(replaceKey: oldKey, withExistingKey: key)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(replaceKey oldKey: Key, withNewKey key: Key) -> (Value)
  {
    if (!hasKey(oldKey))
    {
      fatalError("Replaceing Key: \(oldKey) does not already exsist.")
    }
    else if (!hasKey(key))
    {
      fatalError("Replacement Key: \(key) does not already exsist.")
    }
    
    let oldValue = remove(key: oldKey)!
    insert(newKey: key, andNewValue: oldValue)
    
    return oldValue
  }
  
  mutating func update(keyAtIndex index: Int, withNewKey key: Key) -> (key: Key, value: Value)
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
    
    let oldKey = sortedKeys[index]
    let oldValue = update(replaceKey: oldKey, withNewKey: key)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(swapFirstIndex index1: Int, withSecondIndex index2: Int)
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
      insert(atIndex: index1, newElement: element2)
      insert(atIndex: index2, newElement: element1)
    }
    else
    {
      insert(atIndex: index2, newElement: element1)
      insert(atIndex: index1, newElement: element2)
    }
  }
  
  mutating func update(swapFirstKey key1: Key, withSecondKey key2: Key)
  {
    if (!hasKey(key1))
    {
      fatalError("Cannot swap, Key: \(key1) missing")
    }
    else if (!hasKey(key2))
    {
      fatalError("Cannot swap, Key: \(key2) missing")
    }
    
    let firstIndex = getIndex(forKey: key1)!
    let secondIndex = getIndex(forKey: key2)!
    return update(swapFirstIndex: firstIndex, withSecondIndex: secondIndex)
  }
  
  mutating func update(swapKeyAtIndex index: Int, withKey key: Key)
  {
    if (!hasKey(key))
    {
      fatalError("Cannot swap, Key: \(key) missing")
    }
    
    let secondIndex = getIndex(forKey: key)!
    update(swapFirstIndex: index, withSecondIndex: secondIndex)
  }
  
  mutating func update(elementAtIndex index: Int, withNewKey key: Key, andNewValue value: Value) -> (key: Key, value: Value)
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
    insert(atIndex: index, newKey: key, andNewValue: value)
    
    return (key: oldKey, value: oldValue)
  }
  
  mutating func update(valuesForKeys keys: [Key], withNewValues values: [Value]) -> ([Value?])
  {
    let count = keys.count
    
    if (count != values.count)
    {
      fatalError("[Key] and [Value] must be of the same length")
    }
    
    var oldValues: [Value?] = []
    
    for i in 0..<count
    {
      let oldValue = update(valueForKey: keys[i], withNewValue: values[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(usingElements elements: [(key: Key, value: Value)]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for i in 0..<elements.count
    {
      let oldValue = update(usingElement: elements[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(usingDictionary dictionary: [Key: Value]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for element in dictionary
    {
      let oldValue = update(usingElement: element)
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(keysStartingAtIndex index: Int, withExistingKeys keys: [Key]) -> ([(key: Key, value: Value)])
  {
    var oldValues: [(key: Key, value: Value)] = []
    
    for i in 0..<keys.count
    {
      let oldValue = update(keyAtIndex: i + index, withExistingKey: keys[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(elementsStartingAtIndex index: Int, withNewElements elements: [(key: Key, value: Value)]) -> ([(key: Key, value: Value)])
  {
    var oldValues: [(key: Key, value: Value)] = []
    
    for i in 0..<elements.count
    {
      let oldValue = update(elementAtIndex: index + i, withNewElement: elements[i])
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func update(elementsStartingAtIndex index: Int, withNewDictionary dictionary: [Key: Value]) -> ([(key: Key, value: Value)])
  {
    var index = index
    var oldValues: [(key: Key, value: Value)] = []
    
    for element: (Key, Value) in dictionary
    {
      let oldValue = update(elementAtIndex: index, withNewElement: element)
      oldValues.append(oldValue)
      index += 1
    }
    
    return oldValues
  }
  
  mutating func remove(key key: Key) -> (Value?)
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
  
  mutating func remove(index index: Int) -> (key: Key, value: Value)
  {
    let value = sortedValues.removeAtIndex(index)
    let key = sortedKeys.removeAtIndex(index)
    dictionary.removeValueForKey(key)
    return (key: key, value: value)
  }
  
  mutating func remove(rangeOfIndices range: Range<Int>) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for i in range
    {
      let oldElement = remove(index: i)
      let oldValue = oldElement.value
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  mutating func remove(keys keys: [Key]) -> ([Value?])
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
      update(valueForKey: key, withNewValue: value!)
    }
    
    return oldValue
  }
  
  mutating func edit(index index: Int, key: Key?, value: Value?) -> (key: Key?, value: Value?)
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
            let tuple = update(keyAtIndex: index, withExistingKey: key!)
            
            let key: Key? = tuple.key
            let value: Value? = tuple.value
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
          insert(atIndex: index, newKey: key!, andNewValue: value!)
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
  
  mutating func edit(element element: (key: Key, value: Value)) -> (Value?)
  {
    return edit(addUpdateOrRemoveKey: element.key, withNewOrNilValue: element.value)
  }
  
  mutating func edit(dictionary dictionary: [Key: Value]) -> ([Value?])
  {
    var oldValues: [Value?] = []
    
    for (key, value) in dictionary
    {
      let oldValue = edit(addUpdateOrRemoveKey: key, withNewOrNilValue: value)
      oldValues.append(oldValue)
    }
    
    return oldValues
  }
  
  func getIndex(forKey forKey: Key) -> (Int?)
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
  
  func sorted(sortType: SortType? = nil, valueSort: ((Value, Value) -> Bool
    )? = nil, keySort: ((Key, Key) -> Bool)? = nil) -> (SortableDictionary)
  {
    var sortType = sortType
    
    if (sortType == nil)
    {
      sortType = sortingType
    }
    
    return SortableDictionary(dictionary: dictionary, sortType: sortType!, valueSort: valueSort, keySort: keySort)
  }
  
  func filter(includeElement: (Value) -> Bool) -> (SortableDictionary)
  {
    let newDictionary = filterDictionaryOnly(includeElement)
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSort: valueSort, keySort: keySort)
  }
  
  func filter(includeElement: (Key) -> Bool) -> (SortableDictionary)
  {
    let newDictionary = filterDictionaryOnly(includeElement)
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSort: valueSort, keySort: keySort)
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
    return SortableDictionary(dictionary: newDictionary, sortType: sortType, valueSort: valueSort, keySort: keySort)
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
  
//  func reduce<U>(initial: U, combine: (U, Value) -> U) -> U
//  {
//    
//  }
  
  func combine(otherSortableDictionary: SortableDictionary, overwriteOther: Bool = true) -> (SortableDictionary)
  {
    if (overwriteOther)
    {
      var newSortedDictionary = SortableDictionary(sortedDictionary: self)
      newSortedDictionary.insert(elementsFromDictionary: otherSortableDictionary.dictionary)
      return newSortedDictionary
    }
    else
    {
      var newSortedDictionary = SortableDictionary(sortedDictionary: otherSortableDictionary)
      newSortedDictionary.insert(elementsFromDictionary: self.dictionary)
      return newSortedDictionary
    }
  }
  
  func combineDictionaryOnly(otherSortableDictionary: SortableDictionary, overwriteOther: Bool = true) -> ([Key: Value])
  {
    return combine(otherSortableDictionary, overwriteOther: overwriteOther).dictionary
  }
  
//  func print() -> String
//  {
//    let printString = "["
//    
//    for i in 0..<count
//    {
//      printString += "\(sortedKeys[i]) "
//    }
//  }
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
  newSortedDictionary.insert(elementsFromDictionary: rhs.dictionary)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>)
{
  lhs = lhs + rhs
}

func -<Key, Value>(lhs: SortableDictionary<Key, Value>, rhs: SortableDictionary<Key, Value>) -> (SortableDictionary<Key, Value>)
{
  let newSortedDictionary = lhs
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
  newSortedDictionary.insert(newElement: rhs)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: (key: Key, value: Value))
{
  lhs.insert(newElement: rhs)
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
  newSortedDictionary.insert(elementsFromDictionary: rhs)
  return newSortedDictionary
}

func +=<Key, Value>(inout lhs: SortableDictionary<Key, Value>, rhs: [Key: Value])
{
  lhs = lhs + rhs
}