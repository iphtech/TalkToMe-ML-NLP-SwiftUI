//
//  MLModel.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//

import CoreML
import NaturalLanguage

class Classifiers {
    
// function for loading our model to get output
    
    func classifyAction(for message: String) -> String {
        
        do {
            let mlModel = try TextClassifier(configuration: MLModelConfiguration()).model  //loading ML Model
            let actionClassifier = try NLModel(mlModel: mlModel)  //classifier to get results from model
            if let action = actionClassifier.predictedLabel(for: message) {
                return action   //returning result from model for the input text
            }
        }catch {
            print(error)
        }
        return "Could not be able to find out.."
    }
}

