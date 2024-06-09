//
//  ConnectViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/23.
//

import UIKit

class StartViewController: UIViewController {
    
    let mainVC = MainViewController()
    
    @IBOutlet weak var helloLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userName : String = UserDefaults.shared.object(forKey: "userName") as! String
        helloLabel?.text = "환영합니다! \(userName)님"
        helloLabel?.asColor(targetStringList: [userName], color: .purple)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true) // 뷰 컨트롤러가 사라질 때 나타내기
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        moveToMain()
    }
}
