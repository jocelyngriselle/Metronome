//
//  File.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 27/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import AVFoundation


class MusicalGenreAudioPlayer : ObservableObject {
    @Published var genre : MusicalGenre
    @Published var isPlaying : Bool
    @Published var bpm : Float
    private var engine : AVAudioEngine
    private var speedControl : AVAudioUnitVarispeed
    private var pitchControl : AVAudioUnitTimePitch
    private var playerNode : AVAudioPlayerNode
    
    init(genre: MusicalGenre) {
        self.genre = genre
        self.bpm = genre.bpm
        self.isPlaying = false
        self.engine = AVAudioEngine()
        self.speedControl = AVAudioUnitVarispeed()
        self.pitchControl = AVAudioUnitTimePitch()
        self.playerNode = AVAudioPlayerNode()
        self.connect()
        self.loadAudioFile()
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
        
        // starting the engine
        try? engine.start()
    }
    
    func loadAudioFile() {
        // prepare the player to play its file from the beginning
        //playerNode.scheduleFile(genre.loop, at: nil) // TODO relevant ?
        
        let audioFormat = genre.loop.processingFormat
        let audioFrameCount = UInt32(self.genre.loop.length)
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        try? genre.loop.read(into: audioFileBuffer!)
        playerNode.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: nil)
    }
    
    func changeMusicalGenre(genre: MusicalGenre) {
        // prepare the player to play its file from the beginning
        stop()
        self.genre = genre
        loadAudioFile()
    }
    
    func play() {
        isPlaying = true
        playerNode.play()
    }
    
    func pause() {
        //engine.pause()
        isPlaying = false
        playerNode.pause()
    }
    
    func stop() {
        //engine.stop()
        isPlaying = false
        playerNode.stop()
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
    }
    
    func setPitch(rate : Float) {
        //pitchControl.pitch = -1000 * log2(rate)
        pitchControl.pitch = -1200 * (log2(rate) / log2(2))
        //pitchControl.pitch = exp(rate * log2(pitchControl.pitch))
    }
}
