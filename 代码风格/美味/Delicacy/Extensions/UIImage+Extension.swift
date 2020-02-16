//
//  UIImage+Extension.swift
//  YunLingTenemental
//
//  Created by DerekYuYi on 2018/8/1.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Foundation

enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

extension UIImage {
    static func image(from color: UIColor) -> UIImage {
        var image = UIImage()
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
            if let currentImage = UIGraphicsGetImageFromCurrentImageContext() {
                image = currentImage
            }
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    /// compress to special size
    func compress(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        if let context = context, let cgimage = self.cgImage {
            context.draw(cgimage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        }
        
        if let currentImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return currentImage
        } else {
            UIGraphicsEndImageContext()
            return self
        }
    }
    
    /// resize for bytes
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}


