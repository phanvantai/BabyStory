//
//  EditProfileParentNamesInput.swift
//  BabyStory
//
//  Created by Tai Phan Van on 30/5/25.
//

import SwiftUI

struct EditProfileParentNamesInput: View {
  @ObservedObject var viewModel: EditProfileViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "figure.2.and.child.holdinghands")
          .foregroundColor(.orange)
          .font(.title3)
        Text("Parent Names")
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        
        if viewModel.parentNames.count < 2 {
          Button(action: viewModel.addParentName) {
            Image(systemName: "plus.circle.fill")
              .foregroundColor(.purple)
              .font(.title3)
          }
        }
      }
      
      ForEach(Array(viewModel.parentNames.enumerated()), id: \.offset) { index, name in
        HStack {
          TextField("Parent \(index + 1) name", text: $viewModel.parentNames[index])
            .textFieldStyle(CustomTextFieldStyle())
          
          if viewModel.parentNames.count > 1 {
            Button(action: {
              viewModel.removeParentName(at: index)
            }) {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
            }
          }
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    EditProfileParentNamesInput(viewModel: {
      let vm = EditProfileViewModel()
      vm.parentNames = ["Parent 1"]
      return vm
    }())
    .padding()
  }
}
