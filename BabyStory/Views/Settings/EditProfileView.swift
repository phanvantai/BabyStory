//
//  EditProfileView.swift
//  BabyStory
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct EditProfileView: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      ZStack {
        AppGradientBackground()
        
        VStack(spacing: 20) {
          Text("Edit Profile")
            .font(.largeTitle)
            .fontWeight(.bold)
          
          Text("Coming Soon!")
            .font(.title2)
            .foregroundColor(.secondary)
          
          Text("Profile editing functionality will be available in a future update.")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") {
            dismiss()
          }
          .buttonStyle(SecondaryButtonStyle())
        }
      }
    }
  }
}

#Preview {
    EditProfileView()
}
