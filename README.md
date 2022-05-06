# TalkToMe-ML-NLP-SwiftUI
## A ML and NLP based App written in SwiftUI


This is an interactive text classifier application which converts our questions from speech to text and then gives us results from the ml model by converting text to speech.


## Application feature:

1. Ask questions using voice command.
2. App will respond to your questions and dictates it for you.
3. During app's respond if another question is asked it stops dictating the previous answer and dictates the new answer.
4. App is based on Machine Learning Model and uses NLP to give results.

## Authorization:

Though SwiftSpeech takes care of all the verbose stuff of authorization for you, you still have to state the usage descriptions and specify where you want the authorization process to happen before you start to use it.

## Usage Descriptions in info.plist

Add these two rows in your Info.plist: Privacy - Microphone Usage Description and Privacy - Speech Recognition Usage Description.

These are the messages your users will see on their first use, in the alerts that ask them for permission to use speech recognition and to access the microphone.


The files contained here are:

## TextClassifier.mlmodel

This is the ML Model in which our questions are passed and the results are given by the model according to the questions.


## MLModel.swift

This file contains class for loading the model in our app and passing input questions and get output from the model.


## StopRecord.swift

This file contains function to convert text to speech when we get result from the ML Model.


## SearchView.swift

This file contains the UI of our app and the function used to convert speech to text.


## ArcView.swift

This file contains code for drawing an arc in the bottom part of our app's screen to make an interactive UI.


## Extension.swift

This file contains the extension readability code of our SearchView.


## TextClassifier.json

This file contains our json file which we use to train our ML Model. 


## Packages used:

SwiftSpeech : For converting speech to text (https://github.com/Cay-Zhang/SwiftSpeech)
AVFoundation: For converting text to speech
ComposableArchitecture (https://github.com/pointfreeco/swift-composable-architecture)


## Steps to train the ML model and implement in our project
https://docs.google.com/document/d/1nW9lGof4FekiD-CxDrQtfnzxfSp6baAYXMHBxmM_8cY/edit?usp=sharing


## Demo gif for review
![TalkToMe](https://user-images.githubusercontent.com/96408807/165761425-098db177-b56e-4038-b14c-f1fffbb054d8.gif)







