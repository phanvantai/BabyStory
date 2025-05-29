import SwiftUI

struct DueDatePicker: View {
    @Binding var dueDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.title3)
                Text("Due Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            DatePicker("", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.cardBackground.opacity(0.8))
                        .stroke(AppTheme.defaultCardBorder, lineWidth: 1)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        DueDatePicker(dueDate: .constant(Date()))
            .padding()
    }
}
