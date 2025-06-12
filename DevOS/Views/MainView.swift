import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isInitializing {
                LoadingView()
            } else if authViewModel.isLoggedIn {
                if authViewModel.hasCompletedOnboarding {
                    // Aquí envolvemos NavBarView en NavigationStack
                    NavigationStack {
                        NavBarView()
                    }
                } else {
                    OnboardingFlowView()
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    MainView().modelContainer(for: [], inMemory: true)
}
