import SwiftUI

struct BackpackView: View {
    @EnvironmentObject private var store: VitalityStore
    @State private var selection = 0
    @State private var selectedBox: BlindBox?

    private var uniqueSeries: [String] {
        Array(Set(store.collectibles.map(\.series))).sorted()
    }

    private var favoriteCount: Int {
        store.collectibles.filter(\.isFavorite).count
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
                            .task {
                                await store.preloadBlindBoxDetailsIfNeeded()
                            }
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
        .sheet(item: $selectedBox) { box in
            BlindBoxCollectionView(box: box)
                .environmentObject(store)
        }
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
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("盲盒图鉴")

            ForEach(store.blindBoxes) { box in
                let ownedCount = ownedCardCount(for: box)
                let total = box.previewCards.count

                Button { selectedBox = box } label: {
                    FrostCard {
                        HStack(spacing: 14) {
                            BlindBoxArtworkView(
                                title: box.title,
                                subtitle: nil,
                                imageURL: box.imageURL,
                                accent: VitalityTheme.cyan,
                                contentMode: .fill
                            )
                            .frame(width: 64, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            VStack(alignment: .leading, spacing: 8) {
                                Text(box.title)
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(box.subtitle)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.62))
                                    .lineLimit(1)

                                HStack(spacing: 8) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.white.opacity(0.10))
                                                .frame(height: 5)
                                            Capsule()
                                                .fill(VitalityTheme.accent)
                                                .frame(
                                                    width: total > 0 ? geo.size.width * CGFloat(min(ownedCount, total)) / CGFloat(total) : 0,
                                                    height: 5
                                                )
                                        }
                                    }
                                    .frame(height: 5)

                                    Text("\(ownedCount)/\(total)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(VitalityTheme.accent)
                                        .fixedSize()
                                }
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func ownedCardCount(for box: BlindBox) -> Int {
        let previewIDs = Set(box.previewCards.compactMap(\.remoteCardID))
        if previewIDs.isEmpty {
            // Fall back to series name matching
            return store.collectibles.filter { $0.series == box.title }.count
        }
        return store.collectibles.filter { c in
            guard let id = c.remoteCardID else { return false }
            return previewIDs.contains(id)
        }.count
    }

    private var collectedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("我的收藏")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(store.collectibles) { item in
                    ZStack(alignment: .topTrailing) {
                        // Full-bleed artwork
                        CollectibleArtworkView(collectible: item)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        // Bottom text overlay
                        .overlay(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    RarityBadge(rarity: item.rarity)
                                    if item.ownedCount > 1 {
                                        Text("×\(item.ownedCount)")
                                            .font(.system(size: 11, weight: .black, design: .rounded))
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 4)
                                            .background(VitalityTheme.accent, in: Capsule())
                                    }
                                }
                                Text(item.name)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                HStack(spacing: 2) {
                                    Text("估值")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.6))
                                    Text("\(item.chainValue)")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(.mint)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.top, 40)
                            .padding(.bottom, 12)
                            .background(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.55), .black.opacity(0.82)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(
                                .rect(
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 20
                                )
                            )
                        }

                        // Heart badge
                        if item.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(7)
                                .background(VitalityTheme.pink, in: Circle())
                                .padding(10)
                        }
                    }
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

}

struct BlindBoxCollectionView: View {
    @EnvironmentObject private var store: VitalityStore
    @Environment(\.dismiss) private var dismiss
    let box: BlindBox
    @State private var resolvedBox: BlindBox? = nil

    private var displayBox: BlindBox { resolvedBox ?? box }

    private var ownedByCardID: [Int: Int] {
        var result: [Int: Int] = [:]
        for c in store.collectibles {
            guard let id = c.remoteCardID else { continue }
            result[id, default: 0] += c.ownedCount
        }
        return result
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.10), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 2) {
                        Text(displayBox.title)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        let owned = displayBox.previewCards.filter { card in
                            guard let id = card.remoteCardID else { return false }
                            return ownedByCardID[id] != nil
                        }.count
                        Text("已收集 \(owned)/\(displayBox.previewCards.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VitalityTheme.accent)
                    }

                    Spacer()

                    // Balance placeholder
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)

                if displayBox.previewCards.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(VitalityTheme.accent)
                        .scaleEffect(1.4)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(displayBox.previewCards) { card in
                                collectionCardCell(card)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .task {
            resolvedBox = await store.loadBlindBoxDetail(for: box)
        }
    }

    @ViewBuilder
    private func collectionCardCell(_ card: BlindBoxCardPreview) -> some View {
        let ownedCount = card.remoteCardID.flatMap { ownedByCardID[$0] }
        let isOwned = ownedCount != nil

        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                BlindBoxCardArtworkView(
                    title: card.name,
                    rarity: card.rarity,
                    imageURL: card.imageURL
                )
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .saturation(isOwned ? 1.0 : 0.0)
                .opacity(isOwned ? 1.0 : 0.4)

                // Card name + rarity at bottom
                VStack(alignment: .leading, spacing: 2) {
                    RarityBadge(rarity: card.rarity)
                    Text(card.name)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }

            // Owned count badge
            if let count = ownedCount {
                Text("×\(count)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(VitalityTheme.accent, in: Capsule())
                    .padding(6)
            } else {
                // Lock icon for unowned
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(7)
                    .background(Color.black.opacity(0.40), in: Circle())
                    .padding(6)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isOwned ? VitalityTheme.accent.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1.5)
        )
    }
}
