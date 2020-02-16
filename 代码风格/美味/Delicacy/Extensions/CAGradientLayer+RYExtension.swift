//
//  CAGradientLayer+RYExtension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    
    // MARK: - Direction
    enum Point {
        case topRight, topLeft
        case bottomRight, bottomLeft
        case cushtion(point: CGPoint)
        
        var point: CGPoint {
            switch self {
                case .topRight: return CGPoint(x: 1, y: 0)
                case .topLeft: return CGPoint(x: 0, y: 0)
                case .bottomRight: return CGPoint(x: 1, y: 1)
                case .bottomLeft: return CGPoint(x: 0, y: 1)
                case .cushtion(let point): return point
            }
        }
    }
    
    // MARK: - Init
    convenience init(_ frame: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.init()
        guard frame.equalTo(CGRect(x: 0, y: 0, width: 0, height: 0)) else {
            return
        }
        
        self.frame = frame
        self.colors = colors.map { $0.cgColor }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    convenience init(_ frame: CGRect, colors: [UIColor], startPoint: Point, endPoint: Point) {
        self.init(frame, colors: colors, startPoint: startPoint.point, endPoint: endPoint.point)
    }
    
    func gradientImage() -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        
        UIGraphicsBeginImageContext(frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
