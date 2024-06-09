//
//  ConnectViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/23.
//

import UIKit
import Firebase

class ConnectViewController: SignupViewController {
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var connectStartButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        userNameColored()
    }
    
    func userNameColored(){
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("UserData").document(uid!).getDocument { (document, error) in
            if let document = document {
                if let data = document.data(){
                    let inputUserName = data["userName"] as! String
                    self.helloLabel.text = "안녕하세요! \(inputUserName)님"
                    self.helloLabel.asColor(targetStringList: [inputUserName], color: .purple)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      navigationController?.setNavigationBarHidden(true, animated: true) // 뷰 컨트롤러가 사라질 때 나타내기
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "connectToConnectTyping", sender: nil)
    }
}
