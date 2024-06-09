//
//  LetterWidgetBundle.swift
//  LetterWidget
//
//  Created by daelee on 2023/04/01.
//

import WidgetKit
import SwiftUI
import Firebase

@main
struct LetterWidgetBundle: WidgetBundle {
    
    func auth() {
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        if let filePath = filePath, let firebaseOptions = FirebaseOptions.init(contentsOfFile: filePath)
        {
            FirebaseApp.configure(options: firebaseOptions)
        }
    }
    
    var body: some Widget {
        LetterWidget()
        LetterWidgetLiveActivity()
    }
}
