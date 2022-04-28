# TalkToMe-ML-NLP-SwiftUI
## A ML and NLP based App written in SwiftUI


This is an interactive text classifier application which converts our questions from speech to text and then gives us results from the ml model by converting text to speech.


## Application feature-

1. Ask questions using voice command.
2. App will respond to your questions and dictates it for you.
3. During app's respond if another question is asked it stops dictating the previous answer and dictates the new answer.
4. App is based on Machine Learning Model and uses NLP to give results.


The files contained here are:

## TextClassifier.mlmodel

This is the ML Model in which our questions are passed and the results are given by the model according to the questions.


## MLModel.swift

This file contains code for loading the model in our app and passing input questions and get output from the model.


## StopRecord.swift

This file contains function to convert text to speech when we get result from the ML Model.


## SearchView.swift

This file contains the UI of our app and the function used to convert speech to text.


## Packages used:

SwiftSpeech : For converting speech to text
AVFoundation: For converting text to speech
ComposableArchitecture


## Demo gif for review
![TalkToMe](https://user-images.githubusercontent.com/96408807/165761425-098db177-b56e-4038-b14c-f1fffbb054d8.gif)







