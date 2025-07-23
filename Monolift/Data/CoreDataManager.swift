import Foundation
import CoreData
import CloudKit

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "WorkoutDataModel")
        
        // Configure for CloudKit
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // CloudKit configuration  
        storeDescription?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.samhren.Monolift")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Enable automatic merging of changes from CloudKit
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Watch for remote changes
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { _ in
            self.objectWillChange.send()
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - CloudKit Status
    func checkCloudKitStatus() async {
        do {
            let status = try await CKContainer(identifier: "iCloud.com.samhren.Monolift").accountStatus()
            switch status {
            case .available:
                print("CloudKit available")
            case .noAccount:
                print("No iCloud account")
            case .restricted:
                print("iCloud account restricted")
            case .couldNotDetermine:
                print("Could not determine iCloud status")
            case .temporarilyUnavailable:
                print("iCloud temporarily unavailable")
            @unknown default:
                print("Unknown CloudKit status")
            }
        } catch {
            print("Failed to check CloudKit status: \(error)")
        }
    }
}