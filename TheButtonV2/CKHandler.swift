//
//  CKHandler.swift
//  TheButtonV2
//
//  Created by Zac Holland on 6/28/17.
//  Copyright © 2017 Diericx. All rights reserved.
//

import Foundation
import CloudKit

typealias UpdateRecordCallback = ()  -> Void
typealias UploadRecordCallback = (CKRecord)  -> Void
typealias ErrorCallback = (Error) -> Void
typealias GetRecordCallback = (CKRecord) -> Void

class CKHandler {
    
    static let container = CKContainer.default()
    static let publicDB = CKHandler.container.publicCloudDatabase
    static let privateDB = CKHandler.container.privateCloudDatabase
    
    init () {
        
    }
    
    static func GetRecordById(recordID: CKRecordID, onComplete:@escaping GetRecordCallback ) {
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID, completionHandler: { record, error in
            
            guard let record = record else {
                print("Error fetching record: ")
                return
            }
            
            onComplete(record)
            
        })

    }
    
    static func UpdateRecordWithRecordID(recordID: CKRecordID, key: String, value: CKRecordValue, onComplete:@escaping UpdateRecordCallback, onFetchError:@escaping ErrorCallback, onUpdateError:@escaping ErrorCallback) {
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID, completionHandler: { record, error in
            if let fetchError = error {
                print("An error occurred fetching record in \(fetchError)")
                onFetchError(error!)
            } else {
                // Modify the record
                record?.setObject(value, forKey: key)
                
                //Save Modified record
                CKContainer.default().publicCloudDatabase.save(record!, completionHandler: { record, error in
                    if let saveError = error {
                        print("An error occurred while updating record in \(saveError)")
                        //TODO - add error message
                        onUpdateError(error!)
                    } else {
                        // Saved record
                        print("Updated Record With Cloudkit.")
                        onComplete()
                    }
                })
            }
        })
    }
    
    static func UploadNewRecord(record: CKRecord, onComplete:@escaping UploadRecordCallback, onUploadError:@escaping ErrorCallback) {
        let modifyRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: [record],
            recordIDsToDelete: nil)
        
        modifyRecordsOperation.timeoutIntervalForRequest = 10
        modifyRecordsOperation.timeoutIntervalForResource = 10
        
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) -> Void in
            guard let record = record else {
                print("Error saving record: ", error)
                onUploadError(error!)
                return
            }
            onComplete(record)

        }
    }
    
    static func GetLatestWinnerButton(recordName: String, onComplete: @escaping GetRecordCallback ) {
        var recordID: CKRecordID = CKRecordID(recordName: recordName)
        CKHandler.GetRecordById(
            recordID: recordID,
            onComplete: { (record: CKRecord) in
                onComplete(record)
            }
        )
    }
    
    static func GetMostRecentWinImg(onComplete:@escaping GetRecordCallback) {
        //set query
        let query = CKQuery(recordType: "Image", predicate: NSPredicate(value: true))
        
        //execute query
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil){
            (records, error) in
            if error != nil {
                print("error fetching winner image record\(error)")
                
            } else {
                print("fetched winner image records.")
                if (records?.count == 0) {
                    //No record
                    print("No WImage record!")
                } else {
                    print("Got WImage record!")
                    onComplete(records![0])
                }
            }
        }
    }
    
    static func UpdateWinImg (data: Data, onComplete:@escaping UploadRecordCallback) {
        
        //set query
        let query = CKQuery(recordType: "Image", predicate: NSPredicate(value: true))
        
        //execute query
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil){
            (records, error) in
            if error != nil {
                print("error fetching winner button record\(error)")
                //TODO - display error, couldn't fetch
                //create record for image record name
                let newRecord:CKRecord = CKRecord(recordType: "Image")
                newRecord.setValue(data, forKey: "Image")
                
                CKHandler.UploadNewRecord(
                    record: newRecord,
                    onComplete: { (record: CKRecord) in
                        print("Successfully saved new Image record!")
                        onComplete(record)
                    },
                    onUploadError: { (error: Error) in
                        //TODO - Show pop up saying we couldnt upload image for some reason
                    }
                );
                
            } else {
                print("fetched winner button records.")
                if (records?.count == 0) {
                    //Create new record
                    print("Creating new WImage record...")
                    let newRecord:CKRecord = CKRecord(recordType: "Image")
                    newRecord.setValue(data, forKey: "Image")
                    
                    CKHandler.UploadNewRecord(
                        record: newRecord,
                        onComplete: { (record: CKRecord) in
                            onComplete(record)
                        },
                        onUploadError: { (error: Error) in
                            //TODO - Show pop up saying we couldnt upload image for some reason
                        }
                    );
                } else {
                    print("Updating WImage record...")
                    UpdateRecordWithRecordID(
                        recordID: records![0].recordID,
                        key: "Image",
                        value: data as CKRecordValue,
                        onComplete: { () in
                            onComplete(records![0])
                        },
                        onFetchError: { (error: Error) in
                            //TODO - error fetching
                        },
                        onUpdateError: { (error: Error) in
                            //TODO - error updating
                        }
                    );
                }
            }
        }

    }
}
