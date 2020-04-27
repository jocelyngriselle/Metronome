//
//  MusicalGenreDetail.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI


struct MusicalGenreDetail: View {
    var musicalGenre: MusicalGenre
    @EnvironmentObject var audioPlayer: MusicalGenreAudioPlayer
    
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
                if self.musicalGenre == self.audioPlayer.genre {
                    PlayerDetailView()
                }
                else {
                    PlayerLancherView(musicalGenre: self.musicalGenre)
                }
                Spacer()
            }.frame(width: geometry.size.width, alignment: Alignment.top)
        }.frame(maxHeight: .infinity).frame(maxHeight: .infinity)
    }
}






struct MusicalGenreDetail_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return MusicalGenreDetail(musicalGenre: musicalGenre).environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}
