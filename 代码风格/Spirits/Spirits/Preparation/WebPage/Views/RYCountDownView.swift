//
//  RYCountDownView.swift
//  Spirits
//
//  Created by DerekYuYi on 2020/1/10.
//  Copyright © 2020 RuiYu. All rights reserved.
//

import UIKit

private let countDownCount: Int = 30

protocol RYCountDownViewDelegate: NSObjectProtocol {
    func countDownDidEnd()
}

/// Indicates count down views when read news and novels.
class RYCountDownView: UIView {
    
    weak var delegate: RYCountDownViewDelegate?
    
    private lazy var bgShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private lazy var progressShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = RYColors.color(from: 0xF9525C).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private lazy var circleShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = RYColors.color(from: 0xF9C4C7).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private lazy var secondLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "\(countDownCount)"
        label.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
        label.backgroundColor = RYColors.color(from: 0xF98B91)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "s"
        label.font = UIFont.systemFont(ofSize: 8.0, weight: .medium)
        label.backgroundColor = RYColors.color(from: 0xF98B91)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var flagView: UIView = {
        let view = UIView()
        view.backgroundColor = RYColors.color(from: 0x4EFCFA)
        return view
    }()
    
    private var timer: Timer?
    
    private var seconds: Int = countDownCount {
        didSet {
            DispatchQueue.main.async {
                self.secondLabel.text = "\(self.seconds)"
            }
            if seconds == 0 {
                invalidateTimer()
                progressShapeLayer.removeAllAnimations()
                delegate?.countDownDidEnd()
                progressShapeLayer.strokeEnd = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupViews() {
        layer.addSublayer(bgShapeLayer)
        layer.addSublayer(circleShapeLayer)
        layer.addSublayer(progressShapeLayer)
        addSubview(secondLabel)
        addSubview(flagView)
        addSubview(sLabel)
        
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        secondLabel.widthAnchor.constraint(equalToConstant: 38.0).isActive = true
        secondLabel.heightAnchor.constraint(equalToConstant: 38.0).isActive = true
        secondLabel.roundedCorner(nil, 38.0/2.0)
        
        sLabel.translatesAutoresizingMaskIntoConstraints = false
        sLabel.bottomAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: -11).isActive = true
        sLabel.trailingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: -2.0).isActive = true
        sLabel.widthAnchor.constraint(equalToConstant: 4.0).isActive = true
        sLabel.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        
        flagView.translatesAutoresizingMaskIntoConstraints = false
        flagView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        flagView.topAnchor.constraint(equalTo: secondLabel.topAnchor, constant: 3.0).isActive = true
        flagView.widthAnchor.constraint(equalToConstant: 7.0).isActive = true
        flagView.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        flagView.roundedCorner(nil, 3.0/2.0)
    }
    
    func startCountDown() {
        resetCountInfos()
        setupTimer()
        addAnimation()
    }
    
    func addShadow(_ color: UIColor, cornerRadius radius: CGFloat) {
        layer.cornerRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.15
        layer.shadowColor = color.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: [.topLeft, .bottomLeft],
                                        cornerRadii: CGSize(width: 0, height: 3)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgShapeLayer.path = UIBezierPath(arcCenter: secondLabel.center,
                                         radius: 22,
                                         startAngle: -CGFloat.pi / 2,
                                         endAngle: CGFloat.pi / 2 * 3,
                                         clockwise: true).cgPath
        
        progressShapeLayer.path = UIBezierPath(arcCenter: secondLabel.center,
                                               radius: 22,
                                               startAngle: -CGFloat.pi / 2,
                                               endAngle: CGFloat.pi / 2 * 3,
                                               clockwise: true).cgPath
        
        circleShapeLayer.path = UIBezierPath(arcCenter: secondLabel.center,
                                             radius: 22,
                                             startAngle: -CGFloat.pi / 2,
                                             endAngle: CGFloat.pi / 2 * 3,
                                             clockwise: true).cgPath
    }
    
    private func addAnimation() {
        let basicAnim = CABasicAnimation(keyPath: "strokeEnd")
        basicAnim.fromValue = 0
        basicAnim.toValue = 1
        basicAnim.duration = TimeInterval(seconds)
        progressShapeLayer.add(basicAnim, forKey: nil)
    }
    
    func pauseAnimation() {
        
        guard timer != nil else { return }
        
        invalidateTimer()
        
        let pausedTime = progressShapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressShapeLayer.speed = 0
        progressShapeLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        
        guard timer == nil else { return }
        
        seconds -= 1
        DispatchQueue.main.async {
            self.setupTimer()
        }
        
        let pausedTime = progressShapeLayer.timeOffset
        progressShapeLayer.speed = 1
        progressShapeLayer.timeOffset = 0
        progressShapeLayer.beginTime = 0
        let timeSincePause = progressShapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressShapeLayer.beginTime = timeSincePause
    }
    
    // MARK: - Timer related
    
    private func setupTimer() {
        if let _ = timer { return }
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timeCount), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func invalidateTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }
    
    @objc private func timeCount() {
        seconds -= 1
    }
    
    func resetCountInfos() {
        invalidateTimer()
        seconds = countDownCount
        progressShapeLayer.removeAllAnimations()
    }

}
