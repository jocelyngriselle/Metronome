//
//  AudioPlayerModal.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 27/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import Foundation
import SwiftUI

struct PlayerModalView: View {
    
    @EnvironmentObject var audioPlayer: MusicalGenreAudioPlayer
    @Binding var showingDetail: Bool
    
    var body: some View {
        NavigationView {
            MusicalGenreDetail(musicalGenre: audioPlayer.genre)
                .navigationBarTitle(Text(""), displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    self.showingDetail = false
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.black)
                        .font(.system(size: 38, weight: .light))
                })
        }
    }
}
