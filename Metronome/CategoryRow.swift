//
//  CategoryRow.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var items: [MusicalGenre]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(self.items) { musicalGenre in
                        NavigationLink(
                            destination: MusicalGenreDetail(
                                musicalGenre: musicalGenre
                            )
                        ) {
                            CategoryItem(musicalGenre: musicalGenre)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

struct CategoryItem: View {
    var musicalGenre: MusicalGenre
    var body: some View {
        VStack(alignment: .leading) {
            musicalGenre.image
                .renderingMode(.original)
                .resizable()
                .frame(width: 232, height: 155)
                .cornerRadius(5)
            Text(musicalGenre.name)
                .foregroundColor(.primary)
                .font(.caption)
        }
        .padding(.leading, 15)
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(
            categoryName: musicalGenreData[0].category.rawValue,
            items: Array(musicalGenreData.prefix(4))
        )
        .environmentObject(UserData())
    }
}
