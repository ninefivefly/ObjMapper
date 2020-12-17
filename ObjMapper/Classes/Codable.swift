//
//  Codable.swift
//  ObjMapper
//
//  Created by JIANG PENG CHENG on 2020/12/17.
//

import Foundation

public extension Encodable {
    func toJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toJSONObject() -> Any? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}

public extension Decodable {
    static func decodeJSON(from string: String?, designatedPath: String? = nil) -> Self? {
        decodeJSON(from: string?.data(using: .utf8), designatedPath: designatedPath)
    }
    
    static func decodeJSON(from jsonObject: Any?, designatedPath: String? = nil) -> Self? {
        if let jsonObject = jsonObject,
            JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: []){
            return decodeJSON(from: data, designatedPath: designatedPath)
        }
        return nil
    }
    
    static func decodeJSON(from data: Data?, designatedPath: String? = nil) -> Self? {
        guard let data = data,
            let jsonData = getInnerObject(inside: data, by: designatedPath) else {
                return nil
        }
        return try? JSONDecoder().decode(Self.self, from: jsonData)
    }
}

public extension Array where Element: Codable {
    static func decodeJSON(from jsonString: String?, designatedPath: String? = nil) -> [Element?]? {
        guard let data = jsonString?.data(using: .utf8),
            let jsonData = getInnerObject(inside: data, by: designatedPath),
            let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [Any] else {
            return nil
        }
        return Array.decodeJSON(from: jsonObject)
    }
    
    static func decodeJSON(from array: [Any]?) -> [Element?]? {
        return array?.map({ (item) -> Element? in
            return Element.decodeJSON(from: item)
        })
    }
}

private func getInnerObject(inside jsonData: Data?, by designatedPath: String?) -> Data? {
    guard let _jsonData = jsonData,
        let paths = designatedPath?.components(separatedBy: "."),
        paths.count > 0 else {
        return jsonData
    }
    
    let jsonObject = try? JSONSerialization.jsonObject(with: _jsonData, options: .allowFragments)
    var result: Any? = jsonObject
    var abort = false
    var next = jsonObject as? [String: Any]
    paths.forEach({ (seg) in
        if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
            return
        }
        if let _next = next?[seg] {
            result = _next
            next = _next as? [String: Any]
        } else {
            abort = true
        }
    })
    
    guard abort == false,
        let resultJsonObject = result,
        let data = try? JSONSerialization.data(withJSONObject: resultJsonObject, options: []) else {
        return nil
    }
    return data
}

