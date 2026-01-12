//
//  LoadingButton.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Reusable button with loading state
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .disabled(isLoading)
    }
}
