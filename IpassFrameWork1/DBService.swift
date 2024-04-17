//
//  DBService.swift
//  IpassFrameWork1
//
//  Created by Mobile on 10/04/24.
//

import Foundation
import DocumentReader

final class DocumentReaderService {
    let kRegulaLicenseFile = "iPass.license"
    let kRegulaDatabaseId = "Full"
    
    enum State {
        case downloadingDatabase(progress: Double)
        case initializingAPI
        case completed
        case error(String)
    }

    static let shared = DocumentReaderService()
    private init() { }

    func deinitializeAPI() {
        DocReader.shared.deinitializeReader()
    }

    
    func initializeDatabaseAndAPI(progress: @escaping (State) -> Void) {
        
        guard let licensePath = Bundle(for: type(of: self)).path(forResource: kRegulaLicenseFile, ofType: nil) else {
            progress(.error("Missing License File in Framework Bundle"))
            return
        }
        
        guard let licenseData = try? Data(contentsOf: URL(fileURLWithPath: licensePath)) else {
            progress(.error("Unable to read License File"))
            return
        }

        DispatchQueue.global().async {
            DocReader.shared.prepareDatabase(
                databaseID: self.kRegulaDatabaseId,
                progressHandler: { (inprogress) in
                    progress(.downloadingDatabase(progress: inprogress.fractionCompleted))
                },
                completion: { (success, error) in
                    if let error = error, !success {
                        progress(.error("Database error: \(error.localizedDescription)"))
                        return
                    }
                    let config = DocReader.Config(license: licenseData)
                    DocReader.shared.initializeReader(config: config, completion: { (success, error) in
                        DispatchQueue.main.async {
                            progress(.initializingAPI)
                            if success {
                                progress(.completed)
                            } else {
                                progress(.error("Initialization error: \(error?.localizedDescription ?? "nil")"))
                                
                            }
                        }
                    })
                }
            )
        }
        
    }
}

