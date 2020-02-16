//
//  RYSkillDetailsVideoCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import AVFoundation

protocol RYSkillDetailsVideoCellDelegate: NSObjectProtocol {
    func fullScreenButtonTapped()
}

class RYSkillDetailsVideoCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var loadedProgressView: UIProgressView!
    weak var delegate: RYSkillDetailsVideoCellDelegate?
    
    // video related
    private var playerItem: AVPlayerItem?
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var isSliding = false // Indicates if `videoSlider` is sliding.
    var isPlaying = false { // Indicates if the currentItem is playing.
        didSet {
            if isPlaying {
                startButton.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                startButton.setImage(UIImage(named: "play"), for: .normal)
            }
        }
    }
    
    var updateDisplayLink: CADisplayLink? {
        get {
            return CADisplayLink(target: self, selector: #selector(updatePlayTime))
        }
        set {
        }
    }

    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bottomContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        startTimeLabel.text = "00:00"
        fullScreenButton.setImage(UIImage(named: "fullscreen"), for: .normal)
        
        playSlider.minimumTrackTintColor = RYColors.yellow_theme
        playSlider.maximumTrackTintColor = RYColors.color(from: 0xdedede).withAlphaComponent(0.2)
        
        playSlider.value = 0.0
        isPlaying = false
        
        loadedProgressView.tintColor = .white
        loadedProgressView.progress = 0.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.bounds.width
        let height = width / (16.0/9.0)
        playerLayer?.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func update(_ data: RYSkillDetailsModel) {
        
        if let title = data.title {
            titleLabel.text = title
        }
        
        if let endingTime = data.playTime {
            endingTimeLabel.text = endingTime
        }
        
        if let videoUrlString = data.videoUrlString {
            setupPlayer(videoUrlString)
        }
    }
    
    // MARK: - Touch events
    
    /// start button action
    @IBAction func startButtonTapped(_ sender: UIButton) {
        isPlaying = !isPlaying
        
        if isPlaying {
            if videoPlayer?.status == .readyToPlay {
                videoPlayer?.play()
            }
        } else {
            videoPlayer?.pause()
        }
    }
    
    /// full screen button action
    @IBAction func fullScreenButtonTapped(_ sender: Any) {
        delegate?.fullScreenButtonTapped()
    }
    
    // slider action (TouchDown, TouchCancel, TouchUpInside, TouchUpOutside)
    @IBAction func sliderTouchDown(_ sender: Any) {
        isSliding = true
    }
    
    @IBAction func sliderTouchCancel(_ sender: Any) {
        sliderTouchUpOut()
    }
    
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
        sliderTouchUpOut()
    }
    
    @IBAction func sliderTouchUpOutside(_ sender: Any) {
        sliderTouchUpOut()
    }
    
    private func sliderTouchUpOut() {
        guard let videoPlayer = videoPlayer, let playerItem = playerItem else { return }
        if videoPlayer.status == .readyToPlay {
            let duration = playSlider.value * Float(CMTimeGetSeconds(playerItem.duration))
            if duration.isNaN {
                isSliding = false
                return
            }
            let seekTime = CMTime(value: CMTimeValue(duration), timescale: 1)
            // seek to video location
            videoPlayer.seek(to: seekTime) {[weak self] isFinished in
                // update sliding status
                self?.isSliding = false
            }
        }
    }
}

/// Video Logic
extension RYSkillDetailsVideoCell {
    
    /// Setup player, playerItem, playerLayer
    /// - Parameter videoLinkString: The url string to play video.
    private func setupPlayer(_ videoLinkString: String) {
        guard let videoUrl = URL(string: videoLinkString) else { return }
        
        // playerItem
        let playerItem = AVPlayerItem(url: videoUrl)
        self.playerItem = playerItem
        // add observer
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        
        // player
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        // player layer
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity  = .resizeAspectFill
        playerLayer.contentsScale = UIScreen.main.scale
        containerView.layer.insertSublayer(playerLayer, at: 0)
        self.playerLayer = playerLayer
        
        // displaylink
        updateDisplayLink?.add(to: RunLoop.main, forMode: .default)
    }
    
    /// Remove resources about player
    func invalidatePlayer() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        
        videoPlayer?.pause()
        playerItem = nil
        videoPlayer = nil
        playerLayer?.removeFromSuperlayer()
        
        updateDisplayLink = nil
    }
    
    func updatePlayerLayerFrame() {
        self.playerLayer?.frame = containerView.bounds
//        let width = contentView.bounds.width
//        let height = width / (16.0/9.0)
//        playerLayer?.frame = CGRect(x: 0, y: 23, width: width, height: height - 40)
    }
    
    /// Customize time format for show
    private func formatPlayTime(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let minute = Int(seconds / 60)
        let second = Int(seconds) % 60
        return String(format: "%02d:%02d", minute, second)
    }
    
    // MARK: - CADisplayLink Selector
    @objc private func updatePlayTime() {
        guard let videoPlayer = videoPlayer, let playerItem = playerItem, isPlaying else { return }
        
        let currentTime = CMTimeGetSeconds(videoPlayer.currentTime())
        let totalTime = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        
        // update currentTime to label text
        let timeStr = "\(formatPlayTime(currentTime))"
        startTimeLabel.text = timeStr
        
        // update slider value
        if !isSliding {
            playSlider.value = Float(currentTime / totalTime)
        }
    }
    
    /// Get loaded time duration
    private func availableDurationForPlayerItem() -> TimeInterval {
        guard let playerItem = playerItem, let loadedTimeRange = playerItem.loadedTimeRanges.first else { return 0.0 }
        let timeRange = loadedTimeRange.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecond = CMTimeGetSeconds(timeRange.duration)
        return startSeconds + durationSecond
    }
    
    // Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem {
            if let keypath = keyPath, keypath == "status" {
                
            }
            if let keypath = keyPath, keypath == "loadedTimeRanges" {
                let loadedTime = availableDurationForPlayerItem()
                let totalTime = CMTimeGetSeconds(playerItem.duration)
                let percent = loadedTime / totalTime
                // update progress value
                loadedProgressView.progress = Float(percent)
            } else {
                
            }
        }
    }
}
