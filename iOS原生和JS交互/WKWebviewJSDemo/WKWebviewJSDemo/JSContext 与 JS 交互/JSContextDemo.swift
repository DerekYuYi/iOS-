//
//  JSContextDemo.swift
//  WKWebviewJSDemo
//
//  Created by DerekYuYi on 2018/12/5.
//  Copyright © 2018 Wenlemon. All rights reserved.
//

// 参考博客地址: http://www.mengyueping.com/2016/10/16/iOS-callJavaScript/

import UIKit
import JavaScriptCore

class JSContextDemo: NSObject {
    
    
    // -1 初始化 JSContext 对象及异常处理
    // OC 和 Swift 异常会在运行时被 Xcode 捕获, JSContext 中执行的 JS 如果出现异常, 只会被 JSContext 捕获并存在 exception 上. 而不会向外抛出, 合理的方法是: 给 JSContext 设置 exceptionHandler 属性, JS 运行发生异常时, 能第一时间记录
    func test() {
        guard let context = JSContext() else { return }
        
        context.exceptionHandler = { (context, exception) in
            guard let exception = exception else {
                return
            }
            debugPrint(exception)
            context?.exception = exception
        }
        
        let jsStr1 = "1+2"
        let jsvalue1 = context.evaluateScript(jsStr1)
        debugPrint(jsvalue1?.toNumber()?.intValue ?? "")
        
        // -2 取出 js 脚本执行后储存在 JSContext 对象中的变量 (JSContext 在这里相当于一个JS执行的环境)
        let jsStr2 = "var a = 1; var b = 2;"
        let _ = context.evaluateScript(jsStr2)
        let jsValueA = context.objectForKeyedSubscript("a")
        let jsValueB = context.objectForKeyedSubscript("b")
        debugPrint(String(describing: jsValueA))
        debugPrint(String(describing: jsValueB))
        
        // -3 取出 JS 存储的变量, 并且修改
        let jsStr3 = "var arr = [88, 'wenlemon', 66];"
        let _ = context.evaluateScript(jsStr3)
        let jsArr = context.objectForKeyedSubscript("arr")
        debugPrint(String(describing: jsArr))
        jsArr?.setValue("www", at: 0)
        jsArr?.setValue(".com", at: 2)
        
        // -4 通过 JSValue 还可以获取 JS 对象上的属性, 比如: JS数组的长度 ‘length’
        jsArr?.objectForKeyedSubscript("length") // 数组的长度
        jsArr?.objectForKeyedSubscript(0) // 取数组的第一个元素
        
        // -5 取出存储的 JS 集合对象, 并转为 OC 数组对象
        let _ = jsArr?.toArray()
        
        // -6 取出存储的 JS 集合对象, 并直接使用 OC 对象给 JS 对象赋值
        // JSValue 是遵循 JS 的数组特性L: 没有下标越位, 自动延展数组大小. 即: 集合中没有的下标, 元素会自动补空. 并且通过 JSValue 还可以获取 JS 对象上的属性, 比如: JS数组的长度 ‘length’
        jsArr?.setValue(8, at: 8)
        
        // -7 取出存储的 js 函数, 并执行
        context.evaluateScript("function add(a, b){ return a + b; }")
        let addValue = context.objectForKeyedSubscript("add") // JS 函数
        let sum = addValue?.call(withArguments: [1, 2])
        debugPrint(String(describing: sum?.toInt32()))
        
        // -8 使用 context 的 globalObject 调用 JS 的另外一种方法
        let jsValue2 = context.evaluateScript("function multiply(a, b){ return a * b; }")
        let multiplyValue = jsValue2?.context.globalObject.invokeMethod("multiply", withArguments: [2, 4])
        debugPrint(String(describing: multiplyValue?.toInt32()))
        
        // -9 把 Swift 中 Closure 转换成 JS 函数, 并存储到 JSContext 对象
        // Note: convention 用来修饰 闭包的, 后面根参数 block 表示兼容 OC 的闭包, @convention(swift) : 表明这个是一个swift的闭包
        // @convention(c) : 表明这个是兼容c的函数指针的闭包
        let closure: @convention(block) () -> () = {
            debugPrint("++++++++++Begin Log++++++++++")
            guard let args = JSContext.currentArguments() else { return }
            for jsVal in args {
                debugPrint(jsVal)
            }
            let this = JSContext.currentThis()
            debugPrint(String(describing: this))
            debugPrint("++++++++++End Log+++++++++++")
        }
        
        context.setObject(closure, forKeyedSubscript: NSString(string: "log"))
        context.evaluateScript("log('wenlemon', [10,20], {'hello': 'world', 'number': '100'})")
        /*
        Block在JavaScriptCore中起到强大作用，它为JS和Swift之间的转换建立起更多的桥梁，让转换更方便。但需要注意：
        
        在block内部使用外部定义创建的对象，block会对其做强引用，而JSContext也会对被赋予的block做强引用，这样它们之间就形成了循环引用（Circular Reference）使得内存无法正常释放。
        在block内部使用外部定义创建的JSValue对象，也会造成循环引用，因为每个JSValue上都有JSContext的引用（@property (readonly, strong) JSContext *context;），JSContext再引用Block同样也会形成循环引用。
        无论是把Block传给JSContext对象，让其变成JS方法；还是把它赋值给exceptionHandler属性；在Block内都不要直接使用其外部定义的JSContext/JSValue对象，应该将其当做参数传入到Block中，或者通过JSContext的类方法+(JSContext *)currentContext;来获得。否则会造成循环引用使得内存无法被正确释放。
        */
        
        // -10 JSVirtualMachine
        /*
         JSVirtualMachine 为 JS 脚本的执行提供底层资源, 一个 JSVirtualMachine 实例, 代一个独立的 JS 对象空间, 并为其提供执行资源. 它通过加锁, 保证 JSVirtualMachine 是线程安全的, 如果要并发执行 JS, 那我们可以建立多个 JSVirtualMachine 实例, 在不同的实例中执行 JS. 它有独立的堆空间和垃圾回收机制
         */
        // JSVirtualMachine 的创建方式
        // 1. 创建 JSContext 对象时, 内部默认创建一个新的 JSVirtualMachine 对象
        let _ = JSContext()
        
        // 2. 自己创建一个 JSVirtualMachine 对象, 传入创建的 JSContext 对象中
        let jsVM = JSVirtualMachine()
        let _ = JSContext(virtualMachine: jsVM)
        
        // 总结: JSVirtualMachine 为 JavaScript 的运行提供了底层资源, JSContext 为 JavaScript 提供了运行环境, 而 JSContext 的创建都是基于 JSVirtualMachine
        // JSValue 其实就是 JS 对象在 JSVirtualMachine 中的一个强引用
    }
    
    
}

