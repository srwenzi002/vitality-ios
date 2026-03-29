import SwiftUI

struct BackpackView: View {
    @EnvironmentObject private var store: VitalityStore
    @State private var selection = 0

    private var uniqueSeries: [String] {
        Array(Set(store.collectibles.map(\.series))).sorted()
    }

    private var favoriteCount: Int {
        store.collectibles.filter(\.isFavorite).count
    }

    private var totalValuation: Int {
        store.collectibles.reduce(0) { $0 + $1.chainValue }
    }

    private var groupedSeries: [(name: String, items: [Collectible])] {
        Dictionary(grouping: store.collectibles, by: \.series)
            .map { (name: $0.key, items: $0.value.sorted(by: { $0.chainValue > $1.chainValue })) }
            .sorted { $0.items.count > $1.items.count }
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    profileHeader

                    Picker("背包分类", selection: $selection) {
                        Text("总览").tag(0)
                        Text("已收藏").tag(1)
                        Text("记录").tag(2)
                    }
                    .pickerStyle(.segmented)

                    if selection == 0 {
                        overviewSection
                    } else if selection == 1 {
                        collectedSection
                    } else {
                        activitySection
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var profileHeader: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [VitalityTheme.cyan, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 78, height: 78)
                            .overlay(
                                Text("元")
                                    .font(.system(size: 30, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.profile.name)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("我的背包 · 管理盲盒、收藏与交易记录")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.68))
                            Text("ID 0x431e...32f96354")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(VitalityTheme.accent)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("\(store.profile.totalBoxes)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("累计开箱")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }

                HStack(spacing: 12) {
                    assetPill(title: "收藏系列", value: "\(uniqueSeries.count)", tint: VitalityTheme.accent)
                    assetPill(title: "藏品数量", value: "\(store.collectibles.count)", tint: VitalityTheme.orange)
                    assetPill(title: "重点收藏", value: "\(favoriteCount)", tint: VitalityTheme.cyan)
                }
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            FrostCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("资产总览")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        overviewMetric(title: "总估值", value: "\(totalValuation)", subtitle: "模拟估值")
                        overviewMetric(title: "钥匙库存", value: "\(store.profile.keys)", subtitle: "可继续开箱")
                    }

                    HStack(spacing: 12) {
                        overviewMetric(title: "元气币", value: "\(store.profile.vitalityCoins)", subtitle: "账户可用")
                        overviewMetric(title: "交易记录", value: "\(store.activities.count)", subtitle: "最近动态")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("系列总览")

                ForEach(groupedSeries, id: \.name) { group in
                    FrostCard {
                        HStack(alignment: .center, spacing: 14) {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(seriesColor(for: group.name).opacity(0.18))
                                .frame(width: 56, height: 72)
                                .overlay(
                                    Image(systemName: "shippingbox.circle.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(seriesColor(for: group.name))
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(group.name)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("收藏 \(group.items.count) 件 · 最高估值 \(group.items.map(\.chainValue).max() ?? 0)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.64))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 6) {
                                Text("\(group.items.reduce(0) { $0 + $1.chainValue })")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(.mint)
                                Text("系列总值")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.48))
                            }
                        }
                    }
                }
            }
        }
    }

    private var collectedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("我的收藏")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(store.collectibles) { item in
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            CollectibleArtworkView(collectible: item)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .frame(height: 168)

                            if item.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(VitalityTheme.pink, in: Circle())
                                    .padding(10)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(item.series)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(VitalityTheme.accent)
                                    .lineLimit(1)
                                RarityBadge(rarity: item.rarity)
                            }

                            Text(item.name)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(2)

                            Text(item.style)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.58))

                            HStack {
                                Text("估值")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.48))
                                Spacer()
                                Text("\(item.chainValue)")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(.mint)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("最近记录")

            ForEach(store.activities) { activity in
                FrostCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(activity.detail)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.72))
                        Text(activity.timestamp)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VitalityTheme.orange)
                    }
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private func assetPill(title: String, value: String, tint: Color) -> some View {
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

    private func overviewMetric(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.54))
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.46))
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func seriesColor(for series: String) -> Color {
        switch series {
        case "冠军传说": VitalityTheme.orange
        case "城市跑场": VitalityTheme.pink
        default: VitalityTheme.cyan
        }
    }
}
