//
//  LetterData.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/20.
//

import Foundation
import UIKit

struct LetterData {
    let sender : String // (친구 코드)
    let senderName : String // (나의 이름)
    let receiver : String // (상대방 친구 코드)
    let id : String = "" // (편지 아이디)
    let title : String // (편지 제목)
    let content : String// (편지 내용)
    let updateTime : Date // (작성 시간)
    let receiveTime : Date = Date() // (수신 시간)
    let letterColor : String // (편지지 컬러)
    // let font : String // (편지지 폰트(미정)
    let emoji : String// (이모티콘)

}
