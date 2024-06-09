//
//  LetterDataSource.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/10.
//

import UIKit
import Foundation
import Firebase
import WidgetKit
import UserNotifications

extension AppDelegate {
    
    func updateWidget() {
        let db = Firestore.firestore()
        let userFriendCode : String = UserDefaults.shared.object(forKey: "friendCode") as! String
        let userPairFriendCode : String = UserDefaults.shared.object(forKey: "pairFriendCode") as! String
        
        let calendar = Calendar.current
        let currentDate = Date()
        let todayMidnight = calendar.startOfDay(for: currentDate)
        let timeStamp = Timestamp(date: todayMidnight)
        
        db.collection("LetterData")
            .whereField("sender", isEqualTo: userPairFriendCode)
            .whereField("receiver", isEqualTo: userFriendCode)
            .whereField("updateTime", isLessThan: timeStamp)
            .order(by: "updateTime", descending: true)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, error) in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageTitle = data["title"] as? String,
                               let message_UpdateTime = data["updateTime"] as? Timestamp {
                                
                                let messageUpdateTime = message_UpdateTime.dateValue()
                                let messageContent = data["content"] as! String
                                let messageSenderName = data["senderName"] as! String
                                let messageLetterColor = data["letterColor"] as! String
                                let messageEmoji = data["emoji"] as! String
                                
                                UserDefaults.shared.set(messageTitle, forKey: "latestTitle")
                                UserDefaults.shared.set(messageContent, forKey: "latestContent")
                                UserDefaults.shared.set(messageUpdateTime, forKey: "latestUpdateDate")
                                UserDefaults.shared.setValue(messageLetterColor, forKey: "latestLetterColor")
                                UserDefaults.shared.set(messageEmoji, forKey: "latestEmoji")
                                UserDefaults.shared.set(messageSenderName, forKey: "latestSenderName")
                                
                                WidgetCenter.shared.reloadAllTimelines()
                                
                                print("messageTitle: \(messageTitle)")
                                print("messageUpdateTime: \(messageUpdateTime)")
                                print("messageUpdateTime: \(messageUpdateTime)")
                                print("messageLetterColor: \(messageLetterColor)")
                                print("messageEmoji: \(messageEmoji)")
                                print("messageSenderName: \(messageSenderName)")
                            }
                        }
                    }
                }
            }
    }
    
}
