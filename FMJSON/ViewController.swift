//
//  ViewController.swift
//  FMJSON
//
//  Created by 周发明 on 2017/12/2.
//  Copyright © 2017年 周发明. All rights reserved.
//

import UIKit

class Son: NSObject {
    var height:Int = 0
}

class Person: NSObject {
    public var name: String = "zzzzzzzzz"
    var age: Int = 0
    var son: Son = Son()
    var optSon: Son? = nil
    var sons: [Son] = [Son]()
    var optSons: [Son]? = nil
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print(value, key)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = ["optSon":["height":41], "son":["height":30], "name":"呵呵哒", "age":20, "sons": [["height":21], ["height":22]], "optSons": [["height":21],["height":21],["height":21], ["height":22]]] as [String : Any]
        
        let person = Person.model(json)
        
        print("姓名:\(person.name)\n年龄:\(String(describing: person.age))\n儿子身高:\(String(describing: person.son.height))\n儿子个数:\( person.sons.count)")
        print("可选儿子身高:\(String(describing: person.optSon?.height))\n可选儿子个数:\(String(describing: person.optSons?.count))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

