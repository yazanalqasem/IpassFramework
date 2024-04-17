//
//  ApiHandler.swift
//  IpassFrameWork1
//
//  Created by Mobile on 10/04/24.
//

import Foundation


public class APIHandler {
    
    public static func LoginAuthAPi() {
        guard let apiURL = URL(string: "https://plusapi.ipass-mena.com/api/v1/ipass/create/authenticate/login") else { return }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "email": "ipassmobile@yopmail.com",
            "password": "Admin@123#"
        ]
        print("loginPostApi",apiURL)
        print("login parameters",parameters)
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
                        print("Response",json)
                        if let user = json["user"] as? [String: Any] {
                            if let email = user["email"] as? String, let token = user["token"] as? String {
                                UserLocalStore.shared.token = token
                            } else {
                                print("Email or token not found in user dictionary")
                            }
                        } else {
                            print("User dictionary not found or is not of type [String: Any]")
                        }
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


    
}

