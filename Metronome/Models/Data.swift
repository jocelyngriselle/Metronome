//
//  Data.swift
//  Metronome
//
//  Created by Jocelyn Griselle on 25/04/2020.
//  Copyright © 2020 Jocelyn Griselle. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI
import AVFoundation

let musicalGenreData: [MusicalGenre] = load("musicalGenreData.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

final class ImageStore {
    typealias _ImageDictionary = [String: CGImage]
    fileprivate var images: _ImageDictionary = [:]

    fileprivate static var scale = 2
    
    static var shared = ImageStore()
    
    func image(name: String) -> Image {
        let index = _guaranteeImage(name: name)
        
        return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(name))
    }

    static func loadImage(name: String) -> CGImage {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }
    
    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
        if let index = images.index(forKey: name) { return index }
        
        images[name] = ImageStore.loadImage(name: name)
        return images.index(forKey: name)!
    }
}

//final class LoopStore {
//    typealias _LoopDictionary = [String: AVAudioFile]
//    fileprivate var loops: _LoopDictionary = [:]
//
//    
//    static var shared = LoopStore()
//    
//    func loop(name: String) -> AVAudioFile {
//        let index = _guaranteeLoop(name: name)
//        
//        return loops.values[index]
//    }
//
//    static func loadLoop(name: String) -> AVAudioFile {
//        guard
//            let url = Bundle.main.url(forResource: name, withExtension: "wav")
//        else {
//            fatalError("Couldn't load loop \(name).wav from main bundle.")
//        }
//        do {
//            let loop = try AVAudioFile(forReading: url)
//            }
//        catch {
//            fatalError("Couldn't convert loop \(name).wav from main bundle.")
//        }
//        return loop
//    }
//    
//    fileprivate func _guaranteeLoop(name: String) -> _LoopDictionary.Index {
//        if let index = loops.index(forKey: name) { return index }
//        
//        loops[name] = LoopStore.loadLoop(name: name)
//        return loops.index(forKey: name)!
//    }
//}


