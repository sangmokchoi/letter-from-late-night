//
//  SignupProcess.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/21.
//

import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseOAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import AuthenticationServices
import CryptoKit

fileprivate var currentNonce: String?

let db = Firestore.firestore() //initialize Cloud Firestore
var userdata: [UserData] = []

extension SignupViewController {
    
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
    
    private func sha256(_ input: String) -> String {
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
    
    func sendUserdata(inputUserName: String?, inputUserEmail: String?) {
        
        if let inputUserName, let inputUserEmail {
            db.collection("UserData").addDocument(data: [
                "userName": inputUserName,
                "userEmail": inputUserEmail,
                "friendCode": "none",
                "pairFriendCode": "none",
                "signupTime": Date().timeIntervalSince1970,
                "letterCount": 0
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                }
            }
            if Auth.auth().currentUser != nil {
                print(" User is signed in.")
                //                let userInfo = Auth.auth().currentUser?.providerData[indexPath.row]
                //                cell?.textLabel?.text = userInfo?.providerID
                //                // Provider-specific UID
                //                cell?.detailTextLabel?.text = userInfo?.uid
            } else {
                print(" User is not signed in.")
                // ...
            }
        } else { // Apple 로그인 시 이메일을 가린 유저. 별도의 닉네임 생성이 필요
            print("Apple 로그인 시 이메일을 가린 유저 입니다. 별도의 닉네임 생성이 필요합니다.")
            db.collection("UserData").addDocument(data: [
                "userName": inputUserName,
                "userEmail": inputUserEmail,
                "friendCode": "none",
                "pairFriendCode": "none",
                "signupTime": Date().timeIntervalSince1970,
                "letterCount": 0
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                }
            }
            if Auth.auth().currentUser != nil {
                print(" User is signed in.")
                // ...
            } else {
                print(" User is not signed in.")
                // ...
            }
        }
    }
}

extension SignupViewController: ASAuthorizationControllerDelegate {
    
    // controller로 인증 정보 값을 받게 되면은, idToken 값을 받음
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
        // No user is signed in.
        let givenName = appleIDCredential.fullName?.givenName
        let familyName = appleIDCredential.fullName?.familyName
        let inputUserEmail = appleIDCredential.email
        let inputUserName = "\(givenName) \(familyName)"
        
        sendUserdata(inputUserName: inputUserName, inputUserEmail: inputUserEmail)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print ("Error Apple sign in: %@", error)
                return
            }
            // Main 화면으로 보내기
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController")
            mainViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.show(mainViewController, sender: nil)
        }
    
        if Auth.auth().currentUser != nil { // User is signed in.
            // Reauthenticate current Apple user with fresh Apple credential.
            Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
              guard error != nil else {
              // Apple user successfully re-authenticated.
                self.performSegue(withIdentifier: "signupToMain", sender: self)
                return }
            }
        }
    }
}

extension SignupViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
