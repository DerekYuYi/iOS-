//
//  RYPresenter.swift
//  MeiQingWeather
//
//  Created by DerekYuYi on 2019/1/25.
//  Copyright © 2019 SmartRuiYu. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class RYPresenter: UIViewController {
    
    var willBeSharedImage: UIImage?
    var willBeSharedText: String?
    
    private var shareBoard: RYShareBoard?
    private var shareBoardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Do any additional setup after loading the view.
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // add shareboard view
        if let shareBoard = Bundle.main.loadNibNamed("RYShareBoard", owner: nil, options: nil)?.first as? RYShareBoard {
            self.shareBoard = shareBoard
            shareBoard.delegate = self
            view.addSubview(shareBoard)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let shareBoard = self.shareBoard {
            shareBoardHeight = shareBoard.preferredHeight() // Saves height to avoid calculating repeatly.
            if let shareBoardHeight = shareBoardHeight {
                shareBoard.frame = CGRect(x: 0, y: view.bounds.height - shareBoardHeight, width: view.bounds.width, height: shareBoardHeight)
            }
        }
    }
    
    deinit {
       self.view.clearToastQueue()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showShareBoard(true)
    }
    */
    
    @objc private func viewTapped() {
        showShareBoard(false)
    }
    
    // MARK: - ShareBoard related
    func showShareBoard(_ isShow: Bool) {
        guard let shareBoard = self.shareBoard,
            let shareBoardHeight = self.shareBoardHeight else { return }
        
        if isShow {
            UIView.animate(withDuration: 0.1) {
                shareBoard.isHidden = false
                shareBoard.frame = shareBoard.frame.offsetBy(dx: 0, dy: -shareBoardHeight)
            }
        } else {
            UIView.animate(withDuration: 0.18, animations: {
                shareBoard.frame = shareBoard.frame.offsetBy(dx: 0, dy: shareBoardHeight)
            }) { isFinish in
                shareBoard.isHidden = true
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension RYPresenter: RYShareBoardDelegate {
    func shareToWechat(for scene: WXScene) {
        
        if let reachability = NetworkReachabilityManager() {
            reachability.startListening()
            if !reachability.isReachable {
                self.view.makeToast("网络状况不佳", duration: 1.5, position: .center) { _ in
                    DispatchQueue.main.async {
                        self.showShareBoard(false)
                    }
                }
                return
            }
        }
        
        guard RYWechatManager.isWechatInstalled() else {
            self.view.makeToast("您未安装微信, 请安装微信后重试", duration: 1.5, position: .center) { _ in
                DispatchQueue.main.async {
                    self.showShareBoard(false)
                }
            }
            return
        }
        
        guard let willBeSharedImage = willBeSharedImage else {
            self.view.makeToast("菜品图片未加载完成", duration: 1.5, position: .center) { _ in
                DispatchQueue.main.async {
                    self.showShareBoard(false)
                }
            }
            return
        }
        
        guard let imageData = willBeSharedImage.jpegData(compressionQuality: 0.7) else {
                self.view.makeToast("图片格式错误", duration: 1.5, position: .center) { _ in
                    DispatchQueue.main.async {
                        self.showShareBoard(false)
                    }
                }
                return
        }
        
        RYWechatManager.shareToWechat(for: scene,
                                      objectType: .image,
                                      objectData: [RYWechatManager.imageDataKey : imageData])
        
        DispatchQueue.main.async {
            self.viewTapped()
        }
    }
}

extension RYPresenter: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view,
            let shareBoard = shareBoard, touchView.isDescendant(of: shareBoard) {
            return false
        }
        return true
    }
}
