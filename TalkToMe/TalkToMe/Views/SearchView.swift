//
//  SearchView.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//

import SwiftUI
import Speech
import SwiftSpeech
import Combine
import ComposableArchitecture
import AVFoundation



var result: String = ""


struct SearchView: View {
    
//MARK:- Properties
    
    @State var isRecording: Bool = false
    @State private var speechSession: SwiftSpeech.Session?
    @State private var cancelBag = Set<AnyCancellable>()
    @State var searchQuery = "Tap to speak..."
    let defaultAnimation: Animation = .interactiveSpring()
    let mlmodel = Classifiers()
    var start =  Color(#colorLiteral(red: 0.1429229878, green: 0.8067259491, blue: 1, alpha: 1))
    var end =  Color(#colorLiteral(red: 0.07115641946, green: 0.2028132513, blue: 0.5977793992, alpha: 1))
    
//MARK:- Body
    
    var body: some View {
        
        ZStack {
            VStack {
                VStack {
                    Spacer()
                    
                    queryText
                    
                    modelOutput
                    
                }.padding(.horizontal, 20)   //VSTACK
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)   //frame for gradient color above arc
                .background(LinearGradient(gradient: Gradient(colors: [start, end]), startPoint: .top, endPoint: .bottom))   //gradient color
                .edgesIgnoringSafeArea(.horizontal)
                
                VStack {
                    ZStack {
                        ArcView(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true) //drawing arc by passing start angle and end angle
                            .fill(Color.white)
                            .frame(width: 500 , height: 10)
                        
                            Image("mic")  //display microphone image
                                .resizable()
                                .frame(width:40, height: 40, alignment: .center)
                                .font(.system(size: 35, weight: .semibold, design: .serif))
                                .opacity(self.isRecording ? 0.7 : 1.0)
                                .padding(7)
                                .background(self.isRecording ? Color.blue : Color.white)
                                .clipShape(Circle())
                                .scaleEffect(self.isRecording ? 1.8 : 1.0)
                                .shadow(radius: 20)
                                .overlay(Circle().stroke(Color.white, lineWidth: 5))
                                .gesture(self.gesture)
                                .offset(y: -115)
                    }   //ZSTACK
                }  //VSTACK
            }.padding(20)  //VSTACK
        } //ZSTACK
    }  //BODY

    //MARK:- Gesture
    
    //define type of gesture for mic button
        var gesture: some Gesture {
            
            let longPress = LongPressGesture(minimumDuration: 60)  //defining long press gesture
                .onChanged { _ in
                    withAnimation(self.defaultAnimation) {
                        self.isRecording = true    //start recording on long press
                        self.searchQuery = "Tap to speak..."
                        result = ""
            
                //start recording if permission granted for recording
                        if SFSpeechRecognizer.authorizationStatus() == .authorized {
                            if synthesizer.isSpeaking {
                                synthesizer.stopSpeaking(at: .immediate)   //stopping previous speech on new recording
                            }
                            startListening()
                        } else {
                //request for permission for recording
                            SFSpeechRecognizer.requestAuthorization { _ in
                                if synthesizer.isSpeaking {
                                    synthesizer.stopSpeaking(at: .immediate)  //stopping previous speech on new recording
                                }
                                startListening()
                            }
                        }
                    }
                }
            
            let drag = DragGesture(minimumDistance: 0) //defining drag gesture for stop recording
                .onEnded { value in
                    if value.translation.height < -20.0 {
                        withAnimation(self.defaultAnimation) {
                            self.isRecording = false
                            result = mlmodel.classifyAction(for: searchQuery) //evaluating result from model for the searched query
                            startSpeaking() //converting text result into speech
                        }
                    } else {
                        withAnimation(self.defaultAnimation) {
                            self.isRecording = false
                            result = mlmodel.classifyAction(for: searchQuery)  //evaluating result from model for the searched query
                            startSpeaking() //converting text result into speech
                        }
                        
                    }
                }
            return longPress.simultaneously(with: drag)
        } //GESTURE
    
//function to convert speech to text
    func startListening() {
        self.speechSession = SwiftSpeech.Session(configuration: SwiftSpeech.Session.Configuration(locale: Locale(identifier: "en-US"), audioSessionConfiguration: .recordOnly))  //recording voice query

        self.speechSession?.stringPublisher?.sink(receiveCompletion: { _ in }, receiveValue: { value in
            self.searchQuery = value  //convert speech to text
        })
            .store(in: &cancelBag)
        self.speechSession?.startRecording() //recording voice query
        
    }

}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
