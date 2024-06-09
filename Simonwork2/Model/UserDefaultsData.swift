//
//  UserDefaultsData.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/30.
//

import Foundation
import Firebase

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.Simonwork2"
        return UserDefaults(suiteName: appGroupId)!
    }
}

struct UserDefaultsData {
    
    init(UserName: String, UserEmail: String, friendCode: String, friendName: String, uid: String, pairFriendCode: String, signupTime: Date, documentID: String, connectedTime: Date, todayLetterTitle: String, todayLetterContent: String, todayLetterUpdateTime: Date) {
        
        UserDefaults.shared.set(UserName, forKey: "userName")
        UserDefaults.shared.set(UserEmail, forKey: "userEmail")
        UserDefaults.shared.set(friendCode, forKey: "friendCode")
        UserDefaults.shared.set(friendName, forKey: "friendName")
        UserDefaults.shared.set(uid, forKey: "ALetterFromLateNightUid")
        UserDefaults.shared.set(pairFriendCode, forKey: "pairFriendCode")
        UserDefaults.shared.set(signupTime, forKey: "signupTime")
        UserDefaults.shared.set(documentID, forKey: "documentID")
        UserDefaults.shared.set(connectedTime, forKey: "connectedTime")
        UserDefaults.shared.set(todayLetterTitle, forKey: "todayLetterTitle")
        UserDefaults.shared.set(todayLetterContent, forKey: "todayLetterContent")
        UserDefaults.shared.set(todayLetterUpdateTime, forKey: "todayLetterUpdateTime")
    }
}

struct removeUserDefaultsData {
    init() {
        UserDefaults.shared.removeObject(forKey: "userName")
        UserDefaults.shared.removeObject(forKey: "userEmail")
        UserDefaults.shared.removeObject(forKey: "friendCode")
        UserDefaults.shared.removeObject(forKey: "friendName")
        UserDefaults.shared.removeObject(forKey: "ALetterFromLateNightUid")
        UserDefaults.shared.removeObject(forKey: "pairFriendCode")
        UserDefaults.shared.removeObject(forKey: "signupTime")
        // 상대방의 document 확인 목적
        UserDefaults.shared.removeObject(forKey: "documentID")
        // 상대방과 얼마나 오랫동안 연결됐는지 확인 목적
        UserDefaults.shared.removeObject(forKey: "connectedTime")
        // 오늘 편지 보냈는지 여부 확인 목적
        UserDefaults.shared.removeObject(forKey: "todayLetterTitle")
        UserDefaults.shared.removeObject(forKey: "todayLetterContent")
        UserDefaults.shared.removeObject(forKey: "todayLetterUpdateTime")
        // 위젯 전달 목적
        UserDefaults.shared.removeObject(forKey: "latestTitle")
        UserDefaults.shared.removeObject(forKey: "latestContent")
        UserDefaults.shared.removeObject(forKey: "latestUpdateDate")
        UserDefaults.shared.removeObject(forKey: "latestLetterColor")
        UserDefaults.shared.removeObject(forKey: "latestEmoji")
        UserDefaults.shared.removeObject(forKey: "latestSender")
    }
}
