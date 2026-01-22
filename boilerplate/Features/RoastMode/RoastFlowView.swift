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
    
    // Create view models at this level to persist across navigation
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var imageRoastViewModel = ImageRoastViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mode Selection Screen
                RoastModeSelectionView(selectedMode: $selectedMode)
                
                // Navigation to Text Roast
                NavigationLink(
                    destination: HomeView(viewModel: homeViewModel),
                    tag: RoastMode.text,
                    selection: $selectedMode
                ) {
                    EmptyView()
                }
                .hidden()
                
                // Navigation to Image Roast
                NavigationLink(
                    destination: ImageRoastView(viewModel: imageRoastViewModel),
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
