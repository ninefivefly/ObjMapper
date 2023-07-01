//
//  ViewController.swift
//  ObjMapper
//
//  Created by JIANG PENG CHENG on 12/17/2020.
//  Copyright (c) 2020 JIANG PENG CHENG. All rights reserved.
//

import UIKit
import ObjMapper

struct Response<T: Codable>: Codable {
    var code: Int
    var message: String
    var data: [T]
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ///类型自动转换
        self.autoConversion()
        ///自定义类型
        self.customType()
//
        self.example1()
        self.example2()
    }
    
    ///类型自动转换
    func autoConversion() {
        struct Activaty: Codable{
            @Default<String.Empty> var name: String
            @Backed var status: Int?
        }
        
        struct OptionObject: Codable {
            /*************************************/
            ///1.没有字段，默认nil
            @Backed var nilToString: String?
            ///2.整数自动转换成字符串
            @Backed var intToString: String?
            ///3.浮点数自动转换成字符串
            @Backed var doubleToString: String?
            ///4.布尔值自动转换成字符串
            @Backed var boolToString: String?
            /**************************************/
            ///1.没有字段，默认nil
            @Backed var nilToInt: Int?
            ///2.字符串自动转换成整数
            @Backed var stringToInt: Int?
            ///3.浮点数自动转换成整数
            @Backed var doubleToInt: Int?
            ///4.布尔值自动转换成整数
            @Backed var boolToInt: Int?
            ///5.Double类型支持
            @Backed var double: Double?
            ///6.Float类型支持
            @Backed var float: Float?
            ///7.数组类型支持
            @Backed var activaties: [Activaty]?
        }

        struct Object: Codable {
            /*************************************/
            ///1.没有字段，则取默认值
            @Default<String.Empty> var nilToString: String
            ///2.整数自动转换成字符串， 如果转换不成功就取默认值
            @Default<String.Empty> var intToString: String
            ///3.浮点数自动转换成字符串， 如果转换不成功就取默认值
            @Default<String.Empty> var doubleToString: String
            ///4.布尔值自动转换成字符串， 如果转换不成功就取默认值
            @Default<String.Empty> var boolToString: String
            
            /**************************************/
            ///1.没有字段，则取默认值
            @Default<Int.Zero> var nilToInt: Int
            ///2.字符串自动转换成整数， 如果转换不成功就取默认值
            @Default<Int.Zero> var stringToInt: Int
            ///3.浮点数自动转换成整数，如果转换不成功就取默认值
            @Default<Int.Zero> var doubleToInt: Int
            ///4.布尔值自动转换成整数，如果转换不成功就取默认值
            @Default<Int.Zero> var boolToInt: Int
            ///5.Double类型支持
            @Default<Double.Zero> var double: Double
            ///6.Float类型支持
            @Default<Float.Zero> var float: Float
            ///7.数组支持
            @Default<Array.Empty> var activaties: [Activaty]
            ///7.数组支持
            @Default<Array.Empty> var emptyArray: [Int]
        }

        
        ///对可选类型值的支持
        let json = """
        {
            "intToString": 100,
            "doubleToString": 12.12,
            "boolToString": true,
            "stringToInt": "11",
            "doubleToInt": 13.13,
            "boolToInt": true,
            "double":14.1412312312312312,
            "float":15.0,
            "status": 99999,
            "activaties": [{
                "name": "元旦迎新活动",
                "status": 4
            }]
        }
        """
        ///可选类型自动转换
        let opt = OptionObject.decodeJSON(from: json)
        print("可选值：\(opt?.jsonString ?? "")")
        
        ///类型自动转换
        guard let obj = Object.decodeJSON(from: json) else {
            print("decode json failed.")
            return
        }
        print("带默认值：\(obj.jsonString ?? "")")
    }

    ///自定义类型
    func customType() {
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
    }
    
    ///
    func example1(){
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
        //print(article?.jsonString ?? "")
    }
    
    func example2(){
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
        print(rsp1?.jsonString ?? "")
        print(rsp2?.jsonString ?? "")
    }
}

