import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                Text("AIChatBot")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    LaunchView()
}
