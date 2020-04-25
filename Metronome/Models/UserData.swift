//
//  UserData.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI

final class UserData: ObservableObject {
    @Published var showFavoritesOnly = false
    @Published var musicalGenres = musicalGenreData
}
