//
//  File.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/22.
//

import Foundation

{
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
    
    let inputUserEmail = appleIDCredential.email
    let fullName = appleIDCredential.fullName
    let familyName = fullName?.familyName
    let givenName = fullName?.givenName
    let inputUserName = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
    print("\(inputUserName)은 inputUserName")

    sendUserdata(inputUserName: inputUserName, inputUserEmail: inputUserEmail)
    
    Auth.auth().signIn(with: credential) { authResult, error in
        if let error = error {
            print("에러 발생: \(e.localizedDescription)")
            return
        }
        // Main 화면으로 보내기
        print("Successfully Signed Up!")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController")
        mainViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.show(mainViewController, sender: nil)
    }
    
}


{ user, error in
    if let error = error {
        print("ERROR", error.localizedDescription)
        return
    }
    
    guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
    guard let inputUserName = user?.profile?.name, let inputUserEmail = user?.profile?.email else { return }
    
    self.sendUserdata(inputUserName: inputUserName, inputUserEmail: inputUserEmail)
    
    //GIDSignIn을 통해 받은 idToken, accessToken으로 Firebase에 로그인
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
    // Access token을 부여받음
    
    // 사용자가 처음으로 로그인하면 신규 사용자 계정이 생성되고 사용자가 로그인할 때 사용한 사용자 인증 정보(사용자 이름과 비밀번호, 전화번호 또는 인증 제공업체 정보)에 연결됩니다. 이 신규 계정은 Firebase 프로젝트의 일부로 저장되며 사용자의 로그인 방법에 관계없이 프로젝트 내 모든 앱에서 사용자를 식별하는 데 사용될 수 있습니다.
    Auth.auth().signIn(with: credential) { _, _ in
        if let e = error {
            print(e.localizedDescription)
        } else {
            // navigate to the ChatViewController
            
            self.performSegue(withIdentifier: "signupToMain", sender: self)
        }
    }
}
