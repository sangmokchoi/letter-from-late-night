//
//  TabBarController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/04/06.
//

import UIKit

// UITabBarController를 상속하는 커스텀 클래스를 작성
class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            let tabOne = UINavigationController(rootViewController: MainViewController()) // 네비게이션 컨트롤러 없는 뷰컨트롤러
            let tabTwo = UINavigationController(rootViewController: ArchiveViewController()) // 뷰컨 품은 네비게이션 컨트롤러
            let tabThree = UINavigationController(rootViewController: SentLetterViewController())

            self.viewControllers = [tabOne, tabTwo, tabThree]
        }
}
