//
//  FeedbackFormView.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 13/6/25.
//

import SwiftUI

/// Modal view for collecting and submitting user feedback
struct FeedbackFormView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusedField?
    
    private enum FocusedField {
        case email, message
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Form Content
                        formContent
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("feedback_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common_cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("feedback_submit".localized) {
                        Task {
                            await viewModel.submitFeedback()
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("feedback_success_title".localized, isPresented: $viewModel.showSuccessMessage) {
            Button("common_ok".localized) {
                viewModel.dismissSuccessMessage()
                dismiss()
            }
        } message: {
            Text("feedback_success_message".localized)
        }
        .alert("feedback_error_title".localized, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("common_ok".localized) {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("feedback_header_title".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("feedback_header_subtitle".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Form Content
    private var formContent: some View {
        VStack(spacing: 20) {
            // Feedback Type Picker
            feedbackTypePicker
            
            // Email Field
            emailField
            
            // Message Field
            messageField
            
            // Submit Button (for better UX on mobile)
            submitButton
        }
    }
    
    // MARK: - Feedback Type Picker
    private var feedbackTypePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                Text("feedback_type_label".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Menu {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    Button(action: {
                        viewModel.selectedType = type
                    }) {
                        HStack {
                            Image(systemName: type.icon)
                            Text(type.displayName)
                            if viewModel.selectedType == type {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.selectedType.icon)
                        .foregroundColor(.orange)
                    Text(viewModel.selectedType.displayName)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .appCardStyle()
    }
    
    // MARK: - Email Field
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("feedback_email_label".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextField("feedback_email_placeholder".localized, text: $viewModel.userEmail)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .message
                }
        }
        .padding(20)
        .appCardStyle()
    }
    
    // MARK: - Message Field
    private var messageField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                Text("feedback_message_label".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextField("feedback_message_placeholder".localized, text: $viewModel.message, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
                .focused($focusedField, equals: .message)
                .submitLabel(.done)
        }
        .padding(20)
        .appCardStyle()
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitFeedback()
            }
        }) {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(viewModel.isSubmitting ? "feedback_submitting".localized : "feedback_submit".localized)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.canSubmit ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.horizontal, 24)
    }
}

// MARK: - Previews
#Preview {
    FeedbackFormView()
}
