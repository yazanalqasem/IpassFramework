//
//  FaceLiveView.swift
//  IpassFrameWork1
//
//  Created by Vishal on 18/04/24.
//

import SwiftUI
@_implementationOnly import FaceLiveness

struct FaceLiveView: View {
    @State private var isPresentingLiveness = true
    
    @State private var sessionIdStr: String = ""
    
    var body: some View {
        
       Text(sessionIdStr)
        .onAppear {
            sessionIdStr = UserLocalStore.shared.sessionId
            print("sessionIdStr--->> ", sessionIdStr)
        }
        
        FaceLivenessDetectorView(
            sessionID: sessionIdStr,
            region: "",
            isPresented: $isPresentingLiveness,
            onCompletion: { result in
                switch result {
                case .success:
                    print("success")
                case .failure(let error):
                    print("error")
                    print(error.localizedDescription)
                }
            }
        )
    }
}
