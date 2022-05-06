//
//  SpeechClient.swift
//  DemoApp
//
//  Created by IPHTECH 4 on 21/04/22.
//

import Combine
import ComposableArchitecture
import Speech

// The core data types in the Speech framework are reference types and are not constructible by us,
// and so they aren't super testable out the box. We define struct versions of those types to make
// them easier to use and test.

// MARK: - Models

public struct SpeechRecognitionResult: Equatable {
  var bestTranscription: Transcription
  var transcriptions: [Transcription]
  var isFinal: Bool
}

struct Transcription: Equatable {
  var averagePauseDuration: TimeInterval
  var formattedString: String
  var segments: [TranscriptionSegment]
  var speakingRate: Double
}

struct TranscriptionSegment: Equatable {
  var alternativeSubstrings: [String]
  var confidence: Float
  var duration: TimeInterval
  var substring: String
  var substringRange: NSRange
  var timestamp: TimeInterval
  var voiceAnalytics: VoiceAnalytics?
}

struct VoiceAnalytics: Equatable {
  var jitter: AcousticFeature
  var pitch: AcousticFeature
  var shimmer: AcousticFeature
  var voicing: AcousticFeature
}

struct AcousticFeature: Equatable {
  var acousticFeatureValuePerFrame: [Double]
  var frameDuration: TimeInterval
}

extension SpeechRecognitionResult {
  init(_ speechRecognitionResult: SFSpeechRecognitionResult) {
    self.bestTranscription = Transcription(speechRecognitionResult.bestTranscription)
    self.transcriptions = speechRecognitionResult.transcriptions.map(Transcription.init)
    self.isFinal = speechRecognitionResult.isFinal
  }
}

extension Transcription {
  init(_ transcription: SFTranscription) {
    self.averagePauseDuration = transcription.averagePauseDuration
    self.formattedString = transcription.formattedString
    self.segments = transcription.segments.map(TranscriptionSegment.init)
    self.speakingRate = transcription.speakingRate
  }
}

extension TranscriptionSegment {
  init(_ transcriptionSegment: SFTranscriptionSegment) {
    self.alternativeSubstrings = transcriptionSegment.alternativeSubstrings
    self.confidence = transcriptionSegment.confidence
    self.duration = transcriptionSegment.duration
    self.substring = transcriptionSegment.substring
    self.substringRange = transcriptionSegment.substringRange
    self.timestamp = transcriptionSegment.timestamp
    self.voiceAnalytics = transcriptionSegment.voiceAnalytics.map(VoiceAnalytics.init)
  }
}

extension VoiceAnalytics {
  init(_ voiceAnalytics: SFVoiceAnalytics) {
    self.jitter = AcousticFeature(voiceAnalytics.jitter)
    self.pitch = AcousticFeature(voiceAnalytics.pitch)
    self.shimmer = AcousticFeature(voiceAnalytics.shimmer)
    self.voicing = AcousticFeature(voiceAnalytics.voicing)
  }
}

extension AcousticFeature {
  init(_ acousticFeature: SFAcousticFeature) {
    self.acousticFeatureValuePerFrame = acousticFeature.acousticFeatureValuePerFrame
    self.frameDuration = acousticFeature.frameDuration
  }
}

// MARK: - SpeechClient

public struct SpeechClient {
  var cancelTask: (AnyHashable) -> Effect<Never, Never>
  var finishTask: (AnyHashable) -> Effect<Never, Never>
  var recognitionTask: (AnyHashable, SFSpeechAudioBufferRecognitionRequest) -> Effect<Action, Error>
  var requestAuthorization: () -> Effect<SFSpeechRecognizerAuthorizationStatus, Never>

  public enum Action: Equatable {
    case availabilityDidChange(isAvailable: Bool)
    case taskResult(SpeechRecognitionResult)
  }

  public enum Error: Swift.Error, Equatable {
    case taskError
    case couldntStartAudioEngine
    case couldntConfigureAudioSession
  }
}

// MARK: - Speech Live

extension SpeechClient {
  static let live = SpeechClient(
    cancelTask: { id in
      .fireAndForget {
        dependencies[id]?.cancel()
        dependencies[id] = nil
      }
    },
    finishTask: { id in
      .fireAndForget {
        dependencies[id]?.finish()
        dependencies[id]?.subscriber.send(completion: .finished)
        dependencies[id] = nil
      }
    },
    recognitionTask: { id, request in
      Effect.run { subscriber in
        let cancellable = AnyCancellable {
          dependencies[id]?.cancel()
          dependencies[id] = nil
        }

        let speechRecognizer = SFSpeechRecognizer(locale: .current)!
        let speechRecognizerDelegate = SpeechRecognizerDelegate(
          availabilityDidChange: { available in
            subscriber.send(.availabilityDidChange(isAvailable: available))
          }
        )
        speechRecognizer.delegate = speechRecognizerDelegate

        let audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        do {
          try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
          try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
          subscriber.send(completion: .failure(.couldntConfigureAudioSession))
          return cancellable
        }
        let inputNode = audioEngine.inputNode

//        request.shouldReportPartialResults = true
//        request.requiresOnDeviceRecognition = false
        
        let recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
          switch (result, error) {
          case let (.some(result), _):
            subscriber.send(.taskResult(SpeechRecognitionResult(result)))
          case let (_, .some(error)):
            subscriber.send(completion: .failure(.taskError))
          case (.none, .none):
            fatalError("It should not be possible to have both a nil result and nil error.")
          }
        }

        dependencies[id] = SpeechDependencies(
          audioEngine: audioEngine,
          inputNode: inputNode,
          recognitionTask: recognitionTask,
          speechRecognizer: speechRecognizer,
          speechRecognizerDelegate: speechRecognizerDelegate,
          subscriber: subscriber
        )

        inputNode.installTap(
          onBus: 0,
          bufferSize: 1024,
          format: inputNode.outputFormat(forBus: 0)
        ) { buffer, when in
          request.append(buffer)
        }

        audioEngine.prepare()
        do {
          try audioEngine.start()
        } catch {
          subscriber.send(completion: .failure(.couldntStartAudioEngine))
          return cancellable
        }

        return cancellable
      }
      .cancellable(id: id)
    },
    requestAuthorization: {
      .future { callback in
        SFSpeechRecognizer.requestAuthorization { status in
          callback(.success(status))
        }
      }
    }
  )
}

private struct SpeechDependencies {
  let audioEngine: AVAudioEngine
  let inputNode: AVAudioInputNode
  let recognitionTask: SFSpeechRecognitionTask
  let speechRecognizer: SFSpeechRecognizer
  let speechRecognizerDelegate: SpeechRecognizerDelegate
  let subscriber: Effect<SpeechClient.Action, SpeechClient.Error>.Subscriber

  func finish() {
    self.audioEngine.stop()
    self.inputNode.removeTap(onBus: 0)
    self.recognitionTask.finish()
  }

  func cancel() {
    self.audioEngine.stop()
    self.inputNode.removeTap(onBus: 0)
    self.recognitionTask.cancel()
  }
}

private var dependencies: [AnyHashable: SpeechDependencies] = [:]

private class SpeechRecognizerDelegate: NSObject, SFSpeechRecognizerDelegate {
  var availabilityDidChange: (Bool) -> Void

  init(availabilityDidChange: @escaping (Bool) -> Void) {
    self.availabilityDidChange = availabilityDidChange
  }

  func speechRecognizer(
    _ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool
  ) {
    self.availabilityDidChange(available)
  }
}

