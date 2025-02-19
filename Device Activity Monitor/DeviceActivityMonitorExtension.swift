////
////  DeviceActivityMonitorExtension.swift
////  Device Activity Monitor
////
////  Created by Gursewak Singh on 27/09/24.
////
//
//import DeviceActivity
//import FamilyControls
//import ManagedSettings
//
//// Optionally override any of the functions below.
//// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
//class DeviceActivityMonitorExtension: DeviceActivityMonitor {
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//        print("did start")
//        print(#function)
//    }
//
//    override func intervalDidEnd(for activity: DeviceActivityName) {
//        super.intervalDidEnd(for: activity)
//        let store = ManagedSettingsStore()
//        store.clearAllSettings()
//        print(#function)
//
//        // Handle the end of the interval.
//    }
//
//    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventDidReachThreshold(event, activity: activity)
//        print(#function)
//
//        // Handle the event reaching its threshold.
//    }
//
//    override func intervalWillStartWarning(for activity: DeviceActivityName) {
//        super.intervalWillStartWarning(for: activity)
//        print(#function)
//
//        // Handle the warning before the interval starts.
//    }
//
//    override func intervalWillEndWarning(for activity: DeviceActivityName) {
//        super.intervalWillEndWarning(for: activity)
//        print(#function)
//
//        // Handle the warning before the interval ends.
//    }
//
//    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventWillReachThresholdWarning(event, activity: activity)
//        print(#function)
//        // Handle the warning before the event reaches its threshold.
//    }
//}
