//
//  FMSwiftJSON.swift
//  SwiftJson
//
//  Created by 周发明 on 17/9/14.
//  Copyright © 2017年 周发明. All rights reserved.
//

import Foundation

protocol FMJSON {
    
}

extension FMJSON where Self : NSObject {
    
    static func model(_ jsonString: String) -> Self {
        let model = Self()
        guard let data = jsonString.data(using: .utf8) else {
            return model
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard json as? [String:Any] != nil else {
            return model
        }
        model.model(json as! [String:Any])
        return model
    }
    
    static func models(_ jsonsString: String) -> [Self] {
        
        guard let data = jsonsString.data(using: .utf8) else {
            return [Self]()
        }
        let jsons = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard jsons as? [[String:Any]] != nil else {
            return [Self]()
        }
        return self.models(jsons as? [[String : Any]])
    }
    
    static func model(_ json: [String:Any]) -> Self {
        let model = Self()
        model.model(json)
        return model
    }
    
    static func models(_ jsons: [[String:Any]]?) -> [Self] {
        
        if jsons == nil {
            return [Self]()
        }
        
        var items = [Self]()
        for json in jsons! {
            let model = self.model(json)
            items.append(model)
        }
        return items
    }
    
    fileprivate func model(_ json: [String:Any]) -> Void {
        for (key, value) in json {
            if selfProperties.keys.contains(key) {
                let property = selfProperties[key]
                if property!.isArray {
                    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    let objClass = (NSClassFromString("\(namespace).\(removeArray(property!.type))") as! NSObject.Type)
                    var models = [Any]()
                    if let arrs = value as? [[String:Any]] {
                        for dict in arrs {
                            let model = objClass.init()
                            model.model(dict)
                            models.append(model)
                        }
                    }
                    self.setValue(models, forKey: key)
                } else if property!.isFMJson {
                    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    let objClass = (NSClassFromString("\(namespace).\(removeOptional(property!.type))") as! NSObject.Type)
                    let model = objClass.init()
                    model.model(value as! [String:Any])
                    self.setValue(model, forKey: key)
                } else {
                    self.setValue(value, forKey: key)
                }
            }
        }
    }
}

fileprivate struct FMProperties {
    let name: String
    var isFMJson: Bool = false
    var isArray: Bool = false
    
    let type: Any.Type
}

extension NSObject: FMJSON {
    
    fileprivate static var properties: [String:FMProperties] {
        let model = self.init()
        return model.selfProperties
    }
    
    fileprivate static var isJson: Bool {
        var json = true
        if let _ = self as? FMJSON {
            json = true
        } else {
            json = false
        }
        return json
    }
    
    fileprivate var selfProperties: [String:FMProperties]{
        
        if let properties = FMPropertiesManager.manager.propertyDict["\(type(of: self))"] {
            return properties
        }
        
        var mirror = Mirror(reflecting: self)
        var names = [String:FMProperties]()
        for child in mirror.children {
            let pro = getProperty(child.value, name: child.label!)
            names[child.label!] = pro
        }
        
        var objClass = self.superclass
        while objClass != nil && objClass != NSObject.self {
            guard let superMirror = mirror.superclassMirror else {
                break
            }
            for child in superMirror.children {
                let pro = getProperty(child.value, name: child.label!)
                names[child.label!] = pro
            }
            mirror = superMirror
            objClass = objClass?.superclass()
        }
        
        FMPropertiesManager.manager.propertyDict["\(type(of: self))"] = names
        return names
    }
    
    fileprivate func getProperty(_ value: Any, name: String) -> (FMProperties) {
        let type: Any.Type = type(of: value)
        let isArray = removeOptionalIsArray(type)
        let isJson = removeOptionalIsJson(type)
//        print(type, isArray, isJson)
        return FMProperties(name: name, isFMJson: isJson, isArray: isArray, type: type)
    }
    
    fileprivate func removeOptionalIsJson(_ type: Any.Type) -> (Bool) {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let typeStr = "\(type)".replacingOccurrences(of: "Optional<", with: "").replacingOccurrences(of: ">", with: "")
        if let objClass = (NSClassFromString("\(namespace).\(typeStr)") as? NSObject.Type) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func removeOptionalIsArray(_ type: Any.Type) -> (Bool) {
        if "\(type)".contains("Array") {// 是数组
            let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            if let objClass = (NSClassFromString("\(namespace).\(removeArray(type))") as? NSObject.Type) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    fileprivate func removeOptional(_ type: Any.Type) -> (String) {
        let typeStr = "\(type)".replacingOccurrences(of: "Optional<", with: "").replacingOccurrences(of: ">", with: "")
        return typeStr
    }
    
    fileprivate func removeArray(_ type: Any.Type) -> (String) {
        var typeStr = removeOptional(type)
        typeStr = typeStr.replacingOccurrences(of: "Array<", with: "").replacingOccurrences(of: ">", with: "")
        return typeStr
    }
}


fileprivate class FMPropertiesManager {
    
    static let manager: FMPropertiesManager = FMPropertiesManager()
    
    lazy var propertyDict: [String:[String:FMProperties]] = {
        return [String:[String:FMProperties]]()
    }()
}
