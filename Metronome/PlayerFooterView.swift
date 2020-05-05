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








struct PlayerFooterView: View {
    
    @EnvironmentObject var audioPlayer : MusicalGenreAudioPlayer
    @State var showingDetail = false
    @State var showing = false
    
    @ViewBuilder
    var body: some View {
        if !audioPlayer.isRunning {}
        else {
            Button(action: {
                self.showingDetail.toggle()
            }) {
                PlayerHorizontalView()
            }
            .padding(.top, 0.0)
            .sheet(isPresented: $showingDetail) {
                PlayerModalView(showingDetail: self.$showingDetail)
                    .environmentObject(self.audioPlayer)
            }
            .frame(height: 66, alignment: .center ).background(Color.white)
            .transition(.offset(x:0.0, y: 60.0))
        }
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
                        Text("\(self.audioPlayer.genre.name)")
                            .font(.headline)
                            .foregroundColor(Color.black)
                            .fontWeight(.bold)
                        
                        Text("\(Int(self.audioPlayer.bpm)) BPM")
                            .font(.headline)
                            .foregroundColor(Color.black)
                            .fontWeight(.regular)
                        
                    }
                    Spacer()
                    Button(
                        action: {
                            withAnimation {
                                self.audioPlayer.stop()
                            }
                        },
                        label: {AudioButton(name: "stop.circle")}
                    )
                    Button(
                        action: {
                            withAnimation {
                            self.audioPlayer.isPlaying ?
                                self.audioPlayer.pause() : self.audioPlayer.play()
                            }
                        },
                        label: {
                            AudioButton(name: self.audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                        }
                    ).padding(.trailing, 20.0)
                }
                Divider()
            }
        }.frame(height: 60, alignment: .center).background(Color(UIColor.systemGray6))
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
