//
//  AudioPlayer.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 26/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI
import Foundation


struct AudioButton: View {
    
    var name: String
    var small: Bool = true
    var body: some View {
        Image(systemName: name)
            .foregroundColor(.black)
            .font(.system(size: small ? 36 : 48, weight: .ultraLight))
    }
}


struct PlayerLancherView: View {
    var musicalGenre: MusicalGenre
    @EnvironmentObject var audioPlayer: MusicalGenreAudioPlayer
    @State private var bpm: Float = 0
    
    func onPlay (){
        self.audioPlayer.changeMusicalGenre(genre: self.musicalGenre)
        let rate = bpm / self.audioPlayer.genre.bpm
        self.audioPlayer.setBpm(rate :rate)
        self.audioPlayer.play()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack() {
                    Text(String(format: "LANCHER BPM: %.0f", self.bpm))
                        .font(.headline)
                        .fontWeight(.black)
                    Slider(value: self.$bpm, in: self.musicalGenre.minBpm...self.musicalGenre.maxBpm, step: 1.0)
                    .onAppear() {
                        self.bpm = self.musicalGenre.bpm
                    }
                }.frame(width: geometry.size.width * 2 / 3)
                Button(
                    action: {self.onPlay()},
                    label: {AudioButton(name: "play.circle", small:false)}
                )
                Spacer()
            }.frame(width: geometry.size.width, alignment: Alignment.top)
        }.frame(maxHeight: .infinity).frame(maxHeight: .infinity)
    }
}

struct PlayerDetailView: View {
    @EnvironmentObject var audioPlayer: MusicalGenreAudioPlayer
    
    func setBpm(changed: Bool) {
        audioPlayer.setBpm()
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack() {
                    Text(String(format: "BPM: %.0f", self.audioPlayer.bpm))
                        .font(.headline)
                        .fontWeight(.black)
                    Slider(value: self.$audioPlayer.bpm, in: self.audioPlayer.genre.minBpm...self.audioPlayer.genre.maxBpm, step: 1.0, onEditingChanged: self.setBpm)
                }.frame(width: geometry.size.width * 2 / 3)
                Button(
                    action: {
                        self.audioPlayer.isPlaying ? self.audioPlayer.pause() : self.audioPlayer.play()
                },
                    label: {
                        AudioButton(name: self.audioPlayer.isPlaying ? "pause.circle" : "play.circle", small:false)
                }
                )
                Spacer()
            }.frame(width: geometry.size.width, alignment: Alignment.top)
        }.frame(maxHeight: .infinity).frame(maxHeight: .infinity)
    }
}





struct PlayerFooterView: View {
    
    @EnvironmentObject var audioPlayer : MusicalGenreAudioPlayer
    @State var showingDetail = false
    
    @ViewBuilder
    var body: some View {
        Button(action: {
            self.showingDetail.toggle()
        }) {
            PlayerHorizontalView()
        }.sheet(isPresented: $showingDetail) {
            PlayerModalView(showingDetail: self.$showingDetail)
                .environmentObject(self.audioPlayer)
        }
        .frame(height: 62, alignment: .center ).background(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/.opacity(0.0))
    }
}


struct PlayerHorizontalView: View {
    
    @EnvironmentObject var audioPlayer : MusicalGenreAudioPlayer
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0.0) {
                Divider()
                    .padding(.bottom, 0.0)
                HStack(alignment: .center, spacing: 20.0) {
                    self.audioPlayer.genre.image.resizable()
                        .renderingMode(.original)
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                    
                    VStack(alignment: .leading) {
                        Text(self.audioPlayer.genre.name)
                            .font(.headline)
                            .foregroundColor(Color.black)
                            .fontWeight(.bold)
                        
                        Text(String(format: "BPM: %.0f", self.audioPlayer.bpm))
                            .font(.headline)
                            .foregroundColor(Color.black)
                            .fontWeight(.regular)
                        
                    }
                    Spacer()
                    Button(
                        action: {
                            self.audioPlayer.isPlaying ?
                                self.audioPlayer.pause() : self.audioPlayer.play()
                    },
                        label: {
                            AudioButton(name: self.audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                    }
                    )
                        .padding(.trailing, 20.0)
                }
            }
        }.frame(height: 60, alignment: .center )
    }
}




struct AudioPlayer_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return VStack {
            Spacer()
            PlayerFooterView()
        }.environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}
