//
//  YYJSExport.swift
//  WKWebviewJSDemo
//
//  Created by DerekYuYi on 2018/12/5.
//  Copyright © 2018 Wenlemon. All rights reserved.
//

// 参考链接: http://www.mengyueping.com/2017/07/02/iOS-JSExport-JSCallOC-Swift/

import UIKit
import JavaScriptCore

// 这里使用 @objc, 是为了在 runtime 时候让特定系统类也遵守这个协议
@objc protocol YYJSExport: JSExport {
    var managedValue: JSManagedValue? { get set }
    
    
    var sum: Int { get set }
    
    func doNothing()
    
    func squared(_ num: Int) -> Int
    func add(_ a: Int, _ b: Int) -> Int
    
    func add(num: Int) -> Int
    func add(num1: Int, num2: Int) -> Int
    func add(num1: Int, _ num2: Int) -> Int
}


class YYObject: NSObject, YYJSExport {
    
    var managedValue: JSManagedValue? {
        willSet{
            print("newValue: \(String(describing: newValue))  |CurrentThread: \(Thread.current)")
        }
        didSet{
            print("oldValue: \(String(describing: oldValue))  |CurrentThread: \(Thread.current)")
        }
    }
    
    var sum: Int = 0 {
        willSet {
            print("newValue: \(newValue)  |CurrentThread: \(Thread.current)")
        }
        
        didSet {
            print("oldValue: \(oldValue)  |CurrentThread: \(Thread.current)")
        }
    }
    
    override init() {
        super.init()
    }
    
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
    func doNothing(){
        print("doNothing--")
    }
    func squared(_ num: Int) -> Int {
        return num * num
    }
    
    func add(num: Int) -> Int {
        return num + 10
    }
    func add(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    func add(num1: Int, _ num2: Int) -> Int {
        return num1 * num2
    }
}
