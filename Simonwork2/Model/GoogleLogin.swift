//
//  GoogleLogin.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/05/09.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseOAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import AuthenticationServices
import CryptoKit

struct GoogleLogin {
    
    func googleSignIn() {
        
        let settingVC = SettingViewController()
        let signupVC = SignupViewController()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: signupVC) { (user, error) in
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
            
            if AuthAction == "signIn" {
                Auth.auth().signIn(with: credential) { result, error in
                    if let e = error {
                        print(e.localizedDescription)
                    } else {
                        let uid = Auth.auth().currentUser!.uid
                        signupVC.loadUserData(userName: inputUserName, userEmail: inputUserEmail)
                    }
                    return
                }
            } else if AuthAction == "reauthenticate" {
                Auth.auth().currentUser?.reauthenticate(with: credential) { result, error  in
                    if let error = error {
                        print("reauthenticate error: \(error)")
                        AuthAction = "signIn"
                    } else {
                        print("User re-authenticated. result: \(String(describing: result))")
                        let user = Auth.auth().currentUser

                        user?.delete { error in
                            if let error = error {
                                print("error: \(error)")
                            } else {
                                // Account deleted.
                                print("탈퇴 완료")
                                // UserData 내에서 해당 유저의 정보 삭제
                                let uid = UserDefaults.shared.string(forKey: "ALetterFromLateNightUid")!
                                let friendCode = UserDefaults.shared.string(forKey: "friendCode")!
                                
                                settingVC.deleteLetterData(friendCode: friendCode)
                                settingVC.deleteUserData(uid: uid)
                                
                                signupVC.moveToSignup()
                            }
                        }
                        AuthAction = "signIn"
                    }
                  }
            }
            print("구글 로그인")
        }
    }
}
