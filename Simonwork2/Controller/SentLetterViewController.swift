//
//  ReceivedLetterViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/24.
//

import UIKit
import Firebase
import WidgetKit
import GoogleMobileAds
import FBAudienceNetwork

class SentLetterViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var messages: [LetterData] = []
    let refreshControl = UIRefreshControl()
    
    //let contentList = LetterDataSource.data // DB 연동
    let cellSpacingHeight: CGFloat = 1
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        //f.timeStyle = .short
        return f
    }()
    
    @IBOutlet weak var letterTableView: UITableView!
    
    lazy var iconButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 아이콘 설정 (왼쪽 화살표 아이콘)
        let image = UIImage(systemName: "chevron.up")
        button.setImage(image, for: .normal)
        
        // 버튼 스타일 설정
        button.tintColor = .black
        button.backgroundColor = .white
                
        // 버튼의 레이어를 사용하여 원형 모양 만들기
        button.layer.cornerRadius = 25 // 버튼 크기의 절반으로 설정
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(iconButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc func iconButtonTapped() {
            print("Icon button tapped!")
        guard letterTableView.numberOfSections > 0 else {
                return // 섹션이 없으면 스크롤을 실행하지 않음
            }
        
        let indexPath = IndexPath(row: 0, section: 0)
        letterTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    var adView: FBAdView!
    lazy var containerView: UIView = {
        
        let height = 250
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.width), height: height))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(containerView)
        adView = FBAdView(placementID: Constants.FacebookAds.SentLetterVC, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        view.addSubview(iconButton)
//        adView = FBAdView(placementID: Constants.FacebookAds.ArchiveVC, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
//        adView.delegate = self
//        adView.loadAd()
    
        view.snapshotView(afterScreenUpdates: true)
        
        letterTableView.delegate = self
        letterTableView.dataSource = self
        
        registerXib()
        loadMessages()
        
        // 배너 광고 설정
        setupBannerViewToBottom(adUnitID: Constants.GoogleAds.admobBanner)
        
        // Add refresh control to table view
        if #available(iOS 10.0, *) {
            letterTableView.refreshControl = refreshControl
        } else {
            letterTableView.addSubview(refreshControl)
        }
        // Add target action for refresh control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    // Function to handle refresh action
    @objc func refreshData(_ sender: Any) {
        loadMessages()
        refreshControl.endRefreshing()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            // iconButton의 제약 조건 수정
            iconButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            iconButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            iconButton.widthAnchor.constraint(equalToConstant: 50),
            iconButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor(hex: "FDF2DC")
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(hex: "FDF2DC")
        navigationController?.navigationBar.topItem?.titleView?.backgroundColor = UIColor(hex: "FDF2DC")
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
        
        navigationController?.navigationBar.topItem?.title = "보낸 편지함"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        print("viewWillDisappear letterTableView.numberOfSections: ", letterTableView.numberOfSections)
//        
//        if letterTableView.numberOfSections > 0 {
//            
//            letterTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
//        } else {
//            // 섹션이 없으면 스크롤을 실행하지 않음
//        }
      
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        let nibName = UINib(nibName: "CustomizedCell", bundle: nil)
        letterTableView.register(nibName, forCellReuseIdentifier: "CustomizedCell")
    }
    
    func loadMessages(){
        
        let userFriendCode : String = UserDefaults.shared.object(forKey: "friendCode") as! String
        let userPairFriendCode : String = UserDefaults.shared.object(forKey: "pairFriendCode") as! String
        
        print("userFriendCode: \(userFriendCode)")
        print("userPairFriendCode: \(userPairFriendCode)")
        
        db.collection("LetterData")
            .whereField("sender", isEqualTo: userFriendCode)
            .whereField("receiver", isEqualTo: userPairFriendCode)
            .order(by: "updateTime", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                
                self.messages = []
                
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
                                let messageSenderName = data["senderName"] as! String
                                let messagePairFriendCode = data["receiver"] as! String
                                let messageLetterColor = data["letterColor"] as! String
                                let messageEmoji = data["emoji"] as! String
                                
                                let messageList = LetterData(
                                    sender: messageFriendCode,
                                    senderName: messageSenderName,
                                    receiver: messagePairFriendCode,
                                    title: messageTitle,
                                    content: messageContent,
                                    updateTime: messageUpdateTime,
                                    letterColor: messageLetterColor,
                                    emoji: messageEmoji
                                )
                                self.messages.append(messageList)
                                
                                let setTitle = self.messages[0].title
                                let setContent = self.messages[0].content
                                let setUpdateTime = self.messages[0].updateTime
                                let setLetterColor = self.messages[0].letterColor
                                let setEmoji = self.messages[0].emoji
                                let setSenderName = self.messages[0].senderName
                                
                                self.dispatchQueue()
                            }
                        }
                    }
                }
            }
    }
    
    func dispatchQueue() {
        DispatchQueue.main.async {
            if self.letterTableView != nil {
                self.letterTableView.reloadData()
                self.letterTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
                print("dispatchQueue 완료!")
            } else {
                //print("self.letterTableView에 nil 출력")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    } // section 당 row의 수
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        placeholderLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        placeholderLabel.text = "아직 보낸 편지가 없어요"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .gray
        
        if messages.count == 0 {
            tableView.backgroundView = placeholderLabel
        } else {
            tableView.backgroundView = nil
        }
        return messages.count
    } // section 의 수
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    } // 각 section 간에 간격 부여 (let cellSpacingHeight: CGFloat = 1)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // indexPath에 어떤 cell이 들어갈 것인지 결정하는 메소드 -> cellForRowAt
        // (함수 안에서 UItableViewCell을 생성하여 커스텀한 다음 그 cell을 반환하면 해당 cell이 특정 행에 적용되어 나타남)
        let message = messages[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomizedCell", for: indexPath) as! CustomizedCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.letterTitleLable?.text = message.title
        cell.letterDateLabel?.text = formatter.string(from: message.updateTime)
        cell.backgroundColor = UIColor(hex: message.letterColor)
        cell.emojiLabel.text = message.emoji
        
        navigationController?.navigationBar.sizeToFit()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 오른쪽에 만들기
        
        
        
        print("messages.count: ", messages)
        print("indexPath.section: ", indexPath.section)
        
        let title = messages[indexPath.section].title
        let content = messages[indexPath.section].content
        let sender = messages[indexPath.section].sender
        let receiver = messages[indexPath.section].receiver
        print("title: ", title)
        print("content: ", content)
        
        let delete = UIContextualAction(style: .normal, title: "Delete" ) { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            success(true)
            
            let alertController = UIAlertController(title: "정말로 보낸 편지를 삭제하시겠습니까?", message: "상대방도 더이상 편지를 볼 수 없으며,\n삭제 시 복구가 불가능합니다", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                // 취소 액션 처리
                print("canecl")
            }
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "확인", style: .destructive) { _ in
                
                // Firestore에서 문서를 삭제
                do {
                    try self.db.collection("LetterData")
                        .whereFilter(Filter.andFilter([
                            Filter.whereField("title", isEqualTo: title),
                            Filter.whereField("content", isEqualTo: content),
                            Filter.whereField("sender", isEqualTo: sender),
                            Filter.whereField("receiver", isEqualTo: receiver),
                        ])).getDocuments { querySnapshot, error in

                            if let error = error {
                                print("Error getting documents: \(error)")
                                success(false)
                                return

                            } else {

                                for document in querySnapshot!.documents {
                                    let documentID = document.documentID
                                    self.db.collection("LetterData").document(documentID).delete { error in
                                        
                                        if let error = error {
                                            print("Error getting documents: \(error)")
                                            success(false)
                                            
                                        } else {
                                            success(true)
                                        }
                                    }
                                }
                            }
                            
                            print("remove 직전: ", self.letterTableView.numberOfSections)

                            self.messages.remove(at: indexPath.section)
                            tableView.deleteSections([indexPath.section], with: .fade)
                            
                            print("remove 직후: ", self.letterTableView.numberOfSections)
                            
                            let finalAlertController = UIAlertController(title: "삭제 완료", message: "편지가 삭제되었습니다", preferredStyle: .alert)
                            
                            let confirmAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                                // 취소 액션 처리
                                print("confirm")
                            }
                            finalAlertController.addAction(confirmAction)
                            self.present(finalAlertController, animated: true, completion: nil)
                        }
                    
                } catch {
                    
                    print("Error removing document: \(error)")
                   
                }
            }
            
            alertController.addAction(okAction)
            
            // Alert 창 표시
            self.present(alertController, animated: true, completion: nil)
        }
        //delete.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions:[delete])
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forSectionAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
//            messages.remove(at: indexPath.section)
//            tableView.deleteSections([indexPath.section], with: .fade)
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sentLetterToMessageContent" {
            let nextVC = segue.destination as? LetterViewController
            
            if let index = sender as? Int {
                nextVC?.receivedTitleText = messages[index].title
                nextVC?.receivedContentText = messages[index].content
                nextVC?.receivedUpdateDate = messages[index].updateTime
                nextVC?.receivedLetterColor = messages[index].letterColor
                nextVC?.receivedEmoji = messages[index].emoji
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell 클릭 시, cell 내용을 보여주는 view controller로 이동
        performSegue(withIdentifier: "sentLetterToMessageContent", sender: indexPath.section)
    }
}

extension SentLetterViewController : FBAdViewDelegate {
    
    func adViewDidLoad(_ adView: FBAdView) {
        
        // 광고 뷰를 앱의 뷰 계층에 추가
        let screenHeight = view.bounds.height
        let adViewHeight = adView.frame.size.height

        print("adViewDidLoad 성공")
        requestPermission()
        
        showAd()

    }

    // 배너 광고 불러오기 실패 시 호출되는 메서드
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("ArchiveVC 광고 불러오기 실패: \(error)")
        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
        
    }

    private func showAd() {
      guard let adView = adView, adView.isAdValid else {
        return
      }
        containerView.addSubview(adView)
    }
}
