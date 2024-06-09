//
//  ConnectViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/23.
//

import UIKit
import Firebase

var inputDocumentID = "none"
var inputPairFriendName : String = ""

class ConnectTypingViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let waitingVC = WaitingViewController()
    
    @IBOutlet weak var pairFriendCodeTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var myFriendCodeLabel: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pairFriendCodeTextField.delegate = self
        pairFriendCodeTextField.autocorrectionType = .no
        pairFriendCodeTextField.spellCheckingType = .no
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        let myFriendCode = UserDefaults.shared.string(forKey: "friendCode")!
        myFriendCodeLabel?.text = myFriendCode
        
    }
    
    func friendCodeCheck() {
        let myFriendCode = UserDefaults.shared.string(forKey: "friendCode")!
        
        if let inputPairFriendCode = pairFriendCodeTextField.text {
            // 내가 입력한 pairFriendCode가 DB상에 존재하는지 확인
            if inputPairFriendCode == myFriendCode { // 본인의 친구코드를 그대로 입력한 경우 오류 메시지 출력
                let sheet = UIAlertController(
                    title: "다른 친구코드를 입력해주세요!",
                    message: "나의 친구코드가 아닌 상대방의 친구코드를 입력해주세요",
                    preferredStyle: .alert)
                sheet.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    print("yes 클릭")
                }))
                DispatchQueue.main.async { // '보내기' 이후 title, content 내용 초기화
                    self.pairFriendCodeTextField.text = ""
                }
                self.present(sheet, animated: true)
                
            } else if inputPairFriendCode == "######" { // 더미 데이터 생성 및 자동 연결 필요
                
                let userName = "Dummy"
                let currentDate = Date()
                let friendName = UserDefaults.shared.string(forKey: "userName")!
                let documentID = UserDefaults.shared.string(forKey: "documentID")!
                let todayLetterTitle = "no todayLetterTitle"
                let todayLetterContent = "no todayLetterContent"
                let todayLetterUpdateTime = Date() - (24 * 60 * 60)
                inputDocumentID = "############################"
                inputPairFriendName = userName
                
                // 1. 더미 데이터 생성 및 친구 등록 완료
                db.collection("UserData").document(inputDocumentID).setData([
                    "userName": userName,
                    "userEmail": "Dummy Email",
                    "uid": inputDocumentID,
                    "friendName" : friendName,
                    "friendCode": inputPairFriendCode,
                    "pairFriendCode": myFriendCode,
                    "signupTime": currentDate,
                    "letterCount": 0,
                    "documentID" : documentID,
                    "connectedTime" : currentDate,
                    "todayLetterTitle" : todayLetterTitle,
                    "todayLetterContent" : todayLetterContent,
                    "todayLetterUpdateTime" : todayLetterUpdateTime
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        
                        let uid : String = UserDefaults.shared.object(forKey: "ALetterFromLateNightUid") as! String // 나의 uid / document 이름
                        let dcRef = self.db.collection("UserData").document("\(uid)")
                        
                        // db상 나의 데이터
                        dcRef.updateData([
                            "pairFriendCode" : inputPairFriendCode,
                            "friendName" : userName
                        ])  { (err) in // 나의 UserData에서 pairFriendCode를 inputPairFriendCode로 업데이트
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                //나의 pairFriendCode 및 pairFriendCode 업데이트
                                UserDefaults.shared.set(inputPairFriendCode, forKey: "pairFriendCode")
                                UserDefaults.shared.set(userName, forKey: "friendName")
                                
                                DispatchQueue.main.async { // '보내기' 이후 title, content 내용 초기화
                                    self.pairFriendCodeTextField.text = ""
                                }
                                self.segueToWaitingVC()
                            }
                        }
                    }
                }
            } else { // 입력된 pairFriendCode를 검색
                db.collection("UserData").whereField("friendCode", isEqualTo: inputPairFriendCode).getDocuments() { (querySnapshot, error) in
                    
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let documents = querySnapshot!.documents
                        if documents.isEmpty == false { // friendCode가 DB 상에 있는 경우에 해당
                            print("friend 코드가 db 상에 있음")
                            // 무결성 조회가 필요 (다른 사람과 연결되어 있으면 어떻게 할 건지?)
                            // 1) inputPairFriendCode의 문서에서 다른 사람과 연결되어 있는지 확인
                            // 2-1) 연결되어 있으면 이미 다른 친구와 연결되었다는 메세지 표시 (문서에서 pairFriendCode가 none이 아닌 경우) "상대방이 이미 다른 사람과 연결되어 있어요"
                            // "다른 친구코드를 입력하거나 상대방이 다른 친구와 연결을 끊어야 해요"
                            // 2-2) 연결 안되어 있으면 그대로 진행 (문서에서 pairFriendCode가 none인 경우)
                            for document in documents {
                                let data = document.data()
                                // 다른 친구와 이미 연결되었는지 확인
                                if data["pairFriendCode"] as! String != "no pairFriendCode" && data["pairFriendCode"] as! String != myFriendCode { // 이미 연결된 다른 친구코드가 있음
                                    let sheet = UIAlertController(title: "상대방이 이미 다른 친구코드와 연결되어 있어요", message: "상대방이 다른 사람과의 연결을 끊거나 다른 친구코드를 입력해주세요", preferredStyle: .alert)
                                    let ok = UIAlertAction(title: "확인", style: .default, handler: { _ in
                                        print("yes 클릭")
                                    })
                                    sheet.addAction(ok)
                                    self.present(sheet, animated: true)
                                    
                                    DispatchQueue.main.async { // '확인' 이후 title, content 내용 초기화
                                        self.pairFriendCodeTextField.text = ""
                                    }
                                } else { // 상대방의 pairFriendCode가 none이며 연결된 친구가 아직 없음 (data["pairFriendCode"] as! String == "no pairFriendCode")
                                    // 또는 내가 상대방과 연결을 끊은 상태인데, 아직 상대방은 나를 pairFriendCode에 유지하고 있음(이 경우에는 그대로 연결할 수 있게끔 유도)
                                    // data["pairFriendCode"] as! String == myFriendCode
                                    let documentID = document.documentID // document.documentID는 상대방의 uid로 설정되어 있음.
                                    print("\(documentID) => \(document.data())")
                                    inputDocumentID = documentID // 상대방의 uid(documentID)를 inputDocumentID로 설정
                                    if let pairFriendName = data["userName"] as? String {
                                        // 상대방의 UserName 즉, 나의 pairfriend의 Name
                                        print("friendName: \(pairFriendName)")
                                        
                                        inputPairFriendName = pairFriendName
                                        print("inputFriendName: \(inputPairFriendName)")
                                        
                                        let uid : String = UserDefaults.shared.object(forKey: "ALetterFromLateNightUid") as! String // 나의 uid / document 이름
                                        let dcRef = self.db.collection("UserData").document("\(uid)")
                                        
                                        // db상 나의 데이터
                                        dcRef.updateData([
                                            "pairFriendCode" : inputPairFriendCode,
                                            "friendName" : pairFriendName
                                        ])  { (err) in // 나의 UserData에서 pairFriendCode를 inputPairFriendCode로 업데이트
                                            if let err = err {
                                                print("Error updating document: \(err)")
                                            } else {
                                                print("Document successfully updated")
                                                //나의 pairFriendCode 및 pairFriendCode 업데이트
                                                UserDefaults.shared.set(inputPairFriendCode, forKey: "pairFriendCode")
                                                UserDefaults.shared.set(pairFriendName, forKey: "friendName")
                                                
                                                self.segueToWaitingVC()
                                            }
                                        }
                                    }
                                }
                                return
                            }
                        } else { // 입력한 친구코드가 db 상에 없는 경우이므로 제대로 된 코드 입력하라는 알림 필요.
                            let sheet = UIAlertController(title: "존재하지 않는 친구코드에요", message: "앱 다운로드 링크를 친구에게 보낼까요?", preferredStyle: .alert)
                            let sendInvitation = UIAlertAction(title: "보내기", style: .default, handler: { _ in

                                // 여기서 다운로드 링크를 보여줘야 함. 유저가 복사하게끔 하는 것도 괜찮을듯?
                                // 다운로드 링크를 유저가 상대방에게 공유하고, 공유받은 상대방은 링크를 클릭해서 앱스토어로 이동
                                let downloadLink = UIAlertController(title: "다운로드 URL을 공유해주세요", message: "https://sites.google.com/view/aletterfromlatenight/%ED%99%88", preferredStyle: .alert)
                                let copyLink = UIAlertAction(title: "복사", style: .default) { _ in
                                    UIPasteboard.general.string = "https://sites.google.com/view/aletterfromlatenight/%ED%99%88"
                                    // "저장할 텍스트" 자리에 다운로드 url을 넣어주면 복사가 완료됨
                                    
                                }
                                
                                downloadLink.addAction(copyLink)
                                self.present(downloadLink, animated: true)
                            })
                            let close = UIAlertAction(title: "아니오", style: .destructive, handler: nil)
                            sheet.addAction(sendInvitation)
                            sheet.addAction(close)
                            self.present(sheet, animated: true)
                            
                            DispatchQueue.main.async { // '보내기' 이후 title, content 내용 초기화
                                self.pairFriendCodeTextField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    func segueToWaitingVC() {
        // waitingVC 화면으로 보내기
        performSegue(withIdentifier: "connectTypingToWaiting", sender: nil)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        friendCodeCheck()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connectTypingToWaiting" {
            let nextVC = segue.destination as? WaitingViewController
            
            nextVC?.inputPairFriendName = inputPairFriendName
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        let pasteBoard = UIPasteboard.general
        
        pasteBoard.string = myFriendCodeLabel.text
        
        alert(title: "친구코드가 복사되었습니다", message: "상대방에게 친구코드를 알려주세요", actionTitle: "확인")
    }
    
    @IBAction func appDownloadLinkCopyButtonPressed(_ sender: UIButton) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = Constants.K.appDownloadLink
        
        alert(title: "다운로드 링크가 복사되었습니다", message: "상대방에게 링크를 전달해주세요", actionTitle: "확인")
    }
}

extension ConnectTypingViewController: UITextFieldDelegate {
    func countCharacters(_ text: String) -> Int {
        let charCount = text.utf16.count // String의 utf16 속성을 이용하여 글자 수를 세어줌
        return charCount
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {return false}
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let charCount = countCharacters(changedText)
        
        if charCount <= 6 { // 6자 이하일 경우에만 텍스트 업데이트
            return true
        } else {
            return false // 6자 이상인 경우 텍스트 업데이트 및 입력 막기
        }
    }
}

//1.
// https://itunes.apple.com/kr/app/apple-store/{app이름}
//iOS의 경우 app이름이 id1234123123 이런식으로 조합된다.
//
//2. market shceme을 사용하기
//itms-apps://itunes.apple.com/kr/app/apple-store/{app이름}
