//
//  WritingViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/09.
//

import UIKit
import Firebase
import EmojiPicker
import GoogleMobileAds
import FBAudienceNetwork

extension UITextView {
    func alignTextVerticallyInContainer() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.contentInset.top = topCorrect
    }
}

class LetterViewController: UIViewController {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var letterBg: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var receivedTitleText: String?
    var receivedContentText: String?
    var receivedUpdateDate: Date?
    var receivedLetterColor : String?
    var receivedEmoji : String?
    
    var adView: FBAdView!
    lazy var containerView: UIView = {
        
        let height = 250
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(view.frame.width), height: height))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        
        return containerView
    }()
    
    // Create right UIBarButtonItem.
    lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(editButtonPressed))
        button.tag = 2
        
        return button
    }()

// Button event.
    @objc private func editButtonPressed(_ sender: Any) {
        if let button = sender as? UIBarButtonItem {
            switch button.tag {
            case 2:
                // Change the background color to red.
                self.view.backgroundColor = .red
                // 12시 이전에 수정 버튼 클릭 시 메시지가 수정되는 기능 구현 필요
            default:
                print("error")
            }
        }
    }
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        //f.timeStyle = .short
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(containerView)
        adView = FBAdView(placementID: Constants.FacebookAds.LetterVC, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
        adView.loadAd()
        
        configure()
        titleLabel.text = ""
        contentTextView.text = ""
        
        self.contentTextView.alignTextVerticallyInContainer()
        // 배너 광고 설정
        setupBannerViewToBottom(adUnitID: Constants.GoogleAds.normalBanner)
    }
    
    private func configure() {
        NSLayoutConstraint.activate([
            emojiLabel.bottomAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        titleLabel.font = UIFont(name: "NanumMyeongjoBold", size: 20)
        contentTextView.font = UIFont(name: "NanumMyeongjo", size: 17)
        
        titleLabel.numberOfLines = 3
        
        titleLabel.text = receivedTitleText
        contentTextView.text = receivedContentText
        
        dateLabel.text = formatter.string(from: receivedUpdateDate ?? Date())
        letterBg.backgroundColor = UIColor(hex: receivedLetterColor!)
        
        //setupEmoji()
        emojiLabel.text = receivedEmoji!

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //removeAdView()
    }
}

extension LetterViewController : FBAdViewDelegate {
    
//    func adViewDidLoad(_ adView: FBAdView) {
//
//        // 광고 뷰를 앱의 뷰 계층에 추가
//        let screenHeight = view.bounds.height
//        let adViewHeight = adView.frame.size.height
//
//        print("adViewDidLoad 성공")
//        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
//
//        requestPermission()
//
//        //showAd()
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
//    func removeAdView() {
//        self.adView = nil // 광고 객체 해제
//        print("removeAdView 진입")
//    }
//
//    private func showAd() {
//      guard let adView = adView, adView.isAdValid else {
//        return
//      }
//        containerView.addSubview(adView)
//    }
}
