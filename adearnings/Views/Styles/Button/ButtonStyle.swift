import SwiftUI

struct BlueButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
        .font(.headline)
        .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
        .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : Color.white)
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.45, green: 0.65, blue: 1), Color(red: 0.3, green: 0.3, blue: 1)]), startPoint: .top, endPoint: .bottom))
        .contentShape(RoundedRectangle(cornerRadius: 24))
        .cornerRadius(24)
        .clipShape(RoundedRectangle(cornerRadius: 24))
  }
}
