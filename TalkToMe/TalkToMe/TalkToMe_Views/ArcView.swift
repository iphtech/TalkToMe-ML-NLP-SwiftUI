//
//  ArcView.swift
//  TalkToMe
//
//  Created by IPHTECH 4 on 06/05/22.
//


// struct to draw arc shape

import SwiftUI

struct ArcView: Shape {
  let startAngle: Angle   //start angle for arc
  let endAngle: Angle     //end angle for arc
  let clockwise: Bool     //to start arc in clockwise direction

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let radius = max(rect.size.width, rect.size.height) / 2  //radius of arc
    path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: clockwise)  // drawing arc
    return path
  }
}
