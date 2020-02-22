//
//  RYAdsPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//
/*
 Abstract: Shows full screen ads images and manages ads's validity. This is used to show Spirits related ad logics rather than webpage.
 */

import UIKit
import Kingfisher

private var isAdsShown = false

class RYAdsPage: UIViewController {
    
    // MARK: - Public Interface
    
    /// Show ads view controller
    /// - Parameter presentingVC: presenting view controller and so ads page is presented view controller.
    static func presentAds(from presentingVC: UIViewController?) {
        // 1. check if ad image has shown
        guard !isAdsShown else { return }
        
        // 2. check if cached ads image
        guard let ad = RYUserDefaultCenter.cachedCoopenImageData(),
            let imageUrlString = ad.resource?.first else { return }
        
        // 3. check if has cached image url
        let cache = ImageCache.default
        
        // To know where the cached image is:
        if !cache.imageCachedType(forKey: imageUrlString).cached { return }
        
        // 4. present ads page
        if let presentingVC = presentingVC {
            let adsStoryboard = UIStoryboard(name: "Ad", bundle: nil)
        
            if let adsPage = adsStoryboard.instantiateViewController(withIdentifier:String(describing: RYAdsPage.self)) as? RYAdsPage {
                adsPage.modalTransitionStyle = .crossDissolve
                presentingVC.present(adsPage, animated: true, completion: nil)
            }
        }
    }
    
    /// Returns a Boolean value indicating whether the ads page can be shown.
    static func isEnableShowAdsPage() -> Bool {
        // 1. check if ad image has shown
        guard !isAdsShown else { return false }
        
        // 2. check if cached ads image
        guard let ad = RYUserDefaultCenter.cachedCoopenImageData(),
            let imageUrlString = ad.resource?.first, !imageUrlString.isEmpty else { return false }
        
        return true
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let countDownCount: Int = 5
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var countDownButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    private var bgShapeLayer = CAShapeLayer()
    private var progressShapeLayer = CAShapeLayer()
    
    private var imageClickUrlString: String?
    
    private var countDownTimer: Timer?
    private var downCount: Int = Constants.countDownCount {
        didSet {
            countDownLabel.text = "\(downCount)"
            if downCount == 0 {
                destory()
                whereToGo()
            }
        }
    }
    
//    private var isAdsShown = false
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup_RYAdsPage() {
    }
    
    // MARK: - Deinit
    
    deinit {
        destory()
    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        isAdsShown = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        bgImageView.addGestureRecognizer(tapGestureRecognizer)
        bgImageView.backgroundColor = .white
        bgImageView.clipsToBounds = true
        bgImageView.contentMode = .scaleAspectFill
        
        // 2. get cached image data
        if let ad = RYUserDefaultCenter.cachedCoopenImageData(),
            let imageUrlString = ad.resource?.first,
            let url = URL(string: imageUrlString) {
            
            // show image
            
            bgImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.1))], progressBlock: nil) { (image, error, cacheType, url) in
                RYAdsDataCenter.sharedInstance.countAds(for: ad.id, withType: .present)
            }
            
            // save imageClickUrlString for tap scene.
            if let imageClickString = ad.click_url, !imageClickString.isEmpty {
                imageClickUrlString = imageClickString
            }
        }
        
        // 3. add countDown label
        countDownLabel.text = "\(downCount)"
        countDownButton.setTitleColor(UIColor.blue, for: .normal)
        countDownLabel.textColor = UIColor.blue
        countDownButton.backgroundColor = nil
        countDownLabel.backgroundColor = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgShapeLayer.path = UIBezierPath(arcCenter: countDownButton.center, radius:
            countDownButton.bounds.height / 2, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true).cgPath
        
        progressShapeLayer.path = UIBezierPath(arcCenter: countDownButton.center, radius:
            countDownButton.bounds.height / 2, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true).cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // draw shape layers
        drawBgShapeLayer()
        drawProgressShapeLayer()
        
        // setup and fire timer
        setupTimer()
        
        // animate shape layer
        addAnimation()
    }
    
    // MARK: - Selectors
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        // guard click url string
        guard let clickString = imageClickUrlString else { return }
        
        // go to webpage related to click url
        RYWebPage.showWebPage(clickString, webTitle: nil, fromVC: self)
        
        // to gather statistic operation action
        if let ad = RYUserDefaultCenter.cachedCoopenImageData() {
            RYAdsDataCenter.sharedInstance.countAds(for: ad.id, withType: .click)
        }
        
        // clean and present
        DispatchQueue.main.async {
            self.destory()
            self.whereToGo()
        }
    }
    
    @IBAction func countDownButtonTapped(_ sender: UIButton) {
        whereToGo()
    }
    
    // MARK: -
    private func destory() {
        countDownTimer?.invalidate()
        countDownTimer = nil
        progressShapeLayer.removeAllAnimations()
    }
    
    private func whereToGo() {
        
        // go to homepage
        let storyboard = UIStoryboard(storyboard: .Main)
        let typeList: RYNavigationController = storyboard.instantiateViewController()
        typeList.modalTransitionStyle = .crossDissolve
        present(typeList, animated: true, completion: nil)
    }
    
}

// MARK: - UI and Animation related

extension RYAdsPage {
    
    private func setupTimer() {
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        self.countDownTimer = timer
        // add timer to default runloop
        RunLoop.main.add(timer, forMode: .default)
    }
    
    private func addAnimation() {
        let basicAnim = CABasicAnimation(keyPath: "strokeEnd")
        basicAnim.fromValue = 0
        basicAnim.toValue = 1
        basicAnim.duration = TimeInterval(downCount)
        progressShapeLayer.add(basicAnim, forKey: nil)
    }
    
    private func drawBgShapeLayer() {
        bgShapeLayer.strokeColor = UIColor.white.cgColor
        bgShapeLayer.fillColor = UIColor.clear.cgColor
        bgShapeLayer.lineWidth = 3
        view.layer.addSublayer(bgShapeLayer)
    }
    
    private func drawProgressShapeLayer() {
        progressShapeLayer.strokeColor = UIColor.orange.cgColor
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.lineWidth = 3
        view.layer.addSublayer(progressShapeLayer)
    }
    
    @objc private func countDown() {
        if let _ = self.countDownTimer {
            downCount -= 1
        }
    }
    
    // MARK: - Status bar and home indicator
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
