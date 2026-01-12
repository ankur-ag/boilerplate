//
//  PrimaryButton.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Primary branded button style
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isDisabled ? Color.gray : Color.accentColor)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}
