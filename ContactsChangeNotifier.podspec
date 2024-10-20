Pod::Spec.new do |s|

  s.name         = 'ContactsChangeNotifier'
  s.version      = '1.2.0'
  s.summary      = 'Which contacts changed outside your iOS app? Better CNContactStoreDidChange notification: get real changes, without the noise.'
  s.homepage     = 'https://github.com/yonat/ContactsChangeNotifier'
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }

  s.author             = { 'Yonat Sharon' => 'yonat@ootips.org' }

  s.platform     = :ios, '15.0'
  s.swift_versions = ['5.0']

  s.source       = { :git => 'https://github.com/yonat/ContactsChangeNotifier.git', :tag => s.version }
  s.source_files  = 'Sources/ContactStoreChangeHistory/*.{h,m}', 'Sources/ContactsChangeNotifier/**/*.swift'
  s.resource_bundles = {s.name => ['Sources/ContactsChangeNotifier/PrivacyInfo.xcprivacy']}

end
