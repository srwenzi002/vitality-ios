import SwiftUI

struct MarketView: View {
    @EnvironmentObject private var store: VitalityStore
    @State private var keyTradeMode: KeyTradeMode = .buy

    private enum KeyTradeMode: String, CaseIterable, Identifiable {
        case buy = "买入"
        case sell = "卖出"

        var id: String { rawValue }
    }

    private var featuredCollectibles: [Collectible] {
        Array(store.collectibles.sorted(by: { $0.chainValue > $1.chainValue }).prefix(3))
    }

    private var hotCollectibles: [Collectible] {
        Array(store.collectibles.sorted(by: { $0.chainValue > $1.chainValue }).prefix(4))
    }

    private var keyListings: [MarketListing] {
        store.marketListings.filter { $0.type == .key }
    }

    private var displayedKeyListings: [MarketListing] {
        keyListings.enumerated().compactMap { index, listing in
            let adjustedPrice: Int
            let adjustedValue: Int

            switch keyTradeMode {
            case .buy:
                adjustedPrice = listing.price
                adjustedValue = listing.chainValue
            case .sell:
                adjustedPrice = max(listing.price - 28 - (index * 6), 40)
                adjustedValue = max(listing.chainValue - 9 - (index * 2), 10)
            }

            return MarketListing(
                id: listing.id,
                title: listing.title,
                type: listing.type,
                price: adjustedPrice,
                chainValue: adjustedValue,
                seller: listing.seller,
                subtitle: keyTradeMode == .buy ? listing.subtitle : "回收参考价 \(adjustedValue) · 即时成交"
            )
        }
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "市场中心", subtitle: "用户之间买卖钥匙和数字藏品，首页聚合展示交易重点")
                    holdingsPanel
                    featuredCollectiblePanel
                    hotCollectiblesPanel
                    keyTradingPanel
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var holdingsPanel: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("我的市场资产")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("展示元气币、钥匙库存和市场走势，方便用户快速判断是否继续开箱或交易。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.66))
                    }
                    Spacer()
                    Text("+4.8%")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(VitalityTheme.accent)
                }

                HStack(spacing: 12) {
                    holdingPill(title: "元气币", value: "\(store.profile.vitalityCoins)", tint: VitalityTheme.accent)
                    holdingPill(title: "钥匙库存", value: "\(store.profile.keys)", tint: VitalityTheme.orange)
                    holdingPill(title: "挂单数", value: "\(store.marketListings.count)", tint: VitalityTheme.cyan)
                }
            }
        }
    }

    private var featuredCollectiblePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "精选藏品", action: "查看全部")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredCollectibles) { featuredCollectible in
                        ZStack(alignment: .bottomLeading) {
                            CollectibleArtworkView(collectible: featuredCollectible)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.72)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                )
                                .overlay(
                                    VStack {
                                        HStack {
                                            Text("Preview")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.82))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 7)
                                                .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            Spacer()
                                            Text("精选")
                                                .font(.system(size: 12, weight: .black, design: .rounded))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(VitalityTheme.orange, in: Capsule())
                                        }
                                        Spacer()
                                    }
                                    .padding(16)
                                )
                                .frame(height: 330)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(featuredCollectible.series)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(VitalityTheme.accent)
                                Text(featuredCollectible.name)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                HStack(spacing: 8) {
                                    Text("地板价：")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.66))
                                    Text("\(featuredCollectible.chainValue)")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(VitalityTheme.accent)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                        }
                        .frame(width: 292, alignment: .leading)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var hotCollectiblesPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "热门藏品", action: "更多热门")

            ForEach(hotCollectibles) { item in
                FrostCard {
                    HStack(alignment: .center, spacing: 14) {
                        CollectibleArtworkView(collectible: item)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .frame(width: 58, height: 72)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(item.series)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(VitalityTheme.orange)
                                RarityBadge(rarity: item.rarity)
                            }
                            Text(item.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("地板价 \(item.chainValue) · \(item.style)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.62))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(item.chainValue)")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.mint)
                            Text("Floor")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.46))
                        }
                    }
                }
            }
        }
    }

    private var keyTradingPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "钥匙买卖", action: "交易深度")

            FrostCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        ForEach(KeyTradeMode.allCases) { mode in
                            Button {
                                keyTradeMode = mode
                            } label: {
                                Text(mode.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(keyTradeMode == mode ? VitalityTheme.accent : Color.white.opacity(0.05))
                                    )
                                    .foregroundStyle(keyTradeMode == mode ? Color.black.opacity(0.82) : .white)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(spacing: 10) {
                        ForEach(displayedKeyListings) { listing in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(VitalityTheme.accent.opacity(0.14))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(VitalityTheme.accent)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(listing.title)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(listing.subtitle)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.60))
                                        .lineLimit(1)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("\(listing.price)")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("估值 \(listing.chainValue)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(VitalityTheme.orange)
                                }

                                Button(keyTradeMode == .buy ? "买" : "卖") {}
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(keyTradeMode == .buy ? VitalityTheme.accent : VitalityTheme.orange, in: Capsule())
                                    .foregroundStyle(Color.black.opacity(0.82))
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }
        }
    }

    private func sectionTitle(title: String, action: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Text(action)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitalityTheme.accent)
        }
        .padding(.horizontal, 4)
    }

    private func holdingPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.14))
        )
    }

    private func marketInfoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func labelBadge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.18), in: Capsule())
    }

    private func featuredColor(for rarity: RarityTier) -> Color {
        switch rarity {
        case .n: Color.gray
        case .r: VitalityTheme.cyan
        case .sr: VitalityTheme.pink
        case .ssr: VitalityTheme.orange
        }
    }
}
