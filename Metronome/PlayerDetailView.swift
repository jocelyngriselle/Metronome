//
//  PlayerDetailView.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 29/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

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
                HStack {
                    if self.audioPlayer.isRunning {
                    Button(
                        action: {
                            withAnimation {
                            self.audioPlayer.stop()
                            }
                        },
                        label: {
                            
                            AudioButton(name: "stop.circle", small:false)
                        }
                    ).frame(height: 48)
                    }
                    Button(
                        action: {
                            withAnimation {
                            self.audioPlayer.isPlaying ? self.audioPlayer.pause() : self.audioPlayer.play()
                            }
                        },
                        label: {
                            AudioButton(name: self.audioPlayer.isPlaying ? "pause.circle" : "play.circle", small:false)
                    }
                    ).frame(height: 48)
                }
            }
        }.frame( height: 100, alignment: Alignment.center)
    }
}

struct PlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return PlayerDetailView().environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}



