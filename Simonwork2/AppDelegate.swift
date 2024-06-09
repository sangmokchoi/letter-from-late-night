//
//  AppDelegate.swift
//  Simonwork2
//
//  Created by Sangmok Choi on 2023/03/08.
//
//http://yoonbumtae.com/?p=5329 (Swift(스위프트): 백그라운드 작업 (Background Tasks))
//https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/using_background_tasks_to_update_your_app

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import BackgroundTasks
import CryptoKit
import WidgetKit
import GoogleMobileAds
import FBAudienceNetwork
import AdSupport

import UserNotifications

import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // 1. didFinishLaunchingWithOptions: 앱이 종료되어 있는 경우 알림이 왔을 때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        GADMobileAds.sharedInstance().start { status in
            // Optional: Log each adapter's initialization latency.
            let adapterStatuses = status.adapterStatusesByClassName
            for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                      adapterStatus.description, adapterStatus.latency)
            }
            
            // Start loading ads here...
        }
        FBAdSettings.clearTestDevices()
        
        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        // Pass user's consent after acquiring it. For sample app purposes, this is set to YES.
        //FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        // 앱 푸시 상태를 확인하는 함수
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkNotificationSetting),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        
        UNUserNotificationCenter.current().delegate = self
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.simonwork.Simonwork2.refresh_badge", using: DispatchQueue.global()) { task in
            print("백그라운드 등록 진입")
            task.setTaskCompleted(success: true)
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.simonwork.Simonwork2.refresh_process", using: DispatchQueue.global()) { task in
            print("백그라운드 등록 진입")
            task.setTaskCompleted(success: true)
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }
        
        sleep(1)
        
        return true
    }
    
    @objc private func checkNotificationSetting() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { permission in
                print("add observer 진입")
                switch permission.authorizationStatus  {
                case .authorized:
                    print("사용자가 앱의 알림 권한을 허용한 상태입니다. 이 경우, 앱은 알림을 전송할 수 있고, 사용자에게 알림을 표시할 수 있습니다.")
                    NotificationCenter.default.removeObserver(self)
                case .denied:
                    print("사용자가 앱의 알림 권한을 거부한 상태입니다. 이 경우, 앱은 알림을 전송할 수 없고, 알림 설정에서 변경을 요청하는 사용자를 안내해야 합니다.")
                    let sendUserNotification = SendUserNotification()
                    sendUserNotification.requestNotificationAuthorization()
                    NotificationCenter.default.removeObserver(self)
                case .notDetermined:
                    print("사용자가 아직 앱의 알림 권한에 대한 결정을 내리지 않은 상태입니다. 이 경우, 알림 권한을 요청하기 전에 사용자에게 알림 권한에 대한 안내를 표시할 수 있습니다.")
                    NotificationCenter.default.removeObserver(self)
                case .provisional:
                    print("iOS 12부터 도입된 권한 상태로, 사용자가 앱의 알림 권한에 대한 최초의 응답을 기다리는 동안에 사용됩니다. 사용자가 알림을 허용하지 않아도 앱은 일부 알림을 받을 수 있습니다.")
                    NotificationCenter.default.removeObserver(self)
                case .ephemeral:
                    // @available(iOS 14.0, *)
                    print(" iOS 15부터 도입된 권한 상태로, 앱의 알림이 사용자의 알림 센터에 표시되지 않는 상태입니다.")
                    NotificationCenter.default.removeObserver(self)
                @unknown default:
                    print("푸시 Unknow Status")
                    NotificationCenter.default.removeObserver(self)
                }
            }
    }
    
    //2. 스케줄링
    func scheduleAppRefresh() {
        print("백그라운드 스케줄링 진입")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.simonwork.Simonwork2.refresh_badge")
        let userTimeZone = TimeZone.current
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(in: userTimeZone, from: now)
        let currentDate = calendar.date(from: components)!
        let currentHour = components.hour!
        
        var nextExecutionTime = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: currentDate)! // 태스크 시작 시간
        var endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: currentDate)! // 태스크 마지막 시간
        
        if currentHour < 1 {
        } else {
            nextExecutionTime = calendar.date(byAdding: .hour, value: 24, to: nextExecutionTime)!
            endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: nextExecutionTime)!
        }
        
        if now >= endTime { // 현재 시간이 태스크 마지막 시간을 지났으므로 종료
            return
        } else {
            let requestInterval: TimeInterval = 30 * 60 // 30분 간격 예약
            while nextExecutionTime < endTime { // nextExecutionTime은 30분씩 점점 커지게 됨
                let request = BGProcessingTaskRequest(identifier: "com.simonwork.Simonwork2.refresh_badge")
                request.earliestBeginDate = nextExecutionTime
                
                do {
                    try BGTaskScheduler.shared.submit(request)
                    print("scheduleAppRefresh // Scheduled task for \(request)")
                } catch {
                    print("Could not schedule processing task: \(error)")
                }
                nextExecutionTime = nextExecutionTime.addingTimeInterval(requestInterval)
            }
        }
    }
    
    func scheduleProcessingTaskIfNeeded() {
        print("scheduleProcessingTaskIfNeeded 진입")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.simonwork.Simonwork2.refresh_process")
        
        let userTimeZone = TimeZone.current
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(in: userTimeZone, from: now)
        let currentDate = calendar.date(from: components)!
        let currentHour = components.hour!
        
        var nextExecutionTime = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: currentDate)! // 태스크 시작 시간
        var endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: currentDate)! // 태스크 마지막 시간
        
        if currentHour < 1 {
        } else {
            nextExecutionTime = calendar.date(byAdding: .hour, value: 24, to: nextExecutionTime)!
            endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: nextExecutionTime)!
        }
        
        if now >= endTime { // 현재 시간이 태스크 마지막 시간을 지났으므로 종료
            return
        } else {
            let requestInterval: TimeInterval = 60 * 60 // 60분 간격 예약
            while nextExecutionTime < endTime { // nextExecutionTime은 60분씩 점점 커지게 됨
                let request = BGProcessingTaskRequest(identifier: "com.simonwork.Simonwork2.refresh_process")
                request.requiresExternalPower = false
                request.requiresNetworkConnectivity = false
                request.earliestBeginDate = nextExecutionTime
                
                do {
                    try BGTaskScheduler.shared.submit(request)
                    print("scheduleProcessingTaskIfNeeded // Scheduled task for \(request)")
                } catch {
                    print("Could not schedule processing task: \(error)")
                }
                nextExecutionTime = nextExecutionTime.addingTimeInterval(requestInterval)
            }
        }
        
    }
    func handleAppRefresh(task: BGAppRefreshTask) {
        // 스케줄링 함수. 다음 동작 수행, 반복시 필요
        print("실행 완료 진입")
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            // 가벼운 백그라운드 작업 작성
            print("메시지 로드 진입")
            self.updateWidget()
            WidgetCenter.shared.reloadAllTimelines()
            
            task.setTaskCompleted(success: true)
        }
    }
    
    // 3.실행&완료
    func handleProcessingTask(task: BGProcessingTask) {
        print("실행 완료 진입")
        scheduleProcessingTaskIfNeeded()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        DispatchQueue.global(qos: .userInteractive).async {
            // 가벼운 백그라운드 작업 작성
            print("메시지 로드 진입")
            self.updateWidget()
            task.setTaskCompleted(success: true)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BGTaskScheduler.shared.getPendingTaskRequests { (requests) in
            for request in requests {
                print("Pending task: \(request.identifier)")
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try Auth.auth().useUserAccessGroup("sangmok Choi.group.Simonwork2")
        } catch let error as NSError {
            print("Error changing user access group: %@", error)
        }
        setupAndMigrateFirebaseAuth()
    }
    
    // 2. didReceive: 백그라운드인 경우 & 사용자가 푸시를 클릭한 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        
        //앱이 켜져있는 상태에서 푸쉬 알림을 눌렀을 때
        if application.applicationState == .active {
            print("푸쉬알림 탭(앱 켜져있음)")
        }
        
        //앱이 꺼져있는 상태에서 푸쉬 알림을 눌렀을 때
        if application.applicationState == .inactive {
            print("푸쉬알림 탭(앱 꺼져있음)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(identifier: "SignupViewController")
            mainViewController.modalPresentationStyle = .fullScreen
            NavigationController().show(mainViewController, sender: self)
        }
        completionHandler()
    }
    
    // 3. willPresent: 앱이 실행 중인 경우 (foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) { // ios14에서 .alert가 사라졌기 때문에 list, banner를 함께 넣어줘야함
            completionHandler([.alert, .list,.sound,.banner])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func setupAndMigrateFirebaseAuth() {
        let BuildEnvironmentAppGroup = "group.Simonwork2"
        guard Auth.auth().userAccessGroup != BuildEnvironmentAppGroup else { return }
        //for extension (widget) we want to share our auth status
        do {
            //get current user (so we can migrate later)
            let user = Auth.auth().currentUser
            //switch to using app group
            try Auth.auth().useUserAccessGroup(BuildEnvironmentAppGroup)
            //migrate current user
            if let user = user {
                Auth.auth().updateCurrentUser(user) { error in
                    if error == nil {
                        print ("Firebase Auth user migrated")
                    }
                }
            }
        } catch let error as NSError {
            print("error: \(error)")
        }
        
    }
    
}


extension AppDelegate {
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
    }
    
}
