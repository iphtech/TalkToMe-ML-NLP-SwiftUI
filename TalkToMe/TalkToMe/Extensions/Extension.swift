//
//  Extension.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//

import Foundation
import SwiftUI

//MARK:- Readability Extension
extension SearchView {
    
    var queryText: some View  {
        
        Text(searchQuery)   //displaying searched query
            .font(.custom("Arial Rounded MT Bold", size: 40))
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .offset(y: 150)
        
    }
    
    var modelOutput: some View {
        
        Text(result)  //displaying result from model
            .font(.custom("Arial Rounded MT Bold", size: 25))
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .position(x: 180, y: 300)
        
    }
}

