# Uncomment the next line to define a global platform for your project
platform :ios, '16.2'

target 'Simonwork2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Simonwork2
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseAnalytics'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Auth'
  pod 'Firebase/Core'
  pod 'FirebaseUI/Google'
  pod 'GoogleSignIn'
  pod 'Google-Mobile-Ads-SDK'
  # pod 'FBAudienceNetwork'
  pod 'GoogleMobileAdsMediationFacebook'
  # pod 'FBSDKCoreKit', '~> 8.0.0'
  # pod 'FBSDKLoginKit', '~> 8.0.0'
  # pod 'FBSDKShareKit', '~> 8.0.0'
  # pod 'FBSDKGamingServiceKit', '~> 8.0.0'
  pod 'AcknowList'
  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              #config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
           end
      end
  end
  end
  pod 'EmojiPicker', :git => 'https://github.com/htmlprogrammist/EmojiPicker'
  
  target 'LetterWidgetExtension' do
    pod 'FirebaseAuth'
    pod 'FirebaseFirestore'
    pod 'FirebaseUI'
    pod 'FirebaseUI/Auth'
    pod 'Firebase/Core'
    pod 'FirebaseMessaging'
    end
end
