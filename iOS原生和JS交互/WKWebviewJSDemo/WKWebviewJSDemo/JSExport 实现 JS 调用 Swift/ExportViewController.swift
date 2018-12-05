//
//  ExportViewController.swift
//  WKWebviewJSDemo
//
//  Created by DerekYuYi on 2018/12/5.
//  Copyright © 2018 Wenlemon. All rights reserved.
//

import UIKit
import JavaScriptCore

class ExportViewController: UIViewController {
    let obj = YYObject()
    lazy var context: JSContext? = {
        return JSContext()
    }()
    
    lazy var textField: UITextField = {
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 监听异常
        context?.exceptionHandler = { (context, exception) in
            guard let exce = exception else { return }
            context?.exception = exce
            print("JS抛出exception: \(exce)")
        }
        
        // 把 block 转化为 js 函数
        let block: @convention(block) () -> () = {
            print("++++++Begin Log++++++")
            
            if let args = JSContext.currentArguments() {
                for jsVal in args {
                    print(jsVal)
                }
            }
            
            print("---End Log------")
        }
        
        context?.setObject(block, forKeyedSubscript: NSString(string: "log"))
        
        // ----------------------------------------
        // ----------  JSExport 实现 JS 调用自定义类的对象属性和方法 --------------
        // ----------------------------------------
        jsInvokeCustomClass()
        
        
        // ----------------------------------------
        // ----------  JSExport 实现 JS 调用系统类的对象属性和方法 --------------
        // ----------------------------------------
        jsInvokeSystemClass()
    }
    
    private func jsInvokeCustomClass() {
        // 把 Swift 对象存储到 JSContext 中, 便于在 JS 环境中就可以调用 Swift 对象和属性
        context?.setObject(obj, forKeyedSubscript: NSString(string: "SwiftObj"))
        
        let _ = context?.evaluateScript("function callback(){};")
        obj.managedValue = JSManagedValue(value: context?.objectForKeyedSubscript("callback"))
        // JSVirtualMachine 通过 addManagedReference 来建立 JSManagedValue 对象与控制器 self 之间的弱引用关系
        context?.virtualMachine.addManagedReference(obj.managedValue, withOwner: self)
        
        // JS 调用 Swift 对象的方法和属性, 该对象遵守 JSExport 协议
        debugPrint(context?.evaluateScript("log(SwiftObj.doNothing(5))") ?? "no value")
        debugPrint(context?.evaluateScript("log(Swiftobj.doNothing(5))") ?? "no value")
        debugPrint(context?.evaluateScript("log(Swiftobj.squared(5))") ?? "no value")
        debugPrint(context?.evaluateScript("log(Swiftobj.add(5,5))") ?? "no value")
        // 有语法区别
        debugPrint(context?.evaluateScript("log(Swiftobj.addWithNum(5))") ?? "no value")
        debugPrint(context?.evaluateScript("log(Swiftobj.addWithNum1Num2(10,10))") ?? "no value")
        debugPrint(context?.evaluateScript("log(Swiftobj.addWithNum1(10,10))") ?? "no value")
        
        context?.evaluateScript("Swiftobj.sum = Swiftobj.add(2,3)")
        debugPrint(context?.evaluateScript("log(Swiftobj.sum") ?? "no value")
        debugPrint("obj.sum: \(obj.sum)")
    }
    
    
    private func jsInvokeSystemClass() {
        // 给 UITextField 类添加 YYJSExport 协议, 因为用到了 runtime, 所以需要用 @objc 来修饰 YYJSExport 
        class_addProtocol(UITextField.self, YYJSExport.self)
        
        context?.setObject(textField, forKeyedSubscript: NSString(string: "textField"))
        let  _ = context?.evaluateScript("log(textField.text)")
        
        let script = "var num = parseInt(textField.text, 10); ++num; textField.text = num;"
        let _ = context?.evaluateScript(script)
        
        // Note: JS 脚本调用 Swift 是在子线程还是在主线程, 如果是更新原生UI, 需要注意在主线程执行
    }

    
    /** 关于循环引用
     关于内存管理，OC/Swift使用ARC，而JS使用的是垃圾回收机制，且JS中所有的引用都是强引用，不过JS的循环引用，垃圾回收会帮他们打破。在使用JavaScriptCore里面提供的API时，关于OC/Swift和JS对象之间内存管理，需要注意，
     - 不要在Block/Closure里面直接使用外部的JSContext对象和外部的JSValue对象；
     - OC/Swift对象不要用属性直接保存JSValue对象，太容易循环引用。可以使用JSManagedValue，JSManagedValue帮我们保存了JSValue，这个是弱引用，但必须保证保存的JS对象在JS环境中是存在的
     - 不要在不同的JSVirtualMachine之间进行传递JS对象。一个JSVirtualMachine可以运行多个JSContext对象，由于在同一个堆内存和同一个垃圾回收下，所以相互之间传值是没有问题的。但是如果在不同的JSVirtualMachine之间传值，垃圾回收就不知道他们之间的关系了，可能会引起异常。
     
     有时候为了方便调用，要全局保存JSValue对象，就可以通过全局保存JSManagedValue变量，来达到全局拿到JSValue对象的目的，这样可以避免产生循环引用。这也是JSManagedValue主要用途，解决JSValue对象在OC/Swift堆上的安全引用问题。把JSValue保存进OC/Swift堆对象中是不正确的，这很容易引发循环引用，而导致JSContext不能释放
     
     
     */
    
    

}
