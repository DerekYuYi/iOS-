Swift 4.0 引入 `Codable` 来支持 JSON 数据的编解码处理. 下面我们来介绍它的场景使用.

### 介绍

`Codable` 是 `Encodable` 和 `Decodable` 的类型别名.

```swift
public typealias Codable = Decodable & Encodable
```

使用 `Codable` 进行解析很简单. 用于存储数据的 model 遵守 `Codable` 协议, 使用 `JSONDecoder` 做解码操作. `JSONDecoder` 会封装手动解码过程, 只要你约定了 model 中属性值和 JSON 中 key 一一对应, 就能达到优雅的自动解码过程. 下面我们来详细说说几种常见用法.

### 基础解码

假设某个 json 结构只有一层:

```swift
let json = """
{
"name": "John Davis",
"country": "Peru",
"use": "to buy a new collection of clothes to stock her shop before the holidays.",
"loan_amount": 150
}
"""
```

为了解析 *json* 对象, 根据它的 Key 值创建对应数据模型 *Loan*, 该数据模型遵守 `Codable` 协议:

```swift
struct Loan: Codable {
    var name: String
    var country: String
    var use: String
    var amount: Int
  }
```
接下来可以使用 **JSONDecoder** 解析:

```swift
let decoder = JSONDecoder()
if let jsonData = json.data(using: .utf8) {
    let loan = try? decoder.decode(Loan.self, from: jsonData)
    if let loan = loan {
        debugPrint(loan)
    }
}
```

**JSONDecoder** 自动解码 JSON 数据流并且将值存储到指定的类型里面(Loan).

### 自定义属性解码

有些时候, 类型的属性名并不都是和 JSON key 一一对应的. 比如:

```swift
let json = """
{

"name": "John Davis",
"country": "Peru",
"use": "to buy a new collection of clothes to stock her shop before the holidays.",
"loan_amount": 150

}
"""
```

属性名 `amount` 和 key `loan_amount` 不是一一对应的.  那么此时, 我们需要通过 `CodingKey` 协议来改写此组不匹配关系. 更新 `Loan`:

```swift
struct Loan: Codable {
    var name: String
    var country: String
    var use: String
    var amount: Int
    
    enum CodingKeys: String, CodingKey {
    	case name
    	case country
    	case use 
    	case amount = "loan_amount"
    }
  }
```

在进行 encoding 和 decoding 时, 需要一个 String 类型的 key 值来保证唯一性. `CodingKey` 协议的作用就是提供这样一个 key 值. 定义遵循 `CodingKey` 协议的枚举, 并声明为 String 类型. 此时你可以定义属性名在 JSON 中对应的唯一 Key 值. 这里属性 `amount` 对应 Key 值是 `loan_amount`. 如果没有特殊声明属性值对应的 Key 值, 默认为枚举本身对应的 rawValue (String 值). 

> note:  这明显就是 `Codable` 内部 Key 映射关系的一个实现.


### 嵌套 JSON 对象解码

上面的 json 数据源都只有一层结构, 但是实际场景中, json 数据通常有多层嵌套结构. 现在一起来看看如何对嵌套结构 json 数据进行解码.

我们把原来的 json 结构改一下: 把 `country` 字段放入新的 `location` 中, `location` 暂时只有 `country` 字段. 此时 json 有嵌套 JSON 对象 `location`. 如下:

```swift
let json = """
{

"name": "John Davis",
"location": {
"country": "Peru",
},
"use": "to buy a new collection of clothes to stock her shop before the holidays.",
"loan_amount": 150

}
"""
```

现在, 针对 JSON 嵌套结构, 更新 `Loan`:

```swift
struct Loan: Codable {
    var name: String
    var country: String
    var use: String
    var amount: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case country = "location"
        case use
        case amount = "loan_amount"
    }
    
    enum LocationKeys: String, CodingKey {
        case country
    }
   
   // MARK: - Decoder
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // name
        name = try values.decode(String.self, forKey: .name)
        
        // country
        let location = try values.nestedContainer(keyedBy: LocationKeys.self, forKey: .country)
        country = try location.decode(String.self, forKey: .country)
        
        // use
        use = try values.decode(String.self, forKey: .use)
        
        // amount
        amount = try values.decode(Int.self, forKey: .amount)
    }
}
```

1. 由于 json 中的 `location` key 与属性值 `country` 不匹配,  我们仍然通过定义 String 类型枚举来同步匹配. 该枚举遵循 `CodingKey` 协议. 此时有两组自定义匹配值.
2. 为了处理嵌套 JSON 对象, 我们通过再定义一个枚举来解决. 类似第一步, 该枚举为 `LocationKeys`, 同样遵循 `CodingKey` 协议. 定义 case 值 `country` 与嵌套对象的 key `country` 匹配.
3. 实现 `Decodable` 协议来对所有的属性指定解码方式. 第一步调用 `container` 方法, 从指定的编码 key 值中解析数据.  这些 key 都遵循 `CodingKey` 协议.  第二步使用 `decode` 方法来解码某个特定的值. 对于 `name`、`use` 和 `amount` 可以直接解析. 对于 `country` 属性, 需要调用 `nestedContainer` 方法来解析嵌套对象数据, 在此基础上再调用 `decode` 方法.  
4. 如果在 `location` 里还有其他嵌套结构, 我们仍然可以通过第三步来定义解析.

> 思考: 如果需要我们手动来解析嵌套类型, 这步该怎么做? 根据 JSON 内的结构来定义对应的 Model 结构, 比如这里在 `Loan` 中声明一个 `Location` 属性, `Location` 是另外一个 model, 它声明一个 `country` 属性; 又或者是使用另外一种做法, 在解析的过程中声明对应的临时嵌套对象, 然后从该对象中取得数据, 赋值给原来 model. 比如上述示例中临时嵌套对象对应临时的字典, 然后从字典中取 `country` 对应的值给 `Loan` 的属性 `country`. 后者不用关心源结构和 model 的匹配问题. 

### 数组结构解码

在 App 中, 通常有这样的情况: 列表页内容通常为数组对象, 详情页内容通常为字典对象. 那如何处理数组对象呢?

我们这样修改 json 结构:

```swift
let json = """

[{
"name": "John Davis",
"location": {
"country": "Paraguay",
},
"use": "to buy a new collection of clothes to stock her shop before the holidays.",
"loan_amount": 150
},
{
"name": "Las Margaritas Group",
"location": {
"country": "Colombia",
},
"use": "to purchase coal in large quantities for resale.",
"loan_amount": 200
}]

"""
``` 

我们可以这样解析该数组结构:

```swift
if let jsonData = json.data(using: .utf8) {
    let loans = try? decoder.decode([Loan].self, from: jsonData)
}
```

是的, 就是直接指定 **[Loan].self**.

### 选择性忽略键值对

往往, 列表页中的 json 数据带有分页信息, 比如:

```swift
let json = """
{
"paging": {
"page": 1,
"total": 6083,
"page_size": 20,
"pages": 305
},
"loans":
[{
"name": "John Davis",
"location": {
"country": "Paraguay",
},
"use": "to buy a new collection of clothes to stock her shop before the holidays.",
"loan_amount": 150
},
{
"name": "Las Margaritas Group",
"location": {
"country": "Colombia",
},
"use": "to purchase coal in large quantities for resale.",
"loan_amount": 200
}]
}
"""

```
json 数据顶层有两个对象: `paging` 和 `loans`. 如果我不需要 `paging` 信息, 如何在解析时选择忽略它? 或者说我的目标只是 `loans`.  为了达到这点, 我们新定义 `LoanDataStore` model, 只声明 `loans` 属性, 用来匹配 json 中键值 `loans`. 并遵循 `Codable` 协议:

```swift
struct LoanDataStore: Codable {
    var loans: [Loan] // 匹配数据源中的 key: "loans"
}
``` 

现在, 我们可以直接从 json 中这样解析:

```swift
let loanDataStore = try decoder.decode(LoanDataStore.self, from: jsonData)
```


### 与传统 JSON 解析方式: JSONSerialization 的不同点

我们可以来看一段传统 JSON 解析的过程:

```swift
func parseJsonData(data: Data) -> [Loan] {
        var loans = [Loan]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            	
            if let jsonLoans = jsonResult as? [[String: Any]], jsonLoans.count > 0 {
                for jsonLoan in jsonLoans {
                    var loan = Loan()
                    if let name = jsonLoan["name"] as? String {
                        loan.name = name
                    }
                    if let amount = jsonLoan["load_amount"] as? Int {
                        loan.amount = amount
                    }
                    if let use = jsonLoan["use"] as? String {
                        loan.use = use
                    }
                    if let location = jsonLoan["location"] as? [String: Any],
                        let country = location["country"] as? String {
                        loan.country = country
                    }
                    loans.append(loan)
                }
            }
        } catch {
            debugPrint(error)
        }
        
        return loans
    }
```

使用 `JSONSerialization` 来手动解析数据, 转成对应的数组或者字典, 然后再创建对应的数据模型. 如果数据量多, 或者项目中多处使用这样方式, 将会增加更多的代码量.


### 参考链接

[Working with JSON and Codable in Swift 5](https://www.appcoda.com/json-codable-swift/)

*Developer Documentation*: 
	- **Foundation -> Archives and Serialization -> Codable**
	- **Swift -> Swift Standard Library -> Encoding, Decoding, and Serialization -> Codable**