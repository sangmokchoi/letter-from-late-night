//
//  SettingViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/24.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMobileAds
import FirebaseCore
import FirebaseAuth
import FirebaseOAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import AuthenticationServices
import CryptoKit
import FBAudienceNetwork
import AcknowList

fileprivate var currentNonce: String?

extension UIViewController {
    func alert(title: String, message: String, actionTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    func moveToMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "SecondNavigationController")
        mainViewController.modalPresentationStyle = .fullScreen
        self.show(mainViewController, sender: nil)
    }
    
    func moveToSignup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "NavigationController")
        mainViewController.modalPresentationStyle = .fullScreen
        self.show(mainViewController, sender: nil)
    }
}

extension SettingViewController {
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // request 요청을 했을 때 none가 포함되어서 릴레이 공격을 방지
        // 추후 파베에서도 무결성 확인을 할 수 있게끔 함
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

extension SettingViewController: ASAuthorizationControllerDelegate {
    // controller로 인증 정보 값을 받게 되면은, idToken 값을 받음
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorizationController 출력")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        // nonce : 암호화된 임의의 난수, 단 한번만 사용 가능
        // 동일한 요청을 짧은 시간에 여러번 보내는 릴레이 공격 방지
        // 정보 탈취 없이 안전하게 인증 정보 전달을 위한 안전장치 // 안전하게 인증 정보를 전달하기 위해 nonce 사용
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return }
        
        //MARK: - 유저 개인 정보 (최초 회원가입 시에만 유저 정보를 얻을 수 있으며, 2회 로그인 시부터는 디코딩을 통해 이메일만 추출 가능. 이름은 불가)
        // token들로 credential을 구성해서 auth signin 구성 (google과 동일)
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        print("credential: \(credential)")
        
        if let fullName = appleIDCredential.fullName, let familyName = fullName.familyName, let givenName = fullName.givenName, let email = appleIDCredential.email {
            //inputUserName = (fullName.familyName)!+" "+(fullName.givenName)!
            inputUserName = fullName.givenName!
            inputUserEmail = email
        } else {
            inputUserName = "사용자"
            inputUserEmail = "No Email"
        }
        
        Auth.auth().currentUser?.reauthenticate(with: credential) { result, error  in
            if let error = error {
                print("reauthenticate error: \(error)")
            } else {
                print("User re-authenticated. result: \(String(describing: result))")
                if let user = Auth.auth().currentUser {
                    if let uid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid"),
                       let friendCode = UserDefaults.shared.string(forKey: "friendCode") {
                        self.deleteLetterData(friendCode: friendCode)
                        self.deleteUserData(uid: uid)
                    }
                    self.moveToSignup()
                }
            }
        }
        print("애플 로그인")
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {
        // Handle error.
    }
}

extension SettingViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

class SettingViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nicknameChangeTextField: UITextField!
    @IBOutlet weak var nicknameChangeButton: UIButton!
    @IBOutlet weak var emailChangeLabel: UILabel!
    @IBOutlet weak var emailChangeButton: UIButton!
    
    @IBOutlet weak var nicknameChangeLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var manualButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var legalButton: UIButton!
    @IBOutlet weak var ossButton: UIButton!
    
    @IBOutlet weak var myFriendCodeLabel: UILabel!
    @IBOutlet weak var myFriendCode: UILabel!
    @IBOutlet weak var quitButton: UIButton!
    
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
        adView = FBAdView(placementID: Constants.FacebookAds.SettingVC, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
        adView.loadAd()
        
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        let providerId = user?.providerData.first?.providerID
        print("providerId: \(providerId)")
        
        nicknameChangeTextField.autocorrectionType = .no
        nicknameChangeTextField.spellCheckingType = .no
        // 배너 광고 설정
        setupBannerViewToBottom(adUnitID: Constants.GoogleAds.admobBanner)
        viewChange()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAdView()
    }
    
    func viewChange() {
        
        let userName = UserDefaults.shared.string(forKey: "userName")!
        //userNameLabel.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 25)
        userNameLabel?.text = "\(userName)님 안녕하세요"
        userNameLabel?.asColor(targetStringList: [userName], color: .purple)
        
        let userFriendCode = UserDefaults.shared.string(forKey: "friendCode")!
        myFriendCode?.text = userFriendCode
    }
    
    @IBAction func changeNicknameButtonPressed(_ sender: UIButton) {
        // 닉네임 변경 수정 버튼 클릭 시
        let userName = UserDefaults.shared.string(forKey: "userName") ?? ""
        let userUid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid") ?? ""
        let userPairFriendCode = UserDefaults.shared.string(forKey: "pairFriendCode") ?? ""
        
        let inputNewNickname = nicknameChangeTextField.text
        if inputNewNickname != nil {
            
            let sheet = UIAlertController(title: "\(inputNewNickname!)", message: "입력하신 닉네임으로 변경할까요?", preferredStyle: .alert)
            let change = UIAlertAction(title: "변경", style: .default, handler: { _ in
                // 유저의 userName 변경
                db.collection("UserData").document(userUid).updateData([
                    "userName" : inputNewNickname!
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        self.alert(title: "닉네임 변경 실패", message: "서버 정보를 불러오지 못했어요",  actionTitle: "확인")
                    } else {
                        print("유저의 userName 변경")
                        self.alert(title: "닉네임 변경 완료", message: "\(inputNewNickname!)으로 닉네임을 변경했어요",  actionTitle: "확인")
                        UserDefaults.shared.set(inputNewNickname, forKey: "userName")
                        
                        // 유저와 연결된 친구의 friendName 변경을 위해 유저의 pairFriendcode로 문서 이름 가져오기
                        db.collection("UserData").whereField("friendCode", isEqualTo: userPairFriendCode).getDocuments() { (querySnapshot, error) in
                            if let error = error {
                                print("error: \(error)")
                                self.alert(title: "정보 불러오기 실패", message: "연결된 친구의 정보를 불러오지 못했어요",  actionTitle: "확인")
                            } else {
                                var userPairFriendUid = "not read"
                                if let documents = querySnapshot?.documents {
                                    for document in documents {
                                        // 문서 이름은 연결된 친구의 uid와 일치하므로 userPairFriendUid 변수에 저장
                                        userPairFriendUid = document.documentID
                                    }
                                }
                                db.collection("UserData").document(userPairFriendUid).updateData(["friendName" : inputNewNickname!]){ err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                        self.alert(title: "변경 오류", message: "연결된 상대방에게 변경된 닉네임으로 나타나지 않아요",  actionTitle: "확인")
                                    } else {
                                        print("연결된 친구의 friendName 변경")
                                        self.alert(title: "변경 완료", message: "연결된 상대방에게도 변경된 닉네임으로 나타나요",  actionTitle: "확인")
                                    }
                                }
                            }
                        }
                    }
                }
                
                let changeDone = UIAlertController(title: "닉네임 변경", message: "완료되었습니다", preferredStyle: .alert)
                let copyLink = UIAlertAction(title: "확인", style: .default)
                changeDone.addAction(copyLink)
                self.present(changeDone, animated: true)
                
            })
            let close = UIAlertAction(title: "아니오", style: .destructive, handler: { _ in
                print("no 클릭")
            })
            sheet.addAction(change)
            sheet.addAction(close)
            self.present(sheet, animated: true)
            
            DispatchQueue.main.async { // '보내기' 이후 title, content 내용 초기화
                self.nicknameChangeTextField.text = ""
            }
        }
    }
    
    @IBAction func emailChangeButtonPressed(_ sender: UIButton) {
        
        let userEmail = UserDefaults.shared.string(forKey: "userEmail")!
        let uid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid")!
        let placeholder = userEmail
        
        let alertController = UIAlertController(title: "변경할 이메일을 입력해주세요", message: "애플 로그인의 경우, 이메일 수집이 되지 않았을 수 있습니다", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "현재 이메일: \(userEmail)" // 텍스트 필드의 플레이스홀더를 현재 유저의 이메일로 설정
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            // 취소 액션 처리
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            
            if let textField = alertController.textFields?.first, let inputText = textField.text {
                
                if inputText != nil && inputText.contains("@") {
                    db.collection("UserData").document(uid).updateData(
                        ["userEmail" : inputText]){ err in
                            if let err = err {
                                print("Error updating document: \(err)")
                                self.alert(title: "변경 오류", message: "이메일 변경에 실패했어요",  actionTitle: "확인")
                            } else {
                                print("이메일 변경 완료")
                                UserDefaults.shared.set(inputText, forKey: "userEmail")
                                self.alert(title: "변경 완료", message: "이메일이 변경되었습니다.",  actionTitle: "확인")
                            }
                        }
                } else {
                    self.alert(title: "이메일 형식이 유효하지 않습니다", message: "올바른 이메일 형식으로 입력해주세요", actionTitle: "확인")
                    DispatchQueue.main.async {
                        textField.text = ""
                    }
                }
            }
        }
        
        alertController.addAction(okAction)
        
        // Alert 창 표시
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func manualButtonPressed(_ sender: UIButton) {
        // 웹페이지 이동
        if let url = URL(string: "https://sites.google.com/view/aletterfromlatenight/%ED%99%88") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func disconnectWIthFriendButtonPressed(_ sender: UIButton) {
        // 친구와 연결 끊기 버튼 클릭
        // 나의 pairFriendCode 초기화
        let alertController = UIAlertController(title: "친구와 연결을 끊을까요?", message: "상대방에게는 알리지 않을게요", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default) { _ in
            print("확인 클릭")
            
            let myUid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid")!
            db.collection("UserData").document(myUid).updateData(
                ["pairFriendCode" : "no pairFriendCode",
                 "connectedTime" : Date() - (24 * 60 * 60)]
            ) // DB 상 나의 pairFriendCode, connectedTime 초기화
            
            { (err) in // 나의 UserData에서 pairFriendCode를 inputPairFriendCode로 업데이트
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    UserDefaults.shared.setValue("no pairFriendCode", forKey: "pairFriendCode") // UserDefaults의 pairFriendCode 초기화
                    UserDefaults.shared.setValue(Date() - (24 * 60 * 60), forKey: "connectedTime")
                    
                    self.moveToSignup()
                }
            }
        }
        alertController.addAction(action1)
        let action2 = UIAlertAction(title: "취소", style: .destructive)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        // 로그아웃 버튼 클릭
        // 구글로 로그인했는지, 애플로 로그인했는지 구분해서, if 문을 통한 로그아웃을 구현해야함.
        // 유저가 어떤 소셜 로그인을 이용했는지 확인
        let signupVC = SignupViewController()
        let alertController = UIAlertController(title: "로그아웃 하시겠어요?", message: "로그인 화면으로 이동할게요", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default) { [self] _ in
            print("확인 클릭")
            
            if let currentUser = Auth.auth().currentUser {
                if let providerID = currentUser.providerData.first?.providerID {
                    // 저장된 userDefaults 모두 삭제
                    removeUserDefaultsData()
                    
                    if providerID == "apple.com" {
                        // 애플 계정으로 로그인한 경우
                        print("유저가 애플 계정으로 로그인함")
                        // 애플 로그아웃
                        signupVC.removeAppleLoggedIn()
                    } else if providerID == "google.com" {
                        // 구글 계정으로 로그인한 경우
                        print("유저가 구글 계정으로 로그인함")
                        // 구글 로그아웃
                        GIDSignIn.sharedInstance.signOut()
                        GIDSignIn.sharedInstance.disconnect()
                    }
                }
            }
            
            let firebaseAuth = Auth.auth()
            print("firebaseAuth: \(firebaseAuth)")
            do {
                try firebaseAuth.signOut()
                print("로그아웃 성공")
                self.moveToSignup()
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        alertController.addAction(action1)
        let action2 = UIAlertAction(title: "취소", style: .destructive)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
    }
    
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        // 웹페이지 이동
        if let url = URL(string: "https://sites.google.com/view/aletterfromlatenight-policy/%ED%99%88") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func legalButtonPressed(_ sender: UIButton) {
        // 웹페이지 이동
        if let url = URL(string: "https://sites.google.com/view/aletterfromlatenight-privacy/%ED%99%88") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func ossButtonPressed(_ sender: UIButton) {
        
        let acknowList = AcknowListViewController(fileNamed: "Pods-Mug-Lite-acknowledgements")
        acknowList.modalPresentationStyle = .automatic
        acknowList.title = "오픈소스 라이센스"
    
    
        let doneButton = acknowList.navigationItem.leftBarButtonItem
        doneButton?.tintColor = UIColor.blue
        
                // 새 네비게이션 컨트롤러로 감싸서 모달로 표시
                let navController = UINavigationController(rootViewController: acknowList)
                self.present(navController, animated: true, completion: nil)

    }
    
    @IBAction func quitButtonPressed(_ sender: UIButton) {
        // 회원 탈퇴 버튼
        let signupVC = SignupViewController()
        AuthAction = "reauthenticate"
        let alertController = UIAlertController(title: "탈퇴하시겠어요?", message: "회원 정보가 삭제되면 복구할 수 없어요", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default) { _ in
            print("확인 클릭")
            if let currentUser = Auth.auth().currentUser {
                if let providerID = currentUser.providerData.first?.providerID {
                    
                    let alertController = UIAlertController(title: "회원 탈퇴 작업을 진행합니다", message: "로그인 재인증 작업이 발생할 수 있습니다", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "확인", style: .default) { _ in
                        
                        if providerID == "apple.com" {
                            // 애플 계정으로 로그인한 경우
                            print("유저가 애플 계정으로 로그인함")
                            
                            // credential 추출
                            self.startSignInWithAppleFlow()
                            
                            // 애플 로그아웃
                            signupVC.removeAppleLoggedIn()
                            
                        } else if providerID == "google.com" {
                            // 구글 계정으로 로그인한 경우
                            print("유저가 구글 계정으로 로그인함")
                            
                            // credential 추출
                            self.googleAuthenticate()
                            
                            // 구글 로그아웃
                            GIDSignIn.sharedInstance.signOut()
                            GIDSignIn.sharedInstance.disconnect()
                        }
                        
                    }
                    alertController.addAction(action1)
                    let action2 = UIAlertAction(title: "취소", style: .destructive)
                    alertController.addAction(action2)
                    self.present(alertController, animated: true)
                }
            }
        }
        alertController.addAction(action1)
        let action2 = UIAlertAction(title: "취소", style: .destructive)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
    }
    
    func deleteLetterData(friendCode: String) {
        db.collection("LetterData").whereField("sender", isEqualTo: friendCode).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("  deleteLetterData error: \(error)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        print("deleteLetterData doc: \(doc)")
                        doc.reference.delete() { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Letter deleted successfully")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteUserData(uid: String) {
        
        db.collection("UserData").document(uid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                removeUserDefaultsData()
            }
        }
    }
    
    func googleAuthenticate() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { (user, error) in
            // 구글로 로그인 승인 요청
            if let error = error {
                print("googleSignIn ERROR", error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            inputUserName = (user?.profile?.givenName)!
            inputUserEmail = (user?.profile?.email)!
            
            //GIDSignIn을 통해 받은 idToken, accessToken으로 Firebase에 로그인
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken) // Access token을 부여받음
            
            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error  in
                if let error = error {
                    print("reauthenticate error: \(error)")
                    AuthAction = "signIn"
                } else {
                    print("User re-authenticated. result: \(String(describing: result))")
                    if let user = Auth.auth().currentUser {
                        if let uid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid"), let friendCode = UserDefaults.shared.string(forKey: "friendCode") {
                            self.deleteLetterData(friendCode: friendCode)
                            self.deleteUserData(uid: uid)
                        }
                    }
                    AuthAction = "signIn"
                    self.moveToSignup()
                }
            }
            print("구글 로그인")
        }
    }
    
}

extension SettingViewController : FBAdViewDelegate {
    
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
    
    func removeAdView() {
        self.adView = nil // 광고 객체 해제
        print("removeAdView 진입")
    }

    private func showAd() {
      guard let adView = adView, adView.isAdValid else {
        return
      }
        containerView.addSubview(adView)
    }
}
