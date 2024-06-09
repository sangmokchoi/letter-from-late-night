//
//  CustomizedCell.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/10.
//

import UIKit

class FirstView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        // xibSetup() // 하면 storyboard에서 실시간(컴파일타임)에 inspector창에서 변경해도 확인 불가
    }
    
    private func setupLayout() {
        let titleLabel1 = UILabel()
        titleLabel1.text = "하루 한 번의 진심,\n밤편지"
        titleLabel1.font = UIFont(name: "NanumMyeongjo", size: 35)
        titleLabel1.textAlignment = .right
        titleLabel1.numberOfLines = 2
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchScreen")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel2 = UILabel()
        titleLabel2.text = "정성 가득한 편지를 쓴 건\n언제가 마지막인가요?"
        titleLabel2.font = UIFont(name: "NanumMyeongjo", size: 25)
        titleLabel2.textAlignment = .left
        titleLabel2.numberOfLines = 0
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel1)
        addSubview(imageView)
        addSubview(titleLabel2)
        
        NSLayoutConstraint.activate([
            titleLabel1.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 5),
            titleLabel1.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -7),
            imageView.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: -30),
            
            titleLabel2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            titleLabel2.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10)
        ])
    }
}
