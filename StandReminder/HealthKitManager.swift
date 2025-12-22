import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    private let standDataType = HKQuantityType.quantityType(forIdentifier: .appleStandTime)!
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit不可用")
            return
        }
        
        let typesToWrite: Set<HKSampleType> = [standDataType]
        let typesToRead: Set<HKObjectType> = [standDataType]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    print("HealthKit授权失败: \(error)")
                }
            }
        }
    }
    
    func recordStandActivity(duration: TimeInterval) {
        guard isAuthorized else { return }
        
        let quantity = HKQuantity(unit: HKUnit.minute(), doubleValue: duration / 60)
        let sample = HKQuantitySample(
            type: standDataType,
            quantity: quantity,
            start: Date().addingTimeInterval(-duration),
            end: Date()
        )
        
        healthStore.save(sample) { success, error in
            if success {
                print("成功记录站立活动到HealthKit")
            } else if let error = error {
                print("记录站立活动失败: \(error)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let status = healthStore.authorizationStatus(for: standDataType)
        isAuthorized = status == .sharingAuthorized
    }
}