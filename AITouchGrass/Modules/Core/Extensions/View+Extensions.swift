//
//  View+Extensions.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI

extension View {
    /// Apply loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
        )
    }
    
    /// Apply error alert
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert(
            "Error",
            isPresented: .constant(error.wrappedValue != nil),
            presenting: error.wrappedValue
        ) { _ in
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    /// Apply custom alert
    func customAlert(config: Binding<AlertConfiguration?>) -> some View {
        self.alert(
            config.wrappedValue?.title ?? "",
            isPresented: .constant(config.wrappedValue != nil),
            presenting: config.wrappedValue
        ) { config in
            if let primaryAction = config.primaryAction {
                Button(primaryAction.title, role: primaryAction.role) {
                    primaryAction.action()
                }
            }
            
            if let secondaryAction = config.secondaryAction {
                Button(secondaryAction.title, role: secondaryAction.role) {
                    secondaryAction.action()
                }
            }
        } message: { config in
            if let message = config.message {
                Text(message)
            }
        }
    }
    
    /// Hide keyboard
    func hideKeyboard() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    /// Apply corner radius with border
    func cardStyle(cornerRadius: CGFloat = 16, borderColor: Color = .gray.opacity(0.15)) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 0.5)
            )
    }
    
    /// Apply gradient card style
    func gradientCardStyle(gradient: LinearGradient? = nil, cornerRadius: CGFloat = 16) -> some View {
        let defaultGradient = LinearGradient(
            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(gradient ?? defaultGradient)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
    }
}