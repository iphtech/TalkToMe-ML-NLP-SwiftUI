//
//  Credentials.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//

import Foundation

struct Credentials: Codable {
    
    var isRecording: Bool = false
    var speechSession: SwiftSpeech.Session?
    var cancelBag = Set<AnyCancellable>()
    var searchQuery = "Tap to speak..."
    var result: String = ""
}
