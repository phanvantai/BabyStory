//
//  ProfileSummaryRow.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 29/5/25.
//

import SwiftUI

struct ProfileSummaryRow: View {
  let icon: String
  let label: String
  let value: String
  
  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(.blue)
        .font(.subheadline)
        .frame(width: 20)
      
      Text(label)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
      
      Spacer()
      
      Text(value)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    // Child profile information examples
    ProfileSummaryRow(
      icon: "person.fill",
      label: "Child's Name",
      value: "Emma"
    )
    
    ProfileSummaryRow(
      icon: "calendar",
      label: "Age",
      value: "5 years old"
    )
    
    ProfileSummaryRow(
      icon: "heart.fill",
      label: "Favorite Character",
      value: "Princess"
    )
    
    ProfileSummaryRow(
      icon: "book.fill",
      label: "Reading Level",
      value: "Beginner"
    )
    
    ProfileSummaryRow(
      icon: "moon.stars.fill",
      label: "Story Length",
      value: "5 minutes"
    )
    
    ProfileSummaryRow(
      icon: "paintbrush.fill",
      label: "Favorite Theme",
      value: "Fantasy Adventure"
    )
    
    ProfileSummaryRow(
      icon: "clock.fill",
      label: "Bedtime",
      value: "8:00 PM"
    )
  }
  .padding()
  .background(Color(.systemGroupedBackground))
}
