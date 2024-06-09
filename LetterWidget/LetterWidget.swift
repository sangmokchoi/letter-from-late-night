//
//  LetterWidget.swift
//  LetterWidget
//
//  Created by daelee on 2023/04/01.
//

import Foundation
import WidgetKit
import SwiftUI
import UIKit
import Firebase

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.Simonwork2"
        return UserDefaults(suiteName: appGroupId)!
    }
}

extension Provider {
    //func updateWidget() {
    func updateWidget(completion: @escaping ([String : Any]) -> Void) {
        let db = Firestore.firestore()
        let userFriendCode : String = UserDefaults.shared.object(forKey: "friendCode") as! String
        let userPairFriendCode : String = UserDefaults.shared.object(forKey: "pairFriendCode") as! String
        
        let calendar = Calendar.current
        let currentDate = Date()
        let todayMidnight = calendar.startOfDay(for: currentDate)
        let timeStamp = Timestamp(date: todayMidnight)
        
        db.collection("LetterData")
            .whereField("sender", isEqualTo: userPairFriendCode)
            .whereField("receiver", isEqualTo: userFriendCode)
            .whereField("updateTime", isLessThan: timeStamp)
            .order(by: "updateTime", descending: true)
            .limit(to: 1)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageTitle = data["title"] as? String,
                               let message_UpdateTime = data["updateTime"] as? Timestamp {
                                
                                let messageUpdateTime = message_UpdateTime.dateValue()
                                let messageContent = data["content"] as! String
                                let messageSenderName = data["senderName"] as! String
                                let messageLetterColor = data["letterColor"] as! String
                                let messageEmoji = data["emoji"] as! String
                                
                                UserDefaults.shared.set(messageTitle, forKey: "latestTitle")
                                UserDefaults.shared.set(messageContent, forKey: "latestContent")
                                UserDefaults.shared.set(messageUpdateTime, forKey: "latestUpdateDate")
                                UserDefaults.shared.setValue(messageLetterColor, forKey: "latestLetterColor")
                                UserDefaults.shared.set(messageEmoji, forKey: "latestEmoji")
                                UserDefaults.shared.set(messageSenderName, forKey: "latestSenderName")
                                
                                WidgetCenter.shared.reloadAllTimelines()
                                
                                completion(data)
                                
                            }
                        }
                    }
                }
            }
    }
}
let dateFormatterFile = DateFormatterFile()

var setTitle = UserDefaults.shared.string(forKey: "latestTitle") ?? "첫 편지가 아직 도착하지 않았네요"
var setContent = UserDefaults.shared.string(forKey: "latestContent") ?? "조금만 더 기다려볼까요?"
var setUpdateDate = UserDefaults.shared.object(forKey: "latestUpdateDate") as? Date ?? Date()
var setLetterColor = UserDefaults.shared.string(forKey: "latestLetterColor") ?? "F7D88C"
var setEmoji = UserDefaults.shared.string(forKey: "latestEmoji") ?? "no emoji"
var uicolor = UIColor(hex: setLetterColor)
var setSenderName = UserDefaults.shared.string(forKey: "latestSenderName") ?? "상대방"
var setFriendName = UserDefaults.shared.string(forKey: "friendName") ?? "상대방"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), updateDate: Date(), title: "Placeholder Title", content: "Placeholder Content", emoji: "😃", sender: "Sender")
    }
    // 데이터를 가져와서 표출해주는 함수
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry: SimpleEntry
        
        switch context.family {
        case .systemSmall:
            entry = SimpleEntry(date: Date(), updateDate: Date(), title: "밥은 잘 챙겨먹은거지?", content: "오늘 하루도 화이팅!", emoji: "😃", sender: "하나뿐인 사람")
        case .systemMedium:
            entry = SimpleEntry(date: Date(), updateDate: Date(), title: "밥은 잘 챙겨먹은거지?", content: "바쁘더라도 끼니 굶지 말고\n몸 잘 챙겨 가면서 해\n오늘 하루도 화이팅!", emoji: "😃", sender: "하나뿐인 사람")
        case .systemLarge:
            entry = SimpleEntry(date: Date(), updateDate: Date(), title: "밥은 잘 챙겨먹은거지?", content: "바쁘더라도 끼니 굶지 말고\n몸 잘 챙겨가면서 해\n\n어제 만났을 때 보니깐 너무 피곤해보였어\n\n점심시간에 눈도 잠깐 붙이면서 쉬엄쉬엄해~\n\n오늘 하루도 화이팅!", emoji: "😃", sender: "하나뿐인 사람")
        @unknown default:
            entry = SimpleEntry(date: Date(), updateDate: Date(), title: "밥은 잘 챙겨먹은거지?", content: "오늘 하루도 화이팅!", emoji: "😃", sender: "하나뿐인 사람")
        }
        completion(entry)
    }
    
    // 타임라인 설정 관련 함수(홈에 있는 위젯을 언제 업데이트 시킬 것인지 구현)
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        let calendar = Calendar.current
        //let set1am = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 1, minute: 0), matchingPolicy: .nextTime)!
        
        if setEmoji == "no emoji" {
            let placeHolder = SimpleEntry(date: Date(), updateDate: Date(), title: setTitle, content: setContent, emoji: "😃", sender: setFriendName)
            let timeline0 = Timeline(entries: [placeHolder], policy: .atEnd)
            completion(timeline0)
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            let updateNowEntry = SimpleEntry(date: currentDate, updateDate: setUpdateDate, title: setTitle, content: setContent, emoji: setEmoji, sender: setSenderName)
            entries.append(updateNowEntry)
            
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
            let components = DateComponents(hour: 1)
            let date0 = calendar.date(byAdding: .hour, value: 1, to: Date())!
            let tomorrow1AM = calendar.nextDate(after: tomorrow, matching: components, matchingPolicy: .nextTime)!
            
            let timeline = Timeline(entries: entries, policy: .after(date0))
            // let timeline = Timeline(entries: entries, policy: .after(tomorrow1AM)) // 새벽 한 시에 타임라인이 재실행됨
            completion(timeline)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let updateDate: Date
    let title: String
    let content: String
    let emoji: String
    let sender: String
}

struct LetterWidgetEntryView : View { // 위젯의 내용물을 보여주는 SwiftUI View
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        switch self.family {
        case .systemSmall:
            VStack {
                Text(entry.title)
                    .font(.custom("NanumMyeongjoBold", size: 11))
                    .foregroundColor(.black)
                    .padding(0.1)
                Spacer()
                Text(entry.content)
                    .font(.custom("NanumMyeongjo", size: 10))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Spacer()
            }.padding()
                .onTapGesture {
                    // 위젯 클릭 시 호출되는 함수
                    WidgetCenter.shared.reloadAllTimelines()
                    print("타임라인 새로고침 완료")
                }
        case .systemMedium :
            VStack {
                HStack{
                    Text(entry.emoji)
                        .font(.custom("NanumMyeongjo", size: 25))
                    Text(entry.title)
                        .font(.custom("NanumMyeongjoBold", size: 15))
                        .foregroundColor(.black)
                    Spacer()
                }.padding(1)
                Spacer()
                Text(entry.content)
                    .font(.custom("NanumMyeongjo", size: 12))
                    .foregroundColor(.black)
                    .padding(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack(alignment: .bottom){
                    Spacer()
                    Text(entry.sender)
                        .font(.custom("NanumMyeongjoBold", size: 10))
                        .foregroundColor(.black)
                    Text(dateFormatterFile.dateFormatting(date: entry.updateDate)) // entry.date를 string으로 변환
                        .font(.custom("NanumMyeongjo", size: 10))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .onTapGesture {
                // 위젯 클릭 시 호출되는 함수
                WidgetCenter.shared.reloadAllTimelines()
                print("타임라인 새로고침 완료")
            }
        case .systemLarge :
            VStack {
                HStack{
                    Text(entry.emoji)
                        .font(.custom("NanumMyeongjoExtraBold", size: 40))
                    Text(entry.title)
                        .font(.custom("NanumMyeongjoBold", size: 20))
                        .foregroundColor(.black)
                }.padding(3)
                Spacer()
                Text(entry.content)
                    .font(.custom("NanumMyeongjo", size: 17))
                    .foregroundColor(.black)
                    .padding(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack(alignment: .bottom){
                    Spacer()
                    Text(entry.sender)
                        .font(.custom("NanumMyeongjoBold", size: 15))
                        .foregroundColor(.black)
                    Text(dateFormatterFile.dateFormatting(date: entry.updateDate)) // entry.date를 string으로 변환
                        .font(.custom("NanumMyeongjo", size: 15))
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            .onTapGesture {
                // 위젯 클릭 시 호출되는 함수
                WidgetCenter.shared.reloadAllTimelines()
                print("타임라인 새로고침 완료")
            }
        default:
            Text("default")
        }
    }
}

struct LetterWidget: Widget {
    let kind: String = "LetterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            // 위젯 ID.
            provider: Provider()
            // 위젯 생성자.
            // 위젯을 새로고침할 타임라인을 결정하고 생성하는 객체입니다. 위젯 업데이트를 위한 시간을 지정해주면 알아서 그 시간에 맞춰서 업데이트를 시켜준다고 합니다.
        ) { entry in LetterWidgetEntryView(entry: entry)
                .onTapGesture {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.init(uiColor: (uicolor)!))
            //.background(Color.init(uiColor: (UIColor(hex: "F7D88C"))!))
            //.background(Color.init(uiColor: (uicolor ?? UIColor(hex: "F7D88C"))!)) // 위젯의 배경색상 가져오기
        }
        .configurationDisplayName("밤편지")
        .contentMarginsDisabled()
        .description("원하는 사이즈의 위젯을 선택해주세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct LetterWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let entry = SimpleEntry(date: Date(), updateDate: Date(), title: "밥은 잘 챙겨먹었어?", content: "오늘 하루도 화이팅!", emoji: "😃", sender: "하나뿐인 사람")
    }
}
