//
//  File.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 27/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import AVFoundation
import SwiftUI
import MediaPlayer

class MusicalGenreAudioPlayer : ObservableObject {
    @Published var genre : MusicalGenre
    @Published var isPlaying : Bool
    @Published var isRunning : Bool
    @Published var bpm : Float
    private var engine : AVAudioEngine
    private var speedControl : AVAudioUnitVarispeed
    private var pitchControl : AVAudioUnitTimePitch
    private var playerNode : AVAudioPlayerNode
    private var userData: UserData
    
    init(genre: MusicalGenre) {
        self.userData = UserData()
        self.genre = genre
        self.bpm = genre.bpm
        self.isPlaying = false
        self.isRunning = false
        self.engine = AVAudioEngine()
        self.speedControl = AVAudioUnitVarispeed()
        self.pitchControl = AVAudioUnitTimePitch()
        self.playerNode = AVAudioPlayerNode()
        connect()
        setupRemoteTransportControls()
        start() // should not be in init
    }
    
    func connect() {
        // connect the components to our playback engine
        engine.attach(playerNode)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        // arrange the parts so that output from one is input to another
        engine.connect(playerNode, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
    }
    
    func loadAudioFile() {
        let audioFormat = genre.loop.processingFormat
        let audioFrameCount = UInt32(self.genre.loop.length)
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        try? genre.loop.read(into: audioFileBuffer!)
        playerNode.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: nil)
        playerNode.scheduleFile(genre.loop, at:nil)
    }
    
    func changeMusicalGenre(genre: MusicalGenre) {
        stop()
        self.genre = genre
        start()
        play()
    }
    
    func start() {
        try? engine.start()
        isRunning = true
        self.loadAudioFile()
    }
    
    func play() {
        if !engine.isRunning { try? engine.start() }
        playerNode.play()
        isPlaying = true
        setupNowPlaying(playing: true)
    }
    
    func pause() {
        setupNowPlaying(playing: false)
        isPlaying = false
        playerNode.pause()
        engine.pause()
    }
    
    func next() {
        if let index = self.userData.musicalGenres.firstIndex(of: self.genre) {
            changeMusicalGenre(genre: self.userData.musicalGenres[(index+1) % self.userData.musicalGenres.count])
        }
        changeMusicalGenre(genre:self.userData.musicalGenres[0])
    }
    
    func previous() {
        if let index = self.userData.musicalGenres.firstIndex(of: self.genre) {
            changeMusicalGenre(genre: self.userData.musicalGenres[(index-1) % self.userData.musicalGenres.count])
        }
        changeMusicalGenre(genre:self.userData.musicalGenres[0])
    }
    
    func stop() {
        playerNode.stop()
        engine.stop()
        withAnimation {
            isPlaying = playerNode.isPlaying
            isRunning = engine.isRunning
        }
    }
    
    func setRate(rate : Float) {
        speedControl.rate = rate
    }
    
    func setBpm(rate : Float) {
        bpm = genre.bpm * rate
        setRate(rate :rate)
        setPitch(rate: rate)
    }
    
    func setBpm() {
        let rate = self.bpm / self.genre.bpm
        setRate(rate :rate)
        setPitch(rate: rate)
        //setupNowPlaying()
    }
    
    func setPitch(rate : Float) {
        pitchControl.pitch = -1200 * (log2(rate) / log2(2))
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        // Disable all buttons you will not use (including pause and togglePlayPause commands)
        [commandCenter.changeRepeatModeCommand, commandCenter.stopCommand, commandCenter.changeShuffleModeCommand, commandCenter.changePlaybackRateCommand, commandCenter.seekBackwardCommand, commandCenter.seekForwardCommand, commandCenter.skipBackwardCommand, commandCenter.skipForwardCommand, commandCenter.changePlaybackPositionCommand, commandCenter.ratingCommand, commandCenter.likeCommand, commandCenter.dislikeCommand, commandCenter.bookmarkCommand].forEach {
            $0.isEnabled = false
        }
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.play()
            return .success
            //return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
            //return .commandFailed
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.next()
            return .success
            //return .commandFailed
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.previous()
            return .success
            //return .commandFailed
        }
    }
    
    func elapsedPlaybackTime() -> Double {
        guard let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return 0.0
        }
        return Double(TimeInterval(playerTime.sampleTime) / playerTime.sampleRate)
    }
    
    func getArtWork() -> MPMediaItemArtwork {
        let image = UIImage(cgImage: self.genre.cgImage)
        return MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
            return image
        })
    }
    
    func setupNowPlaying(playing:Bool=false) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.genre.name
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        nowPlayingInfo[MPMediaItemPropertyArtist] = "\(Int(self.bpm)) BPM"
        nowPlayingInfo[MPMediaItemPropertyArtwork] = self.getArtWork()
//        let elapsed = elapsedPlaybackTime()
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
//        let audioNodeFileLength = AVAudioFrameCount(self.genre.loop.length)
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double(Double(audioNodeFileLength) / 44100)
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = elapsed
//            / Double(Double(audioNodeFileLength) / 44100)
//        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = NSNumber(value:1.0)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: playing ? speedControl.rate : 0.0)
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        print("PLAYING: \(playing)")
        print(nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] as Any)
        print(nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] as Any)
        print(nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] as Any
        )
        print(nowPlayingInfoCenter.playbackState.rawValue)
        print("END")
        
    }
}
