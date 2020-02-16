//
//  AGAudioPlayer.swift
//  Carassist
//
//  Created by DerekYuYi on 2019/12/22.
//  Copyright © 2019 szyundong. All rights reserved.
//


import AVKit

@objc enum eAGAudioPlayType: Int {
    case track
    case live
}

@objc enum eAGAudioPlayMode: Int {
    case list // 列表
    case single // 单曲
    case random // 随机
    case cycle // 列表循环
}

protocol AGAudioPlayerDelegate: NSObjectProtocol {
    
    func audioPlayNotifyProcess(_ percent: CGFloat, currentSecond second: UInt)
    func audioPlayerWillPlaying()
    func audioPlayerDidStart()
    func audioPlayerDidEnd()
    func audioPlayerDidPaused()
    func audioPlayerDidStopped()
    func audioPlayerDidExit() // delegate method for speech
       
    func audioPlayerPlayPrevious()
    func audioPlayerPlayNext()
    func audioPlayerModeDidChanged(_ mode: eAGAudioPlayMode)
    func audioPlayerDidFailed(_ error: Any?)
}

extension AGAudioPlayerDelegate {
    
    func audioPlayNotifyProcess(_ percent: CGFloat, currentSecond second: UInt) {}
    func audioPlayerWillPlaying() {}
    func audioPlayerDidStart() {}
    func audioPlayerDidEnd() {}
    func audioPlayerDidPaused() {}
    func audioPlayerDidStopped() {}
    func audioPlayerDidExit() {}// delegate method for speech
       
    func audioPlayerPlayPrevious() {}
    func audioPlayerPlayNext() {}
    func audioPlayerModeDidChanged(_ mode: eAGAudioPlayMode) {}
    func audioPlayerDidFailed(_ error: Error?) {}
}

@objc class AGAudioPlayer: NSObject {
    
    @objc static let shared = AGAudioPlayer()
    
    // MARK: Inter Properties
    
    fileprivate var player: AVPlayer? = AVPlayer(playerItem: nil)
    fileprivate var currentPlayerItem: AVPlayerItem?
    
    fileprivate var timeObserverToken: Any?
    
    fileprivate var totalDuration: Int = 0
    
    fileprivate var currentAudioIndex: Int = 0
    fileprivate var currentPlayerItemDidFinishPlay = false
    
    fileprivate let lock = NSLock()
    
    // MARK: Public Properties
    
    /// Current play item.
    var audio: AGAudioItem? {
        didSet {
            guard let audio = audio else { return }
            DispatchQueue.global().async {
                self.setupCurrentPlayerItem(audio)
            }
//            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
//                self.setupCurrentPlayerItem(audio)
//            }
        }
    }
    
    /// Data source.
    var audioList: [AGAudioItem] = [] {
        didSet {
            guard audioList.count > 0 else { return }
            /// if not specify current audio to play, assign it with the first item.
            if audio == nil { audio = audioList[0] }
        }
    }
    
    @objc var playMode: eAGAudioPlayMode = .list {
        didSet {
            delegate?.audioPlayerModeDidChanged(playMode)
        }
    }
    @objc var playType: eAGAudioPlayType = .track
    
    weak var delegate: AGAudioPlayerDelegate?
    
    @objc var hasValidResourcesToPlay: Bool {
        return audioList.count > 0
    }
    
    @objc var isDisplayAtAudioPlayerPage = false
    @objc weak var audioPlayerPage: AGAudioPlayerPage?
    
    /// A boolean indicates that wheather the audio data source is come from speech wake up. Default is false.
    @objc var isPlayFromSpeechSource: Bool = false
    
    @objc var isPlaying: Bool {
        return player?.rate == 1.0
    }
    
    // MARK: Init
    
    private override init() {
        super.init()
        /// Setup AVPlayer, and only setup once.
        DispatchQueue.global().async {
            self.setupPlayer()
        }
    }
    
    func clearDataSources() {
        audio = nil
        audioList = []
        isDisplayAtAudioPlayerPage = false
        audioPlayerPage = nil
        isPlayFromSpeechSource = false
        delegate = nil
        
        resetPlayer()
        resetPlayerItem()
    }
    
    /// When set data source for `shared`, call this method.
    fileprivate func setupPlayer() {
        // 1. add periodic time observer
        // Invoke callback every second
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: mainQueue,
            using: {[weak self] time in
                guard let strongSelf = self else { return }
                
                let currentTime = UInt(CMTimeGetSeconds(time))
                
                if currentTime == 1 {
                    DispatchQueue.main.async {
                        strongSelf.delegate?.audioPlayerDidStart()
                    }
                }
                
                if strongSelf.totalDuration > 0 {
                    let percent = CGFloat(currentTime) / CGFloat(strongSelf.totalDuration)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.audioPlayNotifyProcess(percent, currentSecond: currentTime)
                    }
                    
                    if percent == 1.0 && !strongSelf.currentPlayerItemDidFinishPlay {
                        strongSelf.delegate?.audioPlayerDidEnd()
                        strongSelf.playNextWhenPlayerFinished()
                        strongSelf.currentPlayerItemDidFinishPlay = true
                    }
                } else { // almost the current play type is `.Live`.
                    DispatchQueue.main.async {
                        strongSelf.delegate?.audioPlayNotifyProcess(0, currentSecond: currentTime)
                    }
                }
        })
    }
    
    fileprivate func playNextWhenPlayerFinished() {
        switch playMode {
        case .list: // play with current order
            playNext()
            
        case .single:
            /// Call didSet of `audio` and recreate playerItem
            audio = audioList[currentAudioIndex]
            play()
            
        case .random:
            currentAudioIndex = Int.random(in: 0..<audioList.count)
            audio = audioList[currentAudioIndex]
            player?.play()
            
        default:
            break
        }
    }
    
    fileprivate func setupCurrentPlayerItem(_ audio: AGAudioItem) {
        
        /// Reset before create a new AVPlayerItem.
        resetPlayerItem()
        
        guard let url = URL(string: audio.playUrlString) else {
            delegate?.audioPlayerDidFailed("暂未提供播放地址~")
            return
        }
        
        /// Create a new AVPlayerItem and assign to player.
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        currentPlayerItem = playerItem
        
        /// Init totalDuration.
        let value = TimeInterval(playerItem.asset.duration.value)
        let timescale = TimeInterval(playerItem.asset.duration.timescale)
        if value != 0 && timescale != 0 {
            totalDuration = Int(value / timescale)
            
            if let currentAudio = self.audio, currentAudio.duration == 0 {
                currentAudio.duration = totalDuration
            }
            
        }
        
        /// Add observer for `status`.
        playerItem.addObserver(self, forKeyPath: Constants.kObserverKeyPathForPlayerStatus, options: .new, context: nil)
    }
    
    fileprivate func resetPlayer() {
        player?.pause()
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    fileprivate func resetPlayerItem() {
        totalDuration = 0
        currentPlayerItemDidFinishPlay = false
        currentPlayerItem?.removeObserver(self, forKeyPath: Constants.kObserverKeyPathForPlayerStatus, context: nil)
        currentPlayerItem = nil
        player?.replaceCurrentItem(with: nil)
    }
    
    // MARK: - Observers
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let keyPath = keyPath, keyPath == Constants.kObserverKeyPathForPlayerStatus {
            if let change = change {
                if let isReadyForPlay = change[.newKey] as? Int, isReadyForPlay == 1 {
                    if let status = AVPlayer.Status(rawValue: isReadyForPlay) {
                        switch status {
                        case .readyToPlay:
                            delegate?.audioPlayerWillPlaying()
                        case .failed:
                            delegate?.audioPlayerDidFailed(nil)
                        
                        case .unknown:
                            delegate?.audioPlayerDidFailed(nil)
                            
                        default: delegate?.audioPlayerDidFailed(nil)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Player logic

extension AGAudioPlayer {
    
    /// Play audios, live, or programs.
    @objc func play() {
        guard hasValidResourcesToPlay else { return }
        DispatchQueue.global().async {
            if self.player == nil {
                self.setupPlayer()
            }
            self.player?.play()
        }
    }
    
    /// Play audio.
    @objc func play(_ audio: AGAudioItem, at audioList: [AGAudioItem]) {
        self.audio = audio
        self.audioList = audioList
        lock.lock()
        if let index = audioList.firstIndex(of: audio) {
            currentAudioIndex = index
        }
        lock.unlock()
        play()
    }
    
    /// Pause audios, live, or programs.
    @objc func pause() {
        guard hasValidResourcesToPlay else { return }
        player?.pause()
        delegate?.audioPlayerDidPaused()
    }
    
    @objc func resume() {
        guard hasValidResourcesToPlay else { return }
        player?.play()
//        delegate?.audioPlayerWillPlaying()
        delegate?.audioPlayerDidStart()
    }
    
    @objc func stop() {
        guard hasValidResourcesToPlay else { return }
        player?.pause()
        resetPlayerItem()
        delegate?.audioPlayerDidStopped()
    }
    
    @objc func playPrevious() {
        guard hasValidResourcesToPlay && hasPrevious() else {
            delegate?.audioPlayerPlayPrevious()
            return
        }
        lock.lock()
        currentAudioIndex -= 1
        audio = audioList[currentAudioIndex]
        lock.unlock()
        player?.play()
        delegate?.audioPlayerPlayPrevious()
    }
    
    @objc func playNext() {
        guard hasValidResourcesToPlay && hasNext() else {
            delegate?.audioPlayerPlayNext()
            return
        }
        lock.lock()
        currentAudioIndex += 1
        audio = audioList[currentAudioIndex]
        lock.unlock()
//        player?.play()
        play()
        delegate?.audioPlayerPlayNext()
    }
    
    func hasPrevious() -> Bool {
        guard audioList.count > 1 && currentAudioIndex != 0 else {
            return false
        }
        return true
    }
    
    func hasNext() -> Bool {
        guard audioList.count > 1 && currentAudioIndex != (audioList.count - 1) else {
            return false
        }
        return true
    }
    
    @objc func exit() {
        delegate?.audioPlayerDidExit()
    }
    
    func seek(to time: CGFloat) {
        guard hasValidResourcesToPlay else { return }
        let seekTime = CMTime(seconds: Double(time), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: seekTime)
    }
}


// MARK: - Audio item for Player

@objc class AGAudioItem: NSObject {
    
    var audioId: String = ""
    var coverUrlString: String = ""
    var playUrlString: String = ""
    var author: String = ""
    var title: String = ""
    var intro: String = ""
    var duration: Int = 0
    
    @objc init(_ dictionary: [String: AnyHashable]) {
        super.init()
        if let audioId = dictionary["audioId"] as? String {
            self.audioId = audioId
        }
        
        if let coverUrlString = dictionary["coverUrlString"] as? String {
            self.coverUrlString = coverUrlString
        }
        
        if let playUrlString = dictionary["playUrlString"] as? String {
            self.playUrlString = playUrlString
        }
        
        if let author = dictionary["author"] as? String {
            self.author = author
        }
        
        if let title = dictionary["title"] as? String {
            self.title = title
        }
        
        if let intro = dictionary["intro"] as? String {
            self.intro = intro
        }
        
        if let duration = dictionary["duration"] as? Int {
            self.duration = duration
        }
    }
}
