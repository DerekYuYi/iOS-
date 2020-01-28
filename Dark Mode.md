# Dark Mode 总结

> **使用 Visual-Effect Meterials 突出其他意图.**

- 使用系统的标准控件, UIKit 会帮助你自动是适配不同模式. 推荐使用系统的 sematic color (system color).

- 选择可适应的颜色. 创建适应的颜色对象方法有2个:
	- 使用语义颜色来代替固定颜色值. 比如 labelColor, 完成的 sematic color list, 参阅 UIColor
	- 在 asset catalog 中定义自定义的颜色. 当你需要一个指定的颜色时, 使用 color asset 来创建该颜色. 使用 Xcode asset -> 增加一个 Color Set asset, 然后添加 Light Appearance, Dark Appearance 或者 Any Appearance(配置 iOS 12 及其以下的颜色)
	
	```Swift
	/// 该对象不需要重新创建, 因为 current appearance 改变, 会自动匹配环境设置. 作用与 sematic color 一样
	let aColor = UIColor(named: "customControlColor")
	```

- 为外观创建图像. 如果需要在不同外观下显示不同的图片, 这里有三种办法.
	1. 新建 images asset. 
	2. 使用符号图像和模版图像. 好处是不需要增加 image asset. 该图像仅定义要渲染的图像, 因此不需要在亮, 暗, 和高对比度环境中使用单独的图像. 具体的解决方案是使用 images 和 icons 的 tintColor. 设置 images 或者 icons 的 Render mode 为 template. 你可以在 assets 中设置, 也可以代码设置:

		```Swift
		let iconImage = UIImage()
		let imageView = UIImageView()
		imageView.image = iconImage.withRenderingMode(.alwaysTemplate)
		```

   3. inverting colors as a solution for images(反转颜色, 白色变为黑色, 黑色变为白色). 同样可以在保持 image 大小的情况下适配不同模式. 不需要增加新的 image asset. 使用以下 extension 来解决:

	   ```Swift
	   extension UIImage {
	    /// Inverts the colors from the current image. Black turns white, white turns black etc.
	    func invertedColors() -> UIImage? {
	        guard let ciImage = CIImage(image: self) ?? ciImage, let filter = CIFilter(name: 	"CIColorInvert") else { return nil }
	        filter.setValue(ciImage, forKey: kCIInputImageKey)
	
	        guard let outputImage = filter.outputImage else { return nil }
	        return UIImage(ciImage: outputImage)
	   		 }
		}
		
		/// 当界面发生变化, 你需要手动管理相关变化
		
		// MARK: - Dark Mode Support
		private func updateImageForCurrentTraitCollection() {
		    if traitCollection.userInterfaceStyle == .dark {
		        imageView.image = originalImage?.invertedColors()
		    } else {
		        imageView.image = originalImage
		    }
		}
	
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		    super.traitCollectionDidChange(previousTraitCollection)
		    updateImageForCurrentTraitCollection()
		}
   ```

- 使用特定的方法更新视图. 当用户改变了系统外观时, 系统自动要求每个窗口和视图重新绘制. 此时, 系统会调用这几个方法:
	
	| Class | Appropriate Methods |
	| ---- | ----- | 
	| NSView | updateLayer() |
	| UIView | traitCollectionDidChange(_:) |
	| UIViewController | traitCollectionDidChange(_:) |
	| UIPresnetationController | traitCollectionDidChange(:_) |
	
	系统在调用这几个方法之前已经更新 特征环境 (trait environment). 
	这是做外观修改最好的方法时机. 如果在这些方法之外, app 将不会正确适配当前环境. 比如我们在初始化时设置 cgColor(CGImage or CALayer), 因为 cgColor 不属于 UIKit, 不会自动适配颜色, 初始化时只会是留下一个固定的颜色. 
	
	```Swift
	override func updateLayer() {
	   	self.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
	
	   	// Other updates.
	}
	```

- 根据需要适配. 为 app 选择一个指定的界面风格. 并不总是 light or dark.
- 避免执行昂贵的任务在外观过渡期间. 尽管系统管理整个绘制过程, 但是整个过程仍然依赖在特定的几个方法中的代码. 这个方法中的代码应该尽可能快, 而且不应该包括与外观改变无关的代码. (注: 这个方法就是 updateLayer()/traitCollectionDidChange(_:)).


## 为App选择指定的界面风格

1. 重载属性 `overrideUserInterface`. 比如, 为某个控制器固定配置 light 风格: 

	```Swift
	override func viewDidLoad() {
        super.viewDidLoad()

        // Always adopt a light interface style.    
        overrideUserInterfaceStyle = .light
    }
	```
	
	重载界面风格, 会有以下影响:  
	
	- View Controllers - 该控制器的 view 和 子控制器都采用该风格;
	- Views - 当前视图 和 所有子视图采用该风格;
	- Windows - 在 window 中的所有事物都采用该风格. 包括根控制器, 所有 presnetation controller.
	
2. 控制某个子控制器的外观, 使用 **setOverrideTraitCollection(_:forChild:)** method 来赋值一个新的 trait 给子控制器.
3. 完全退出 Dark Mode. 在 info.plist 中增加 key: **UserInterfaceStyle**, 并且设置值为 Light.


## 为不同的外观提供图像

创建位图(bitmap image)可替代的方案是使用 template image 和 symbol image 代替. template image 指定了要画的形状, 但是没有内容; Symbol images 和 template image 相似, 但是基于向量, 可以变化不同的大小.

1. 适配外观, 管理图片最好的方法是使用 asset catalogs.
2. 使用 Symbol images 来创建可扩展的, 颜色可变的图像. 一般用于显示简单的图形、符号或者结合icon和描述的地方. 系统提供了许多 symbol images.
3. 使用 template images 创建颜色可变的(Tintable)图像. (设计给出图像文件, 背景为颜色透明的). 加入到 asset catalog, 设置 Render As option for Image Set asset to Template Image in the inspector.

## 在UI中配置、展示符号图像(symbol images)

1. 在 symbol 中选择 Symbol Images;
2. 自定义 symbol image: 创建 Symbol Image asset, 然后通过名字加载.
3. UIKit 提供加载的方法有:
	- Load system-supplied symbol images using the **init(systemName:)**, **init(systemName:compatibleWith:)**, or **init(systemName:withConfiguration:)** methods of UIImage.
	- Load your app’s custom symbol images using the **init(named:)**, **init(named:in:compatibleWith:)**, or **init(named:in:with:)** methods of UIImage.

	```Swift
	let image = UIImage(systemName: "multiply.circle.fill")
	```
		

### 相关的实现代码有:

```Swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if #available(iOS 13.0, *) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            configForUserInterfaceStyle()
        }
    }
}

/// border color
private func configForUserInterfaceStyle() {
    if #available(iOS 12.0, *) {
        if traitCollection.userInterfaceStyle == .light {
            cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
            arrowDownImageView.tintColor = .black
        } else {
            cornerView.layer.borderColor = UIColor.white.cgColor
            /// 使用 template image 来使图片颜色变得 tintable
            arrowDownImageView.tintColor = .white
        }
    } else {
        cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
        arrowDownImageView.tintColor = .black
    }
}

/// 2. 使用 color asset 来创建颜色
if #available(iOS 11.0, *) {
    cornerView.backgroundColor = UIColor(named: "Color_FCFCFC")
    titleTextField.backgroundColor = UIColor(named: "Color_FCFCFC")
} else {
    cornerView.backgroundColor = .white
    titleTextField.backgroundColor = RYColors.color(from: 0xfcfcfc)
}

/// 3. 实现 iOS 12 以及以下支持 semantic colors
public enum DefaultStyle {

    public enum Colors {

        public static let label: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return .black
            }
        }()
    }
}

public let Style = DefaultStyle.self

let label = UILabel()
label.textColor = Style.Colors.label

/// 4. 创建自定义的 semantic color

public static var tint: UIColor = {
    if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return Colors.osloGray
            } else {
                /// Return the color for Light Mode
                return Colors.dataRock
            }
        }
    } else {
        /// Return a fallback color for iOS 12 and lower.
        return Colors.dataRock
    }
}()

```

### 参考来源

- [WWDC2019](https://developer.apple.com/documentation/uikit/appearance_customization/adopting_ios_dark_mode)
- [Adopting_ios_dark_mode](https://developer.apple.com/documentation/uikit/appearance_customization/adopting_ios_dark_mode)
- [SwiftLee](https://www.avanderlee.com/swift/dark-mode-support-ios/)
- Xcode -> Window -> Develop documentation -> Appkit -> Supporting Dark Mode in Your Interface
