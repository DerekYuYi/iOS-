//
//  RYDishDetailsIngredientCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/24.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYDishDetailsIngredientCell: UITableViewCell {
    
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientValueLabel: UILabel!
    @IBOutlet weak var baseLineView: UIView!
    private var shapeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashLine(for: baseLineView)
    }
    
    func update(_ data: RYInGredient) {
        if let name = data.name {
            ingredientNameLabel.text = name
        }
        
        if let value = data.size {
            ingredientValueLabel.text = value
        }
    }
    
    private func dashLine(for view: UIView) {
        let shapeLayer = CAShapeLayer()
//        shapeLayer.frame = view.bounds
        let width: CGFloat = contentView.bounds.width - 35*2
        let height: CGFloat = 1
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: width, y: 0))
        shapeLayer.path = linePath.cgPath
        
        shapeLayer.lineWidth = 1.0 / UIScreen.main.scale
        shapeLayer.lineDashPattern = [5, 2]
        shapeLayer.strokeColor = RYFormatter.color(from: 0xdddedd).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
        view.backgroundColor = nil // remove parent view background color
    }

}
