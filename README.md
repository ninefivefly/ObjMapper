# ObjMapper

[![Version](https://img.shields.io/cocoapods/v/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![License](https://img.shields.io/cocoapods/l/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![Platform](https://img.shields.io/cocoapods/p/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)

ObjtMapper is an extended framework based on Swift's Codable protocol, which allows you to easily convert model objects (classes and structures) to and from JSON without side effects.

Language: English|[中文简体](https://github.com/ninefivefly/ObjMapper/edit/main/README_zh.md)

## Features
- [x] Codable-based extensions
- [x] JSON mapping to object
- [x] object is mapped to JSON
- [x] Nested objects
- [x] supports nil objects
- [x] supports default values
- [x] supports array defaults
- [x] Support conversion between String and integer, floating point number, Bool

## Install

#### CocoaPods
```ruby
pod 'ObjMapper'
```

#### Swift Package Manager
```ruby
dependencies: [
    .package(url: "https://github.com/ninefivefly/ObjMapper.git", '3.0.0')
]
```

## Preface
### Why do we have this library?

In Swift development, JSON data serialization is an unavoidable task. Due to the type safety feature of Swift, it has always been a headache to process weakly typed data like JSON. Among the new features brought by Swift 4 , the Codable protocol makes people shine. However, Codable cannot fully meet our requirements, such as not supporting automatic conversion of types, and not being friendly to default value support.
So, if we solve these problems, will it be perfect?
[How to use the Codable protocol gracefully](https://juejin.cn/post/7252499099328086074)

## Tutorial
### 1. Convert between Model and JSON
```objc
// JSON:
{
     "uid":888888,
     "name": "Tom",
     "age": 10
}

// Model:
struct Dog: Codable{
     //If the field is not an optional type, use Default and provide a default value, like the following
     @Default<Int. Zero> var uid: Int
     //If it is an optional type, use Backed
     @Backed var name: String?
     @Backed var age: Int?
}

//JSON to model
let dog = Dog. decodeJSON(from: json)

//model to json
let json = dog.jsonString
```

When the object type in JSON/Dictionary is inconsistent with the Model property, ObjMapper will automatically convert as follows. Values not supported by automatic conversion will be set to nil or the default value.
<table>
   <thead>
     <tr>
       <th>JSON/Dictionary</th>
       <th>Model</th>
     </tr>
   </thead>
   <tbody>
     <tr>
       <td>String</td>
       <td>String, Number type (including integer, floating point number), Bool</td>
     </tr>
     <tr>
       <td>Number type (including integer, floating point number)</td>
       <td>Number type, String, Bool</td>
     </tr>
     <tr>
       <td>Bool</td>
       <td>Bool, String, Number types (including integers, floating point numbers)</td>
     </tr>
     <tr>
       <td>nil</td>
       <td>nil,0</td>
     </tr>
   </tbody>
</table>

### 2. Model nesting
```objc
let raw_json = """
{
     "author": {
         "id": 888888,
         "name": "Alex",
         "age": "10"
     },
     "title": "model and json conversion",
     "subTitle":"How to convert gracefully"
}
"""

// Model:
struct Author: Codable{
     @Default<Int.Zero> var id: Int
     @Default<String.Empty> var name: String
     // After using Backed, if the type does not match, the type will be automatically converted
     //For example, in the above json, age is a string, and the model we defined is Int,
     //Then after declaring @Backed, it will be automatically converted to Int type
     @Backed var age: Int?
}

struct Article: Codable {
     //If the title in json is nil or does not exist, a default value will be assigned to the title
     @Default<String.Empty> var title: String
     var subTitle: String?
     var author: Author
}

//JSON to model
let article = Article.decodeJSON(from: raw_json)

//model to json
let json = article.jsonString
print(article?.jsonString ?? "")
```

### 3. Optional values of custom types
Without further ado, let's go to the code
```objc
struct Activity: Codable {
     enum Status: Int {
         case start = 1//Activity starts
         case processing = 2//Activity in progress
         case end = 3//end of event
     }
    
     @Default<String.Empty> var name: String
     var status: Status//active status
}
```
Here's an activity that currently has three states, so far so good. One day, I suddenly said that I need to add a delisted status to the event, what?
```
//JSON
{
     "name": "New Year's Day Welcome Event",
     "status": 4
}
```
Using Activity to parse the above JSON will report an error, how can we avoid it, like the following
```
var status: Status?
```
The answer is no, no, no, because the decoding of the optional value expresses "if it does not exist, set it to nil" instead of "if the decoding fails, set it to nil", then use our Default, Please see the code below:
```
struct Activity: Codable {
     ///Step 1: Let Status follow the DefaultValue protocol
     enum Status: Int, Codable, DefaultValue {
         case start = 1//Activity starts
         case processing = 2//Activity in progress
         case end = 3//end of event
         case unknown = 0//default value, meaningless
        
         ///Step 2: Implement the DefaultValue protocol and specify a default value
         static func defaultValue() -> Status {
             return Status.unknown
         }
     }
    
     @Default<String.Empty> var name: String
     ///Step 3: Use Default
     @Default<Status> var status: Status//active status
}

//{"name": "New Year's Day Welcome Event", "status": 4 }
//Activity will parse the status into unknown
```

### 4. Set different default values for common types
This library has built-in many default values, such as Int.Zero, Bool.True, String.Empty..., if we want to set a different default value for the field, see the following code:

```
public extension Int {
     enum One: DefaultValue {
         static func defaultValue() -> Int {
             return 1
         }
     }
}

struct Dog: Codable{
     @Backed var name: String?
     @Default<Int.Zero> var uid: Int
     //If there is no age field in json or the parsing fails, the age of the model is set to the default value 1
     @Default<Int.One> var age: Int
}
```

### 5. Array support
For arrays, @Backed, @Default can be used to resolve
```objc
// JSON:
let raw_json = """
{
     "code": 0,
     "message": "success",
     "data": [{
         "name": "New Year's Day Welcome Event",
         "status": 4
     }]
}
"""

struct Activaty: Codable{
     @Default<String.Empty> var name: String
     @Default<Int.Zero> var status: Int
}

// If the array is an optional type, you can use @Backed
struct Response1: Codable {
     @Default<Int.Zero> var code: Int
     @Default<String. Empty> var message: String
     @Backed var data: [Activaty]?
}

// For the array, set the default value, if the array does not exist or the parsing error, use the default value
struct Response2: Codable {
     @Default<Int.Zero> var code: Int
     @Default<String.Empty> var message: String
     @Default<Array.Empty> var data: [Activaty]
}
//JSON to model
let rsp1 = Response1.decodeJSON(from: raw_json)
let rsp2 = Response2.decodeJSON(from: raw_json)

//model to json
let json1 = rsp1.jsonString
let json2 = rsp2.jsonString
// print(rsp1?.jsonString ?? "")
// print(rsp2?.jsonString ?? "")
```


### 6. Set the general type
During the development process, the first JSON we encounter may look like this:
```objc
// JSON:
{
     "code": 0,
     "message": "success",
     "data":[]//This data can be of any type
}
```
Since the type of the data field is not fixed, sometimes for unified processing, we define the model as follows, represented by the enumeration type JsonValue.
```
struct Response: Codable {
     var code: Int
     var message: String
     var data: JsonValue?
}
```
If you want to get the value of the data field, we can use data?.intValue or data?.arrayValue, etc., see the source code for specific usage.

Note: This is a simple model for data (such as an integer, string, etc.), which can achieve twice the result with half the effort; if the data is a large model, it is recommended to specify the data as a specific type.


### 7. If you are upgrading from 1.0.x to 2.0, the DefaultValue protocol has been modified. If the DefaultValue protocol is used in the previous code, an error will be reported, and the modification is as follows:

```
Originally:
///Step 1: Let Status follow the DefaultValue protocol
enum Status: Int, Codable, DefaultValue {
     case start = 1//Activity starts
    
     ///Step 2: Implement the DefaultValue protocol and specify a default value
     static let defaultValue = Status.unknown
}

changed to:
///Step 1: Let Status follow the DefaultValue protocol
enum Status: Int, Codable, DefaultValue {
     case start = 1//Activity starts
    
     ///Step 2: Implement the DefaultValue protocol and return a default value
     static func defaultValue() -> Status {
         return Status.unknown
     }
}

```


ps: Don’t spray if you don’t like it, please leave a message if you have any questions 😁😁😁, welcome ✨✨✨star✨✨✨ and PR

## Author

JIANG PENG CHENG, ninefivefly@foxmail.com

## License

ObjMapper is available under the MIT license. See the LICENSE file for more info.

