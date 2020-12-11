import SwiftUI

struct BlueButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
        .font(.headline)
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        .foregroundColor(configuration.isPressed ? Color.blue.opacity(0.5) : Color.blue)
        .background(Color.blue.opacity(0.05))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .cornerRadius(12)
        .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
