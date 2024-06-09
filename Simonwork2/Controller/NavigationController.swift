//
//  NavigationController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/14.
//

import UIKit
import FirebaseMessaging

// UINavigationController를 상속하는 커스텀 클래스를 작성
class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
          }
        }
    }
}
