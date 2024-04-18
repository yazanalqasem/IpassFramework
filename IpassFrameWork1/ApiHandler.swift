//
//  ApiHandler.swift
//  IpassFrameWork1
//
//  Created by Mobile on 10/04/24.
//

import Foundation
import SwiftUI

public class APIHandler {
    
    public static func LoginAuthAPi(email: String, password: String, completion: @escaping (Bool?, String?) -> Void){
        guard let apiURL = URL(string: "https://plusapi.ipass-mena.com/api/v1/ipass/create/authenticate/login") else { return }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
//        print("loginPostApi",apiURL)
//        print("login parameters",parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("Error serializing parameters: \(error.localizedDescription)")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let status = response.statusCode
            print("Response status code: \(status)")

            if status == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response",json)
                        if let user = json["user"] as? [String: Any] {
                            if let email = user["email"] as? String, let token = user["token"] as? String {
                                UserLocalStore.shared.token = token
                                completion(true, token)
                            } else {
                                completion(false, "Email or token not found in user dictionary")
                            }
                        } else {
                            completion(false, "User dictionary not found or is not of type [String: Any]")
                        }
                    } else {
                        completion(false, "Failed to parse JSON response")
                    }
                } catch let error {
                    completion(false, "Error parsing JSON response: \(error.localizedDescription)")
                }
            } else {
                completion(false, "Unexpected status code: \(status)")
            }
            
        }
        task.resume()
    }


    private static func createSessionApi(email:String,auth_token:String){
        guard let apiURL = URL(string: "https://plusapi.ipass-mena.com/api/v1/ipass/plus/face/session/create?token=eyJhbGciOiJIUzI1NiJ9.eW9wbWFpbDEyM0BnbWFpbC5jb21hZnNkIHNkZmEgICA2ODlmMDJhYy1iZGMwLTQ1YzAtOWVlNC04NDRmOGMzMGQ0YzU.LiGjDJwSjOAMBU-ssBA0DbYPlz_sPLexErz70hGCP6A") else { return }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict:[String:Any] = [:]
        let parameters: [String: Any] = [
            "email": email,
            "auth_token": auth_token
        ]

        print("url-> ", apiURL)
        print("parameters-> ", parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("Error serializing parameters: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let status = response.statusCode
            print("Response status code: \(status)")

            if status == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("createSessionApi response -->> ",json)
                        
                        if let sessionId = json["sessionId"] as? String {
                            UserLocalStore.shared.sessionId = sessionId
                            print("sessionId ------>> ",sessionId)
                        }
                        
                        presentSwiftUIView()
                        
                    } else {
                        print("Failed to parse JSON response")
                    }
                } catch let error {
                    print("Error parsing JSON response: \(error.localizedDescription)")
                }
            } else {
                print("Unexpected status code: \(status)")
            }
        }

        task.resume()
    }
    
    private static func presentSwiftUIView() {
        let swiftUIView = FaceLiveView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Present the SwiftUI view modally
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(hostingController, animated: true, completion: nil)
        }
    }
    
}

