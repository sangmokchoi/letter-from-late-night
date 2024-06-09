//
//  SecondViewController.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/04/06.
//

import UIKit

// UINavigationController를 상속하는 커스텀 클래스를 작성
class SecondNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]

    }
}
