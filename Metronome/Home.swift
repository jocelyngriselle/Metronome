//
//  MusicalGenre.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

struct CategoryHome: View {
    
    var categories: [String: [MusicalGenre]] {
        Dictionary(
            grouping: musicalGenreData,
            by: { $0.category.rawValue }
        )
    }
    var featured: [MusicalGenre] {
        musicalGenreData.filter { $0.isFeatured }
    }
    
    @State var showingProfile = false
    
    var profileButton: some View {
        Button(action: { self.showingProfile.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 0){
                NavigationView {
                    List {
                        FeaturedMusicalGenres(musicalGenres: self.featured)
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .listRowInsets(EdgeInsets())
                        
                        ForEach(self.categories.keys.sorted(), id: \.self) { key in
                            CategoryRow(categoryName: key, items: self.categories[key]!)
                        }
                        .listRowInsets(EdgeInsets())
                        
                        NavigationLink(destination: MusicalGenreList()) {
                            Text("See All")
                        }
                    }
                    .navigationBarTitle(Text("Pick your style"))
                    .navigationBarItems(trailing: self.profileButton)
                    .sheet(isPresented: self.$showingProfile) {
                        Text("User Profile")
                    }
                    //MusicalGenreAudioPlayerFooterView()
                }
                PlayerFooterView()
            }.frame( alignment: .top)
        }
    }
}

struct FeaturedMusicalGenres: View {
    var musicalGenres: [MusicalGenre]
    var body: some View {
        //NavigationLink(destination: MusicalGenreDetail(musicalGenre: musicalGenres[0])) {
            musicalGenres[0].image.resizable()
        //}
    }
}

struct CategoryHome_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        let musicalGenre = userData.musicalGenres[0]
        return Group {
            CategoryHome()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            CategoryHome()
            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
            .previewDisplayName("iPhone 11 Pro Max")
        }
        .environmentObject(UserData())
        .environmentObject(MusicalGenreAudioPlayer(genre: musicalGenre))
    }
}
