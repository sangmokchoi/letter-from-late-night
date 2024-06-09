//
//  CustomizedCell.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/10.
//

import UIKit

class SecondView: UIView {
    
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
    
    func setupLayout(){
        let titleLabel1 = UILabel()
        titleLabel1.text = "바쁜 일상 때문에 숨겨왔던\n진심을 전해보세요."
        titleLabel1.font = UIFont(name: "NanumMyeongjoBold", size: 25)
        titleLabel1.textAlignment = .left
        titleLabel1.numberOfLines = 0
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel2 = UILabel()
        titleLabel2.text = "자정까지 편지를 쓰면\n새벽에 조용히 전달할게요.\n\n수정이나 회수가 어려우니\n한 글자씩 진심을 담아 적어주세요."
        titleLabel2.font = UIFont(name: "NanumMyeongjo", size: 18)
        titleLabel2.textAlignment = .left
        titleLabel2.numberOfLines = 0
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel1)
        addSubview(titleLabel2)

        
        NSLayoutConstraint.activate([
            titleLabel1.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -30),
            titleLabel1.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            
            titleLabel2.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -40),
            titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 10)
            
            
        ])
    }

}
