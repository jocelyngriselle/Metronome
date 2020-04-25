//
//  MusicalGenreDetail.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI
import AVFoundation

struct MusicalGenreDetail: View {
    @EnvironmentObject var userData: UserData
    var musicalGenre: MusicalGenre
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                ZStack {
                    self.musicalGenre.image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                    Text(" \(self.musicalGenre.name) ")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                }.frame(maxWidth: geometry.size.width).fixedSize()
                Text(self.musicalGenre.description)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                    .frame(width: geometry.size.width - 20)
                Text(self.musicalGenre.descriptionTempo)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(Color.black).frame(width: geometry.size.width - 20)
                BPMPlayerView(genre: self.musicalGenre)
            }.frame(width: geometry.size.width, alignment: Alignment.top)
        }.frame(maxHeight: .infinity).frame(maxHeight: .infinity)
    }
}


struct AudioButton: View {
    
    let name: String
    var body: some View {
        Image(systemName: name).resizable()
            .frame(width: 60.0, height: 60.0)
            .foregroundColor(.black)
    }
    
}

struct BPMPlayerView: View {
    
    let genre : MusicalGenre
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    let audioPlayer = AVAudioPlayerNode()
    @State private var rate: Float = 1.0
    @State private var pitch: Float = 0.0
    @State private var isPlaying: Bool = false  // TODO autoplay at start ?
    @State private var bpm: Float = 100
    
    init(genre: MusicalGenre) {
        self.genre = genre
        _bpm = State(initialValue: self.genre.bpm) // doest work
        //self.bpm = genre.bpm
        // connect the components to our playback engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        
        // arrange the parts so that output from one is input to another
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        // prepare the player to play its file from the beginning
        audioPlayer.scheduleFile(genre.loop, at: nil)
        //try? engine.start()
        
        let audioFile = genre.loop
        let audioFormat = audioFile.processingFormat
        
        let audioFrameCount = UInt32(audioFile.length)
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        try? audioFile.read(into: audioFileBuffer!)
        
        try? engine.start()
        
        // audioPlayer.play() TODO autoplay at start ?
        audioPlayer.scheduleBuffer(audioFileBuffer!, at: nil, options:.loops, completionHandler: nil)
        
        print("PITCH")
        print(pitchControl.pitch)
    }
    
    func play() {
        isPlaying = true
        audioPlayer.play()
        //        let audioFormat = genre.file!.processingFormat
        //        let audioFrameCount = UInt32(genre.file!.length)
        //        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)!
        //        audioPlayer.scheduleBuffer(audioFileBuffer, at: nil, options:.loops, completionHandler: nil)
    }
    
    func pause() {
        //engine.pause()
        isPlaying = false
        audioPlayer.pause()
    }
    
    func stop() {
        //engine.stop()
        isPlaying = false
        audioPlayer.pause()
    }
    
    func setRate(rate : Float) {
        speedControl.rate = rate
    }
    
    func setBpm(rate : Float) {
        self.bpm = self.genre.bpm * rate
    }
    
    func setPitch(rate : Float) {
        print("NEW PITCH 1")
        print(pitchControl.pitch)
        print("RATE")
        print(rate)
        print(log2(rate) / log2(2))
        //pitchControl.pitch = -1000 * log2(rate)
        pitchControl.pitch = -1200 * (log2(rate) / log2(2))
        pitch = pitchControl.pitch
        //pitchControl.pitch = exp(rate * log2(pitchControl.pitch))
        print("NEW PITCH 2")
        print(pitchControl.pitch)
    }
    
    func onEditingChanged (changed : Bool){
        let rate = bpm / self.genre.bpm
        self.setRate(rate :rate)
        self.setBpm(rate :rate)
        self.setPitch(rate: rate)
    }
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24.0) {
                Text(String(format: "BPM: %.0f", self.bpm))
                    .font(.title)
                    .fontWeight(.black)
                    .padding(0.0)
                Slider(value: self.$bpm, in: self.genre.minBpm...self.genre.maxBpm, step: 1.0, onEditingChanged: self.onEditingChanged)
                    .frame(width: geometry.size.width - 20)
                
                //            Text(String(format: "Pitch: %.2f", pitch))
                //                .font(.title)
                //                .fontWeight(.black)
                //                .padding(0.0)
                //            Slider(value: $pitch, in: -2400...2400, step: 10.0, onEditingChanged: onEditingChanged)
                
                HStack(alignment: .bottom, spacing: 10.0) {
//                    Button(action: {
//                        self.stop()
//                    }, label: {
//                        AudioButton(name: "stop.circle")
//                    })
                    Button(action: {
                        if self.isPlaying {
                            self.pause()
                        }
                        else {
                            self.play()
                        }
                        
                    }, label: {
                        if self.isPlaying {
                            AudioButton(name: "pause.circle")
                        }
                        else {
                            AudioButton(name: "play.circle")
                        }
                    }
                    )
                }
                .frame(width: 400.0, height: 60.0)
            }.padding(.all, 45.0)
        }
    }
}

struct MusicalGenreDetail_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        return MusicalGenreDetail(musicalGenre: userData.musicalGenres[0])
            .environmentObject(userData)
    }
}
