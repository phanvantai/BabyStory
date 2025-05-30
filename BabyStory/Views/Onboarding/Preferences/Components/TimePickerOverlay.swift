import SwiftUI

struct TimePickerOverlay: View {
  @Binding var showTimePicker: Bool
  @Binding var storyTime: Date
  
  var body: some View {
    // Background overlay
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          showTimePicker = false
        }
      
      // Popup content
      VStack(spacing: 0) {
        Spacer()
        
        VStack(spacing: 20) {
          // Header
          VStack(spacing: 8) {
            HStack {
              Button("Cancel") {
                showTimePicker = false
              }
              .font(.subheadline)
              .fontWeight(.medium)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .foregroundColor(.secondary)
              
              Spacer()
              
              Text("Story Time")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
              
              Spacer()
              
              Button("Done") {
                showTimePicker = false
              }
              .buttonStyle(DoneButtonStyle(gradient: [.purple, .indigo]))
            }
            
            Divider()
              .background(Color.gray.opacity(0.3))
          }
          
          // Time picker
          DatePicker(
            "Story Time",
            selection: $storyTime,
            displayedComponents: .hourAndMinute
          )
          .datePickerStyle(.wheel)
          .labelsHidden()
          .frame(height: 200)
        }
        .padding(24)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(AppTheme.cardBackground)
            .shadow(color: AppTheme.defaultCardShadow.opacity(0.15), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}

#Preview {
  TimePickerOverlay(
    showTimePicker: .constant(true),
    storyTime: .constant(Date())
  )
}
