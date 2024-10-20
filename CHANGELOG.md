# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-10-20

### Added
- Allow custom storage for `lastHistoryToken`, in addition to iCloud and UserDefaults. (thanks JPToroDev!)
- Support Swift 6 concurrency. (thanks JPToroDev!)

## [1.1.0] - 2024-09-28

### Added
- add option to save the `lastHistoryToken` in iCloud instead of locally. (thanks JPToroDev!)

### Fixed
- fix PrivacyInfo.xcprivacy for spm

## [1.0.5] - 2023-08-19

### Added
- add privacy manifest PrivacyInfo.xcprivacy.

## [1.0.4] - 2023-08-12

### Fixed
- Fix test and raise minimum deployment target to iOS 15.

## [1.0.3] - 2022-11-08

### Fixed
- fix crash after second app open (1.0.2 regression).
- get changes on app/notifier start (e.g. if app was force-quit).

## [1.0.2] - 2022-09-29

### Fixed
- allow to include in code used by app extensions (fix #1).

## [1.0.1] - 2022-07-17

### Fixed
- ensure UIApplication.applicationState is used from the main thread.
- skip internal changes when later getting external changes.
- get contacts history in background thread.

## [1.0.0] - 2022-07-14

Initial release.
