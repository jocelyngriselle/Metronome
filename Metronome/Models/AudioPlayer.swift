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
    //private var nowPlayingInfo : [String : Any]
    
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
        setupRemoteTransportControls()
        
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
        // prepare the player to play its file from the beginning
        //playerNode.scheduleFile(genre.loop, at: nil) // TODO relevant ?
        
        let audioFormat = genre.loop.processingFormat
        let audioFrameCount = UInt32(self.genre.loop.length)
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        try? genre.loop.read(into: audioFileBuffer!)
        
//        guard let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
//            playerNode.scheduleFile(genre.loop, at:nil)
//            return
//        }
//        playerNode.scheduleFile(genre.loop, at:playerTime)
        //playerNode.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: nil)
        //setupNowPlaying()
        playerNode.scheduleFile(genre.loop, at:nil)
    }
    
    func changeMusicalGenre(genre: MusicalGenre) {
        // prepare the player to play its file from the beginning
        
        self.genre = genre
        if !engine.isRunning {
            start()
        }
        playerNode.stop()
        loadAudioFile()
        if self.isPlaying {
            play()
        }
        else {
            setupNowPlaying(playing: false, elapsedPlaybackTime: self.elapsedPlaybackTime())
        }
    }
    
    func start() {
        connect()
        try? engine.start()
        isRunning = true
        self.loadAudioFile()
    }
    
    func play() {
        if !engine.isRunning {
            start()
        }
        playerNode.play()
        isPlaying = true
        setupNowPlaying(playing: true, elapsedPlaybackTime: self.elapsedPlaybackTime())
        
    }
    
    func pause() {
        setupNowPlaying(playing: false, elapsedPlaybackTime: self.elapsedPlaybackTime())
        isPlaying = false
        playerNode.pause()
    }
    
    func nextMusicalGenre() -> MusicalGenre {
        if let index = self.userData.musicalGenres.firstIndex(of: self.genre) {
            return self.userData.musicalGenres[(index+1) % self.userData.musicalGenres.count]
        }
        return self.userData.musicalGenres[0]
    }
    
    func previousMusicalGenre() -> MusicalGenre {
        if let index = self.userData.musicalGenres.firstIndex(of: self.genre) {
            return self.userData.musicalGenres[(index-1) % self.userData.musicalGenres.count]
        }
        return self.userData.musicalGenres[0]
    }
    
    func next() {
        changeMusicalGenre(genre: self.nextMusicalGenre())
    }
    
    func previous() {
        changeMusicalGenre(genre: self.previousMusicalGenre())
    }
    
    func stop() {
        playerNode.stop()
        engine.stop()
        isPlaying = false
        isRunning = false
        withAnimation {
            isPlaying = playerNode.isPlaying
            isRunning = engine.isRunning
        }
        setupNowPlaying()
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
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        // Disable all buttons you will not use (including pause and togglePlayPause commands)
        [
            commandCenter.changeRepeatModeCommand, commandCenter.stopCommand, commandCenter.changeShuffleModeCommand, commandCenter.changePlaybackRateCommand, commandCenter.seekBackwardCommand, commandCenter.seekForwardCommand, commandCenter.skipBackwardCommand, commandCenter.skipForwardCommand, commandCenter.changePlaybackPositionCommand, commandCenter.ratingCommand, commandCenter.likeCommand, commandCenter.dislikeCommand, commandCenter.bookmarkCommand].forEach {
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
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
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
    
    func setupNowPlaying(playing:Bool=false, elapsedPlaybackTime:Double=0.0) {
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.genre.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = "\(Int(self.bpm)) BPM"
        let image = UIImage(cgImage: self.genre.cgImage)
        nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                return image
            })
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
        
        
        let audioNodeFileLength = AVAudioFrameCount(self.genre.loop.length)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double(Double(audioNodeFileLength) / 44100)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = elapsedPlaybackTime / Double(Double(audioNodeFileLength) / 44100)

        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playing ? speedControl.rate : 0.0
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        nowPlayingInfoCenter.playbackState = playing ? .playing : .paused
        
        NSLog("%@", "**** Set playback info: rate \(String(describing: nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate])), genre \(String(describing: nowPlayingInfo[MPMediaItemPropertyTitle]))")
        
    }
}
