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
            VStack(alignment: .leading) {
                ZStack {
                    self.musicalGenre.image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: geometry.size.width, maxHeight: geometry.size.height / 3)
                        .clipped()
                    Text(" \(self.musicalGenre.name) ")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                }//.frame(alignment: .top)
                Spacer()
                Text(self.musicalGenre.description)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    
                Text(self.musicalGenre.descriptionTempo)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                Spacer()
                if self.musicalGenre == self.audioPlayer.genre {
                    PlayerDetailView()
                }
                else {
                    PlayerLauncherView(musicalGenre: self.musicalGenre)
                }
                Spacer()
            }//.frame(alignment: .top)//.padding(.bottom, 62.0)
        }
    }
}






struct MusicalGenreDetail_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return Group {
                
                MusicalGenreDetail(musicalGenre: musicalGenre)
                    .navigationBarHidden(false)
                    .navigationBarTitle("", displayMode: .inline)
                
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")
            NavigationView {
                MusicalGenreDetail(musicalGenre: musicalGenre)
                .navigationBarHidden(false)
                .navigationBarTitle("", displayMode: .inline)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
            .previewDisplayName("iPhone 11 Pro Max")
        }
        .environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}


