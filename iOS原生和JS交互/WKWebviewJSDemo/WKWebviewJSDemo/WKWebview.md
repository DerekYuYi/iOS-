# iOS 与 JS 交互的关键点:

#### iOS 中调用 JS 函数或者一段 JS 代码:

使用 **evaluateJavaScript**来执行对应的 JS 函数


#### iOS 中监听 JS 函数调用, 并作出相应的行为. 通过监听 `decidePolicyFor navigationAction`  来监听对应的URL

#### JS 向 iOS 发消息是通过注册 `ScriptMessageHandler` 来实现, `ScriptMessageHandler` 由 `WKWebView` 的 `WKUserContentController` 来注册, `iOS` 端通过实现协议 `WKScriptMessageHandler` 来接受处理 `JS` 脚本发送过来消息


# iOS 中利用 JavaScriptCore 交互 JS

#### 相关的类有: JSContext, JSValue, JSManagedValue, JSVirtualMachine, JSExport

- `JSContext` 是运行 JS 的环境, 类似于 window 对象.
- `JSValue` 包含每个 JS 类型的值, 都是由 `JSContext` 返回或者创建的.  以下是 `JSValue` 对应的值:

|    OC or Swift Type    |  JavaScript Type   |   
| -----------------------|--------------------|
|          nil           |     undefined      |
|         NSNull         |         null       |
|     NSString String    |       string       |
|       NSNumber         | number, boolean    |
| NSDictionary Dictionary|    Object object   |
|      NSArray Array     |    Array object    |
|      NSDate Date       |     Date object    |
|     NSBlock Closure    |   Function object  |
|     id AnyObject       |   Wrapper object   |
|         Class          | Constructor object | 
