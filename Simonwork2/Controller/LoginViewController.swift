//
//  WritingViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/09.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func emailLoginButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginToMain", sender: self)
    }
    
    @IBAction func googleLoginButton(_ sender: UIButton) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print("ERROR", error.localizedDescription)
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            // authentication에서 바로 가져오기
            // let idToken       = authentication.idToken
            let accessToken   = authentication.accessToken
            let refreshToken  = authentication.refreshToken
            let clientID      = authentication.clientID
            print("accessToken : \(accessToken)")
            print("refreshToken : \(refreshToken)")
            print("clientID : \(clientID)")
            
            //GIDSignIn을 통해 받은 idToken, accessToken으로 Firebase에 로그인
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // 사용자가 처음으로 로그인하면 신규 사용자 계정이 생성되고 사용자가 로그인할 때 사용한 사용자 인증 정보(사용자 이름과 비밀번호, 전화번호 또는 인증 제공업체 정보)에 연결됩니다. 이 신규 계정은 Firebase 프로젝트의 일부로 저장되며 사용자의 로그인 방법에 관계없이 프로젝트 내 모든 앱에서 사용자를 식별하는 데 사용될 수 있습니다.
            Auth.auth().signIn(with: credential) { result, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    // navigate to the ChatViewController
                    print("Successfully Loged In!")
                    self.performSegue(withIdentifier: "loginToMain", sender: self)
                }
            }
        }
    }
    
    @IBAction func appleLoginButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginToMain", sender: self)
    }
}





