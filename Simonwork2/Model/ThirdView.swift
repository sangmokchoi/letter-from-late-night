//
//  CustomizedCell.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/10.
//

import UIKit

class ThirdView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    @IBOutlet weak var toSignupButton: UIButton!
    //toSignupButton.layer.cornerRadius = 10
    
    @IBAction func ToSignup(_ sender: UIButton) {
        
    }
    
    func setupLayout() {
        
        let titleLabel1 = UILabel()
        titleLabel1.text = "꼭! 배경화면에 위젯을\n설정하고 확인해주세요"
        titleLabel1.font = UIFont(name: "NanumMyeongjoBold", size: 25)
        titleLabel1.textAlignment = .left
        titleLabel1.numberOfLines = 0
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel2 = UILabel()
        titleLabel2.text = "오늘의 기쁨, 내일의 행운을 담아\n상대방에게 전달해볼까요?"
        titleLabel2.font = UIFont(name: "NanumMyeongjo", size: 20)
        titleLabel2.textAlignment = .left
        titleLabel2.numberOfLines = 0
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "widget exmple2")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel1)
        addSubview(titleLabel2)
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            titleLabel1.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -38),
            titleLabel1.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            
            titleLabel2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -20),
            titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 25),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -250),
            imageView.topAnchor.constraint(equalTo: titleLabel2.bottomAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 5000),
            imageView.heightAnchor.constraint(equalToConstant: 1275),
        ])
    }
}
