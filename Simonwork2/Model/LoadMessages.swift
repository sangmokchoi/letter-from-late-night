//
//  LoadMessages.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/29.
//

import Firebase
class LoadMessages {
    
    func loadMessagesFromDB(sender: String, receiver: String) {
        let db = Firestore.firestore()
        // db에서 편지를 가져올 떄, 유저의 친구코드 내지는 uid 등을 확인하여 해당 값을 포함한 문서만 가져와야함
        db.collection("LetterData")
            .whereField("sender", isEqualTo: sender)
            .whereField("receiver", isEqualTo: receiver)
            .order(by: "updateTime")
            .addSnapshotListener { (querySnapshot, error) in
                
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
                                let messageFriendCode = data["sender"] as! String
                                let messagePairFriendCode = data["receiver"] as! String
                                
                                let messageList = LetterData(
                                    sender: messageFriendCode,
                                    receiver: messagePairFriendCode,
                                    title: messageTitle,
                                    content: messageContent,
                                    updateTime: messageUpdateTime
                                )
                            }
                        }
                    }
                }
            }
    }
    
}
