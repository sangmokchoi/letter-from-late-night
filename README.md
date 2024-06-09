# 밤편지: 마음을 주고받는 편지 한 통


</br>



## 00. 개요

- **개발 기간:** 2023.03 - 2023.05

- **Github:** [https://github.com/SimonWork-co/letter-from-late-night](https://github.com/SimonWork-co/letter-from-late-night)

- **App Store:** [<밤편지> 다운로드 바로가기 ](https://apps.apple.com/kr/app/밤편지-마음을-주고-받는-편지-한-통/id6448700074)

  

- 기술 구조 요약
  - **UI:** UIKit, SwiftUI(위젯), Storyboard
  - **Communication:** Jira, Confluence
  - **Architecture**: MVC
  - **Data Storage**: Firebase, UserDefaults
  - **Library/Framework:** GoogleMobileAds, GoogleSignIn, AuthenticationServices, CryptoKit, UserNotifications, EmojiPicker, BackgroundTasks 등

</br>

## 01. 밤편지 소개 및 기능


<aside>
💡 밤편지는 커플끼리 하루에 한 통, 위젯으로 편지를 주고받는 IOS 어플리케이션 입니다.


</aside>

- 친구코드를 입력해 상대방과 1:1로 편지를 주고받을 수 있습니다.
- 자정 전까지 하루에 한 번 보낼 수 있는 편지는 수정과 취소가 불가능 합니다.
  - 마치 우체통에 넣은 손편지처럼요.
- 작성한 편지는 별도의 알림없이 새벽 5시, 상대방의 위젯에 업데이트 됩니다.
- 텍스트로만 마음을 전달하기 부족하다면, 이모지를 활용할 수 있습니다.

</br>


## 02. 구현 사항

| 2.1. Apple, Google 로그인<br /><br />![login-start](https://github.com/SimonWork-co/letter-from-late-night/assets/37580034/b50008fe-60bb-4eb4-ba53-1f9d2f158cd7) | - FirebaseGoogleAuthUI 및 AuthenticationServices 를 사용해 구글 / 애플 로그인을 구현했습니다. <br />- 난수를 생성하는 CryptoKit 프레임워크로 유저의 로그인 데이터를 보호합니다. |
| :----------------------------------------------------------: | ------------------------------------------------------------ |
| **2.2. 친구코드 입력 후 1:1 페어링** <br /><br />![pairing](https://github.com/SimonWork-co/letter-from-late-night/assets/37580034/cb706e32-73dc-4859-a08d-7f07cae15120) | **- UserDefaults에 저장된 친구코드를 이용해 페어링을 지원합니다. <br />- 두 명의 유저가 서로의 친구코드를 입력하면 페어링이 완료되고 그때부터 앱을 사용할 수 있습니다.** |
| **2.3. 편지지 색상, 이모지 선택**<br /><br />![send-letter](https://github.com/SimonWork-co/letter-from-late-night/assets/37580034/1f97de6d-bd9c-4112-a4b3-5d2b5f6fdd18) | **- 위젯 사이즈에 맞춰 글자수를 제한합니다. <br />- 편지지의 색상과 이모지를 선택할 수 있습니다. <br />- EmojiPicker라는 오픈소스 라이브러리를 사용했습니다.** |
| **2.4. 위젯으로 상대방 편지 수신<br /><br />**![widget](https://github.com/SimonWork-co/letter-from-late-night/assets/37580034/70c226f9-1de2-4317-a633-bffea201e564) | **- small, medium, large 사이즈의 위젯을 지원합니다. <br />- 수신한 편지는 매일 아침 위젯에 자동으로 업데이트 됩니다. <br />- 위젯을 구현하기 위해 swiftUI를 사용했습니다.** |



</br>

## 03. **핵심경험**


### 3.1. **UserDefaults**

앱이 종료되어도 유지되는 사용자 기본 설정들은 UserDefaults 인터페이스로 관리합니다. 편지를 수신하고 답장하지 않는 유저에게 푸쉬알림을 보내기 위해 유저 정보, 편지 정보를 저장했으며 마지막으로 받은 편지의 정보(제목, 내용, 받은 시간, 편지지 색상, 이모지, 보낸사람 데이터)를 저장해 위젯을 업데이트 하기 전 매번 UserDefaults를 확인했습니다.

### 3.2. 구조에 대한 고민, **UIKit + MVC + SwiftUI**

필요한 화면이 많지 않고 각 화면에 들어가는 정보도 많지 않아 storyboard로 개발을 해도 무리가 없을 것이라고 생각했습니다. 따라서 가장 익숙한 구조인 MVC 패턴으로 개발을 진행했습니다. 만약 ViewController가 길어지거나, 뷰와 데이터 관련 로직들의 결합도가 높아지는 문제가 생긴다면 MVVC 모델을 고민했을 것 같습니다. 

CodeBased UI의 장점도 함께 공부했습니다. 빌드 및 실행 속도가 빨라진다는 것을 알게 됐고, snapKit 라이브러리를 사용하면 인터페이스 구현에 비해 코드 양이 많아지는 단점을 해결할 수 있음을 배웠습니다. swift를 활용한 iOS 개발이 처음이라 스토리보드를 사용했지만, 다음 개발에는 다양한 시도를 해볼 것 같습니다.

<밤편지>의 핵심 기능인 위젯을 사용하기 위해서는 WidgetKit 으로 개발을 진행해야 했습니다. 위젯은 swiftUI로만 개발이 가능해서, UIKit 프로젝트에 swiftUI 코드를 일부 넣었습니다.

### 3.3. 라이브러리 사용

이모지 기능을 넣기 위해 [EmojiPicker 라이브러리](https://github.com/htmlprogrammist/EmojiPicker)를 사용했습니다. dependency 관리를 위해CocoaPods을 사용했습니다. 



</br>



## 04. 기술 스택

**Back**

`Firebase`

`Google Analytics`

**Front**

`Swift` 

`UIKit`

`SwiftUI`

`Figma`

**Communication**

`Github`

`Jira`

`Confluence`
