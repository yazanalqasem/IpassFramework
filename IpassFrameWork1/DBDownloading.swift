//
//  DBDownloading.swift
//  IpassFrameWork1
//
//  Created by Mobile on 10/04/24.
//

import Foundation
import DocumentReader

public class DataBaseDownloading{

    public static func initialization(completion: @escaping (String, String, String) -> Void) {
        DocumentReaderService.shared.initializeDatabaseAndAPI(progress: { state in
            var progressValue = ""
            var status = ""
            var validationError = ""
            switch state {
            case .downloadingDatabase(progress: let progress):
                let progressString = String(format: "%.1f", progress * 100)
                progressValue = "Downloading database: \(progressString)%"
            case .initializingAPI:
                status = "Start Now"
                APIHandler.LoginAuthAPi()
            case .completed:
//                DispatchQueue.main.async {
//                StartFullProcess.fullProcessScanning(type: 0, controller: controller)
//                }
//
                break
            case .error(let text):
                validationError = text
                print(text)
            }
            
            completion(progressValue, status, validationError)
        })
    }
    
    
}
