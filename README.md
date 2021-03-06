# ObjMapper

[![Version](https://img.shields.io/cocoapods/v/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![License](https://img.shields.io/cocoapods/l/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)
[![Platform](https://img.shields.io/cocoapods/p/ObjMapper.svg?style=flat)](https://cocoapods.org/pods/ObjMapper)

## 特性
- [x] 基于Codable的扩展
- [x] JSON映射为object
- [x] object映射为JSON
- [x] 嵌套对象
- [x] 支持nil对象
- [x] 支持默认值
- [x] 支持String和整数、浮点数、Bool之间的转换

## 安装

```ruby
pod 'ObjMapper'
```

## 前言
### 为什么要有这个库？

在Swift开发中，JSON数据序列化是一个避不开的工作，Swift由于类型安全的特性，对于像JSON这类弱类型的数据处理一直是一个比较头疼的问题，Swift 4 带来的新特性中， Codable 协议让人眼前一亮。但是, Codable也不能完全满足我们的要求，比如不支持类型的自动转换、对默认值支持不友好。
so，我们如果把这些问题解决了，是不是就完美啦
[如何优雅的使用Codable协议](https://juejin.cn/post/6910094553684901895/)

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
{
    "author":{
        "id": 888888
        "name":"Alex",
        "age":"10"
    },
    "title":"model与json互转",
    "subTitle":"如何优雅的转换"
}

// Model:
struct Author: Codable{
    @Default<Int.Zero> var uid: Int
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

struct Activity: Codable {
    ///Step 1：让Status遵循DefaultValue协议
    enum Status: Int, Codable, DefaultValue {
        case start = 1//活动开始
        case processing = 2//活动进行中
        case end = 3//活动结束
        case unknown = 0//默认值，无意义
        
        ///Step 2：实现DefaultValue协议，指定一个默认
        static let defaultValue = Status.unknown
    }
    
    @Default<String.Empty> var name: String
    ///Step 3：使用Default
    @Default<Status> var status: Status//活动状态
}

///对可选类型值的支持
let json = """
{
    "name": "元旦迎新活动",
    "status": 4
}
"""
///可选类型自动转换
let activity = Activity.decodeJSON(from: json)!
///activity的status，转换为unknown
print("activity.status: \(activity.status)")
///
print("json：\(activity.jsonString ?? "")")

//JSON to model
let article = Article.decodeJSON(from: json)

//model to json
let json = article.jsonString
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
        static let defaultValue = Status.unknown
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
        public static let defaultValue = 1
    }
}

struct Dog: Codable{
    @Backed var name: String?
    @Default<Int.Zero> var uid: Int
    //如果json中没有age字段或者解析失败，则模型的age被设置成默认值1
    @Default<Int.One> var age: Int
}
```

ps: 不喜勿喷，有问题请留言😁😁😁，欢迎✨✨✨star✨✨✨和PR

## Author

JIANG PENG CHENG, ninefivefly@foxmail.com

## License

ObjMapper is available under the MIT license. See the LICENSE file for more info.
