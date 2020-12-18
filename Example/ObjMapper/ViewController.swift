//
//  ViewController.swift
//  ObjMapper
//
//  Created by JIANG PENG CHENG on 12/17/2020.
//  Copyright (c) 2020 JIANG PENG CHENG. All rights reserved.
//

import UIKit
import ObjMapper

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
}

enum Status: Int, Codable, DefaultValue {
    case start = 0
    case process = 1
    case end = 2
    case unknown = 1000
    
    static let defaultValue: Status = .unknown
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
    ///4.自定义枚举值, 如果取值错误或者没有，则取默认值
    @Default<Status> var status: Status
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ///对可选类型值的支持
        let json = """
        {
            "intToString": 100,
            "doubleToString": 12.12,
            "boolToString": true,
            "stringToInt": "11",
            "doubleToInt": 13.13,
            "boolToInt": true,
            "status": 99999
        }
        """
        let opt = OptionObject.decodeJSON(from: json)
        print("可选值：\(opt.toJSONString() ?? "")")
        
        let obj = Object.decodeJSON(from: json)
        print("带默认值：\(obj.toJSONString() ?? "")")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

