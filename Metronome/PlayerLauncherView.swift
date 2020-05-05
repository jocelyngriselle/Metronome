//
//  PlayerLauncherView.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 29/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

struct PlayerLauncherView: View {
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
                    Text(String(format: "LBPM: %.0f", self.bpm))
                        .font(.headline)
                        .fontWeight(.black)
                    Slider(value: self.$bpm, in: self.musicalGenre.minBpm...self.musicalGenre.maxBpm, step: 1.0)
                    .onAppear() {
                        self.bpm = self.musicalGenre.bpm
                    }
                }.frame(width: geometry.size.width * 2 / 3)
                Button(
                    action: {
                        withAnimation{
                            self.onPlay()
                        }
                },
                    label: {AudioButton(name: "play.circle", small:false)}
                ).frame(height: 48)
            }
        }.frame( height: 100, alignment: Alignment.center)
    }
}

struct PlayerLauncherView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return PlayerLauncherView(musicalGenre: musicalGenre).environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}
