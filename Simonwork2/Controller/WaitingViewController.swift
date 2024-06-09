//
//  ConnectViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/23.
//

import UIKit
import Firebase

class WaitingViewController: UIViewController {
    
    var inputPairFriendCode : String?
    var inputPairFriendName : String?
    var documentID : String?
    var timer = Timer()
    var listener: ListenerRegistration? // ListenerRegistration 선언
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helloLabel?.text = "\(inputPairFriendName!)님께\n기분을 북돋는 한 마디를\n남겨볼까요?"
        helloLabel?.asColor(targetStringList: [inputPairFriendName], color: .purple)
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(inputFriendCodeCheck), userInfo: nil, repeats: false)
        // inputFriendCode를 friendCode로 가지고 있는 유저의 문서를 실시간 조회 -> 실시간으로 조회하는 중에 유저가 pairFriendCode에다가 나의 friendCode를 넣으면 mainVC로 세그
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.activityIndicator.stopAnimating()
    }
    
    @objc func inputFriendCodeCheck() {
        //inputFriendCode가 상대방의 friendCode와 일치하는지 실시간으로 조회
        //(상대방이 나의 친구코드를 connectTyping VC에서 입력하게 되면 dbDocumentsCall()를 실행
        print("inputFriendCodeCheck 진입")
        let myFriendCode = UserDefaults.shared.string(forKey: "friendCode")!
        let documentId = inputDocumentID
        
        listener = db.collection("UserData").document(documentId) // 상대방의 uid 가 document의 이름임
            .addSnapshotListener { (documentSnapshot, error) in
                
                self.listener?.remove()
                
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                
                if data["pairFriendCode"] as? String == myFriendCode { // 상대방이 pairFriendCode로 나의 friendCode를 업데이트하면, startVC로 세그
                    
                    let uid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid")!
                    let connectedTime = Date()
                    UserDefaults.shared.set(connectedTime, forKey: "connectedTime")
                    
                    let dcRef = self.db.collection("UserData").document(uid)
                    
                    // db상 나의 데이터
                    dcRef.updateData([
                        "documentID" : documentId,
                        "connectedTime" : connectedTime
                    ])  { (err) in // 나의 UserData에서 documentId를 업데이트
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            UserDefaults.shared.set(documentId, forKey: "documentID")
                            self.timer.invalidate()
                            print("self.timer.invalidate")
                            // StartViewController 화면으로 보내기
                            self.listener?.remove()
                            print("self.listener?.remove")
                            self.performSegue(withIdentifier: "waitingToStart", sender: nil)
                            print("self.performSegue")
                        }
                    }
                    print("pairFriendCode 연동 완료")
                }
            }
        
    }
}
