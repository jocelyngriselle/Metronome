//
//  MusicalGenreList.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

struct MusicalGenreList: View {
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        List {
            Toggle(isOn: $userData.showFavoritesOnly) {
                Text("Show Favorites Only")
            }
            
            ForEach(userData.musicalGenres) { musicalGenre in
                if !self.userData.showFavoritesOnly || musicalGenre.isFavorite {
                    NavigationLink(
                        destination: MusicalGenreDetail(musicalGenre: musicalGenre)
                            .environmentObject(self.userData)
                    ) {
                        MusicalGenreRow(musicalGenre: musicalGenre)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Musical Genres"))
    }
}

struct MusicalGenresList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            NavigationView {
                MusicalGenreList()
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
        .environmentObject(UserData())
    }
}
