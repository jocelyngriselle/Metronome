//
//  MusicalGenreRow.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

struct MusicalGenreRow: View {
    var musicalGenre: MusicalGenre

    var body: some View {
        HStack {
            musicalGenre.image
                .resizable()
                .frame(width: 75, height: 50)
            Text(musicalGenre.name)
            Spacer()

            if musicalGenre.isFavorite {
                Image(systemName: "star.fill")
                    .imageScale(.medium)
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct MusicalGenreRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MusicalGenreRow(musicalGenre: musicalGenreData[0])
            MusicalGenreRow(musicalGenre: musicalGenreData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
