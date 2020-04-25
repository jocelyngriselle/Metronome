//
//  MusicalGenre.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import SwiftUI
import CoreLocation
import AVFoundation


//struct MusicalGenres {
//    static let genres = [dancehall, hiphop, bosseSamba]
//    static let dancehall = MusicalGenre(imageName: "wave", name: "Dancehall", song: "dancehall_hip", bpm: 98.0)
//    static let hiphop = MusicalGenre(image: Image("wave"), name: "Hip-Hop", song: "acoustic_hiphop", bpm: 140.0)
//    static let bosseSamba = MusicalGenre(image: Image("wave"), name: "Samba", song: "bossa_samba_acoustic", bpm: 80.0)
//}

struct MusicalGenre: Hashable, Codable, Identifiable {
    var id : Int
    var name : String
    var bpm : Float
    var minBpm : Float
    var maxBpm : Float
    var description : String
    var category: Category
    fileprivate var imageName : String
    fileprivate var loopName : String
    var isFavorite: Bool
    var isFeatured: Bool
    
    enum Category: String, CaseIterable, Codable, Hashable {
        case electro = "Electro"
        case jazz = "Jazz"
        case raggae = "Raggae"
        case rock = "Rock"
        case blues = "Blues"
        case world = "World Music"
    }
}
//fileprivate var loopName : String

//    init(image: Image, name : String, song : String, bpm : Float) {
//        self.id = UUID()
//        self.image = image
//        self.name = name
//        self.song = song
//        self.bpm = bpm
//
//        if let url = Bundle.main.url(forResource: song, withExtension: "wav") {
//            do {
//                self.file = try AVAudioFile(forReading: url)
//            }
//            catch {
//                print("CAN'T READ FILE")
//                self.file = nil
//            }
//        } else {
//            self.file = nil
//            print("NOFILE")
//        }
//    }
//}
//    var loop: AVAudioFile {
//        //AVAudioFile
//        ImageStore.shared.image(name: imageName)
//    }


extension MusicalGenre {
    var image: Image {
        ImageStore.shared.image(name: imageName)
    }
}

extension MusicalGenre {
    var loop: AVAudioFile {
        //LoopStore.shared.loop(name: loopName)
        guard
            let url = Bundle.main.url(forResource: loopName, withExtension: "wav")
        else {
            fatalError("Couldn't load loop \(name).wav from main bundle.")
        }
        do {
            return try AVAudioFile(forReading: url)
            }
        catch {
            fatalError("Couldn't convert loop \(name).wav from main bundle.")
        }
    }
}
