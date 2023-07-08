# ObjMapper

[![Version](https://img.shields.io/cocoapods/v/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![License](https://img.shields.io/cocoapods/l/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![Platform](https://img.shields.io/cocoapods/p/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)

ObjtMapper是基于Swift的Codable协议进行扩展的框架，可让您轻松地将模型对象（类和结构）与JSON相互转换，无副作用的转换。
Language: 中文简体|[English](https://github.com/ninefivefly/ObjMapper/edit/main/README.md)

## 特性
- [x] 基于Codable的扩展
- [x] JSON映射为object
- [x] object映射为JSON
- [x] 嵌套对象
- [x] 支持nil对象
- [x] 支持默认值
- [x] 支持数组默认值
- [x] 支持String和整数、浮点数、Bool之间的转换

## 安装

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

## 前言
### 为什么要有这个库？

在Swift开发中，JSON数据序列化是一个避不开的工作，Swift由于类型安全的特性，对于像JSON这类弱类型的数据处理一直是一个比较头疼的问题，Swift 4 带来的新特性中， Codable 协议让人眼前一亮。但是, Codable也不能完全满足我们的要求，比如不支持类型的自动转换、对默认值支持不友好。
so，我们如果把这些问题解决了，是不是就完美啦
[如何优雅的使用Codable协议](https://juejin.cn/post/7252499099328086074)

## 使用教程
### 1、Model与JSON相互转换
```objc
// JSON:
{
    "uid":888888,
    "name":"Tom",
    "age":10
}

// Model:
struct Dog: Codable{
    //如果字段不是可选类型，则使用Default，提供一个默认值，像下面一样
    @Default<Int.Zero> var uid: Int
    //如果是可选类型，则使用Backed
    @Backed var name: String?
    @Backed var age: Int?
}

//JSON to model
let dog = Dog.decodeJSON(from: json)

//model to json
let json = dog.jsonString
```

当 JSON/Dictionary 中的对象类型与 Model 属性不一致时，ObjMapper 将会进行如下自动转换。自动转换不支持的值将会被设置为nil或者默认值。
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
      <td>String，Number类型(包含整数，浮点数)，Bool</td>
    </tr>
    <tr>
      <td>Number类型(包含整数，浮点数)</td>
      <td>Number类型，String，Bool</td>
    </tr>
    <tr>
      <td>Bool</td>
      <td>Bool，String，Number类型(包含整数，浮点数)</td>
    </tr>
    <tr>
      <td>nil</td>
      <td>nil,0</td>
    </tr>
  </tbody>
</table>

### 2、Model的嵌套
```objc
let raw_json = """
{
    "author":{
        "id": 888888,
        "name":"Alex",
        "age":"10"
    },
    "title":"model与json互转",
    "subTitle":"如何优雅的转换"
}
"""

// Model:
struct Author: Codable{
    @Default<Int.Zero> var id: Int
    @Default<String.Empty> var name: String
    //使用Backed后，如果类型不匹配，则类型会自动转换
    //比如，上面的json中，age是个字符串，我们定义的模型是Int,
    //那么声明@Backed后，会自动转换成Int类型
    @Backed var age: Int?
}

struct Article: Codable {
    //如果json中的title为nil或者不存在，则会给title赋一个默认值
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

### 3、自定义类型的可选值
话不多说，上代码
```objc
struct Activity: Codable {
    enum Status: Int {
        case start = 1//活动开始
        case processing = 2//活动进行中
        case end = 3//活动结束
    }
    
    @Default<String.Empty> var name: String
    var status: Status//活动状态
}
```
这儿有一个活动，活动现目前有三种状态，到目前为止，一切都很美好。有一天，突然说需要给活动添加已下架的状态，what？
```
//JSON
{
    "name": "元旦迎新活动",
    "status": 4
}
```
用Activity解析上面的JSON就会报错，我们如何规避呢，像下面一样
```
var status: Status?
```
答案是no、no、no，因为可选值的解码所表达的是“如果不存在，则置为 nil”，而不是“如果解码失败，则置为 nil”，那就用我们的Default吧，请看下面代码:
```
struct Activity: Codable {
    ///Step 1：让Status遵循DefaultValue协议
    enum Status: Int, Codable, DefaultValue {
        case start = 1//活动开始
        case processing = 2//活动进行中
        case end = 3//活动结束
        case unknown = 0//默认值，无意义
        
        ///Step 2：实现DefaultValue协议，指定一个默认值
        static func defaultValue() -> Status {
            return Status.unknown
        }
    }
    
    @Default<String.Empty> var name: String
    ///Step 3：使用Default
    @Default<Status> var status: Status//活动状态
}

//{"name": "元旦迎新活动", "status": 4 }
//Activity将会把status解析成unknown
```

### 4、为普通类型设置不一样的默认值
本库已经内置了很多默认值，比如Int.Zero, Bool.True, String.Empty...，如果我们想为字段设置不一样的默认值，见下面代码：

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
    //如果json中没有age字段或者解析失败，则模型的age被设置成默认值1
    @Default<Int.One> var age: Int
}
```

### 5、数组支持
对于数组，可以使用@Backed,@Default来解析
```objc
// JSON:
let raw_json = """
{
    "code":0,
    "message":"success",
    "data": [{
        "name": "元旦迎新活动",
        "status": 4
    }]
}
"""

struct Activaty: Codable{
    @Default<String.Empty> var name: String
    @Default<Int.Zero> var status: Int
}

// 如果数组是可选类型，可以使用@Backed
struct Response1: Codable {
    @Default<Int.Zero> var code: Int
    @Default<String.Empty> var message: String
    @Backed var data: [Activaty]?
}

// 为数组，设置默认值，如果数组不存在或者解析错误，则使用默认值
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



### 6、设置通用类型
我们在开发过程中，第一个遇到的json可能是这样的：
```objc
// JSON:
{
    "code":0,
    "message":"success",
    "data":[]//这个data可以是任何类型
}
```
由于data字段的类型不固定，有时候为了统一处理，我们定义模型可以像下面这样，有枚举类型JsonValue来表示。
```
struct Response: Codable { 
    var code: Int
    var message: String
    var data: JsonValue?
}
```
如果要取data字段的值，我们可以这样用data?.intValue或者data?.arrayValue等等，具体使用见源码。

注意：这种对于data是一个简单的model（比如就是一个整形、字符串等等），可以起到事半功倍的效果；如果data是一个大型model，建议还是将data指定为具体类型。


### 7、如果是从1.0.x升级到2.0版本，修改了DefaultValue协议。如果之前的代码中使用了DefaultValue协议，则会报错，修改如下：

```
原来为：
///Step 1：让Status遵循DefaultValue协议
enum Status: Int, Codable, DefaultValue {
    case start = 1//活动开始
    
    ///Step 2：实现DefaultValue协议，指定一个默认值
    static let defaultValue = Status.unknown
}

修改成：
///Step 1：让Status遵循DefaultValue协议
enum Status: Int, Codable, DefaultValue {
    case start = 1//活动开始
    
    ///Step 2：实现DefaultValue协议，返回一个默认值
    static func defaultValue() -> Status {
        return Status.unknown
    }
}

```


ps: 不喜勿喷，有问题请留言😁😁😁，欢迎✨✨✨star✨✨✨和PR

## Author

JIANG PENG CHENG, ninefivefly@foxmail.com

## License

ObjMapper is available under the MIT license. See the LICENSE file for more info.
