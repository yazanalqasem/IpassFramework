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
    
    var body: some View {
        FaceLivenessDetectorView(
            sessionID: "",
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
