import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: VitalityStore

    var body: some View {
        ZStack {
            AppGradientBackground()

            TabView {
                NavigationStack { DashboardView() }
                    .tabItem { Label("仪表盘", systemImage: "house.fill") }

                NavigationStack { MallView() }
                    .tabItem { Label("商城", systemImage: "bag.fill") }

                NavigationStack { MarketView() }
                    .tabItem { Label("市场", systemImage: "chart.line.uptrend.xyaxis") }

                NavigationStack { BackpackView() }
                    .tabItem { Label("背包", systemImage: "shippingbox.fill") }

                NavigationStack { SocialView() }
                    .tabItem { Label("社交", systemImage: "person.3.fill") }
            }
            .tint(VitalityTheme.accent)
            .toolbarBackground(.hidden, for: .tabBar)

            ToastOverlay(message: store.toastMessage)
                .allowsHitTesting(false)
        }
        .onChange(of: store.toastMessage) { _, message in
            guard message != nil else { return }
            Task {
                try? await Task.sleep(for: .seconds(2.4))
                await MainActor.run {
                    store.dismissToast()
                }
            }
        }
        .task {
            await store.loadIfNeeded()
        }
    }
}
