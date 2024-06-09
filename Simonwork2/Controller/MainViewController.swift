//
//  ViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/08.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency
import FBAudienceNetwork

extension UILabel { // 글자 색상 바꾸는 함수
    func asColor(targetStringList: [String?], color: UIColor) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        
        targetStringList.forEach{
            let range = (fullText as NSString).range(of: $0 ?? "")
            attributedString.addAttributes([.foregroundColor: color as Any], range: range)
        }
        attributedText = attributedString
    }
}

class MainViewController: UIViewController {
    
    let db = Firestore.firestore()
    let sendUserNotification = SendUserNotification()
    let archiveVC = ArchiveViewController()
    let sentLetterVC = SentLetterViewController()
    
    @IBOutlet weak var dayCountingLabel: UILabel!
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var letterSendButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var settingButton: UIButton!
    
    var adView: FBAdView!
    lazy var containerView: UIView = {
        
        let height = 250
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.width), height: height))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        
        return containerView
    }()
    
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestPermission()
        
        view.addSubview(containerView)
        adView = FBAdView(placementID: Constants.FacebookAds.mainVC, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
        adView.loadAd()
        
        dayCountingLabel?.textColor = UIColor(hex: "FDF2DC")
        settingButton?.setTitle("", for: .normal)
        
        //}
        changeLabelColor()
        
        loadingIndicator.clipsToBounds = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingIndicator)
        view.bringSubviewToFront(loadingIndicator)
        
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: dayCountingLabel.centerYAnchor)
        ])
        
        loadingIndicator.startAnimating()
        // 배너 광고 설정
        setupBannerViewToBottom(adUnitID: Constants.GoogleAds.normalBanner)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        todayDateLabel?.text = dateFormatter.string(from: Date())
        
        archiveVC.archiveUpdate()
        sentLetterVC.loadMessages()
    }
    
    func changeLabelColor() {
        
        let userDefaultsUid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid")
        let userUid = Auth.auth().currentUser?.uid ?? userDefaultsUid
        
        db.collection("UserData").whereField("uid", isEqualTo: userUid).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let userConnectedTime = data["connectedTime"] as? Timestamp {
                            
                            let friendName = data["friendName"] as? String
                            UserDefaults.shared.set(friendName, forKey: "friendName")
                            let calendar = Calendar.current
                            let today = Date()
                            let dateFormatter = DateFormatter()
                            var daysCount : Int = 0
                            
                            let connectedTime = userConnectedTime.dateValue()
                            // dateValue() : 날짜는 정확하지만 시간 단위는 부정확할 수 있음.
                            
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let startDateString = dateFormatter.string(from: connectedTime)
                            let startDate = dateFormatter.date(from: startDateString)
                            
                            daysCount = Calendar.current.dateComponents([.day], from: startDate!, to: today).day! + 1
                            if let dayCountingLabel = self.dayCountingLabel {
                                
                                DispatchQueue.main.async {
                                    self.loadingIndicator.stopAnimating()
                                    self.loadingIndicator.removeFromSuperview()
                                    dayCountingLabel.text = "\(friendName!)님과 편지를\n주고받은 지 \(daysCount)일째"
                                    dayCountingLabel.textColor = .black
                                    dayCountingLabel.asColor(targetStringList: [friendName, String(daysCount)], color: .purple)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        sendUserNotification.requestNotificationAuthorization() // 알림 권한 요청 함수
        // if n일 째가 넘어가면 알림 전송하는 함수 추후 구현
        //sendNotification(seconds: 5) // 현재는 3초뒤 테스트 푸시알림. 오늘 편지를 아직 작성하지 않았을때 && 시간이 저녁 11시일때 발송
        
        sendUserNotification.letterSendingPush() // 유저가 오늘 편지를 보냈는지 여부에 따라 notification을 전달하는 함수
    }
    
    @IBAction func letterSendButtonPressed(_ sender: UIButton) {
        let todayLetterUpdateTime = UserDefaults.shared.object(forKey: "todayLetterUpdateTime") as? Date
        
        let todayLetterSend = timeCheck() // 마지막 편지를 보낸 날짜와 오늘 날짜를 비교하여 dateDifference를 출력

        if todayLetterUpdateTime != nil { // 편지를 보낸 적은 있음
            if todayLetterSend == 0 {
                // 편지를 마지막으로 보낸 일자가 오늘인 경우, writingVC로 이동 불가능
                // 아래의 alert 구현
                print("todayLetterUpdateTime2 (편지를 마지막으로 보낸 일자가 오늘인 경우, writingVC로 이동 불가능): \(todayLetterUpdateTime)")
                print("todayLetterSend: \(todayLetterSend)")
                alert(title: "오늘 이미 편지를 작성하셨어요!", message: "자정 이후에 다시 편지를 쓸 수 있어요", actionTitle: "확인")

            } else { // 편지를 마지막으로 보낸 일자가 오늘이 아닌 더 이전인 경우, writingVC로 이동 가능
                print("todayLetterUpdateTime3 (편지를 마지막으로 보낸 일자가 오늘이 아닌 더 이전인 경우, writingVC로 이동 가능): \(todayLetterUpdateTime)")
                print("todayLetterSend: \(todayLetterSend)")
                moveToWritingVC()
            }
        } else { // 편지를 보낸 적이 없으므로 nil이 출력되며, writingVC로 이동 가능
            moveToWritingVC()
        }
    }
    
    func moveToWritingVC() {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WritingViewController") as! WritingViewController
        let navigationController = UINavigationController(rootViewController: nextVC)
        self.show(nextVC, sender: nil)
    }
    
}

extension MainViewController : FBAdViewDelegate {
    
//    func adViewDidLoad(_ adView: FBAdView) {
//
//        // 광고 뷰를 앱의 뷰 계층에 추가
//        let screenHeight = view.bounds.height
//        let adViewHeight = adView.frame.size.height
//
//        //FBAdSettings.clearTestDevices()
//        print("adViewDidLoad 성공")
//        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
//        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
//        print("")
//        print("adView.isAdValid: \(adView.isAdValid)")
//        print("")
//        showAd()
//
//    }
//
//    // 배너 광고 불러오기 실패 시 호출되는 메서드
//    func adView(_ adView: FBAdView, didFailWithError error: Error) {
//        print("ArchiveVC 광고 불러오기 실패: \(error)")
//        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
//        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
//
//    }
//
//    func adViewDidClick(_ adView: FBAdView) {
//        print("adViewDidClick")
//    }
//
//    private func showAd() {
//      guard let adView = adView, adView.isAdValid else {
//        return
//      }
//        containerView.addSubview(adView)
//        containerView.bringSubviewToFront(adView)
//    }
}

extension UIViewController {
    
    func requestPermission() {
         if #available(iOS 14, *) {
             ATTrackingManager.requestTrackingAuthorization { status in
                 switch status {
                 case .authorized:
                     // Tracking authorization dialog was shown
                     // and we are authorized
                     print("Authorized")

                     // Now that we are authorized we can get the IDFA
                     print(ASIdentifierManager.shared().advertisingIdentifier)
                     FBAdSettings.setAdvertiserTrackingEnabled(true)
                 case .denied:
                     // Tracking authorization dialog was
                     // shown and permission is denied
                     print("Denied")
                     print(ASIdentifierManager.shared().advertisingIdentifier)
                     FBAdSettings.setAdvertiserTrackingEnabled(false)
                 case .notDetermined:
                     // Tracking authorization dialog has not been shown
                     //print("Not Determined")
                     DispatchQueue.main.async {
                         self.requestPermission()
                     }
                 case .restricted:
                     print("Restricted")
                 @unknown default:
                     print("Unknown")
                 }
             }
         }
     }
}
