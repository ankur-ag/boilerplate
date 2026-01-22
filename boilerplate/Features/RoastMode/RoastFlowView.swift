//
//  RoastFlowView.swift
//  boilerplate
//
//  Manages navigation between mode selection and roast screens
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct RoastFlowView: View {
    @State private var selectedMode: RoastMode?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mode Selection Screen
                RoastModeSelectionView(selectedMode: $selectedMode)
                
                // Navigation to Text Roast
                NavigationLink(
                    destination: HomeView(),
                    tag: RoastMode.text,
                    selection: $selectedMode
                ) {
                    EmptyView()
                }
                .hidden()
                
                // Navigation to Image Roast
                NavigationLink(
                    destination: ImageRoastView(),
                    tag: RoastMode.image,
                    selection: $selectedMode
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

#Preview {
    RoastFlowView()
        .environmentObject(LLMManager())
        .environmentObject(ImageGenerationManager())
        .environmentObject(AuthManager())
}
