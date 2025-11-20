import SwiftUI

struct RootView: View {
    @State private var isLaunchScreenActive = true

    var body: some View {
        ZStack {
            if isLaunchScreenActive {
                LaunchView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isLaunchScreenActive = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}

#Preview {
    RootView()
}
