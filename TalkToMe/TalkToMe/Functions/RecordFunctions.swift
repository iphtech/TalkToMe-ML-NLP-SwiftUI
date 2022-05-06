//
//  RecordFunctions.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//

import Foundation

import Foundation
import SwiftSpeech
import Speech
import Combine
import ComposableArchitecture
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
// function to convert text to speech
func startSpeaking() {
    let utterance = AVSpeechUtterance(string: result)  //storing text to convert to speech
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")  //language for speech
    utterance.rate = 0.45  //managing speed rate of speech
    synthesizer.continueSpeaking()  //continuing new speech
    synthesizer.speak(utterance)  //converting text to speech
}
