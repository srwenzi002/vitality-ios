import SwiftUI

private enum MallDestination: String, Identifiable, CaseIterable {
    case blindBoxes = "盲盒"
    case collectibles = "藏品"
    case creators = "创作者"
    case ranking = "藏家榜单"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .blindBoxes: "shippingbox.fill"
        case .collectibles: "sparkles.rectangle.stack.fill"
        case .creators: "paintpalette.fill"
        case .ranking: "trophy.fill"
        }
    }

    var tint: Color {
        switch self {
        case .blindBoxes: VitalityTheme.orange
        case .collectibles: VitalityTheme.cyan
        case .creators: VitalityTheme.pink
        case .ranking: VitalityTheme.accent
        }
    }

    var subtitle: String {
        switch self {
        case .blindBoxes: "官方盲盒池与开箱概率"
        case .collectibles: "系列藏品与稀有度预览"
        case .creators: "合作创作者与联名计划"
        case .ranking: "热门藏家与收藏热度"
        }
    }
}

private struct CreatorProfile: Identifiable {
    let id = UUID()
    let name: String
    let tag: String
    let focus: String
}

private struct CollectorRank: Identifiable {
    let id = UUID()
    let name: String
    let level: String
    let collectionCount: Int
}

struct MallView: View {
    @EnvironmentObject private var store: VitalityStore

    @State private var activeDestination: MallDestination?
    @State private var selectedBlindBox: BlindBox?

    private let creators: [CreatorProfile] = [
        .init(name: "YQ Motion Lab", tag: "官方合作", focus: "运动动态卡与勋章联名"),
        .init(name: "Neon Sprint", tag: "城市系列", focus: "夜跑都市主题视觉"),
        .init(name: "Pulse Artifact", tag: "收藏艺术家", focus: "体能数据抽象艺术卡")
    ]

    private let collectorRanks: [CollectorRank] = [
        .init(name: "元气鲸落", level: "SSR 收藏家", collectionCount: 28),
        .init(name: "Sprint 404", level: "SR 猎手", collectionCount: 21),
        .init(name: "跑道漫游者", level: "R 收纳师", collectionCount: 16)
    ]

    private var featuredBox: BlindBox? {
        store.blindBoxes.last
    }

    private var hotBoxes: [BlindBox] {
        Array(store.blindBoxes.prefix(2))
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "商城", subtitle: "官方内容发布中心，二级入口承接盲盒、藏品、创作者与榜单")
                    menuGrid
                    featuredSection
                    hotSection
                    calendarSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .navigationDestination(item: $activeDestination) { destination in
            MallDetailView(
                destination: destination,
                blindBoxes: store.blindBoxes,
                collectibles: store.collectibles,
                creators: creators,
                collectorRanks: collectorRanks
            )
        }
        .navigationDestination(item: $selectedBlindBox) { box in
            BlindBoxDetailView(initialBox: box)
                .environmentObject(store)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var menuGrid: some View {
        HStack(spacing: 10) {
            ForEach(MallDestination.allCases) { destination in
                Button {
                    activeDestination = destination
                } label: {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(destination.tint.opacity(0.16))
                                .frame(width: 50, height: 50)
                            Image(systemName: destination.icon)
                                .font(.system(size: 21, weight: .bold))
                                .foregroundStyle(destination.tint)
                        }

                        Text(destination.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, minHeight: 102, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "精品盲盒", action: "查看盲盒") {
                activeDestination = .blindBoxes
            }

            if let featuredBox {
                Button {
                    selectedBlindBox = featuredBox
                } label: {
                    FrostCard {
                        VStack(alignment: .leading, spacing: 16) {
                            BlindBoxArtworkView(
                                title: featuredBox.title,
                                subtitle: featuredBox.subtitle,
                                imageURL: featuredBox.imageURL,
                                accent: boxColor(for: featuredBox.category)
                            )
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(featuredBox.title)
                                        .font(.system(size: 26, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(featuredBox.subtitle)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.68))
                                    HStack(spacing: 8) {
                                        labelBadge(text: featuredBox.category.rawValue, tint: VitalityTheme.orange)
                                        labelBadge(text: featuredBox.highlight, tint: VitalityTheme.accent)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.85))
                            }

                            HStack(spacing: 10) {
                                mallStatCard(title: "发售价", value: "\(featuredBox.priceInCoins) 元气币")
                                mallStatCard(title: "钥匙", value: "\(featuredBox.keyCost) 把")
                                mallStatCard(title: "发售", value: featuredBox.releaseDateText)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var hotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "热门盲盒", action: "更多热门") {
                activeDestination = .blindBoxes
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(hotBoxes) { box in
                        Button {
                            selectedBlindBox = box
                        } label: {
                            VStack(alignment: .leading, spacing: 14) {
                                BlindBoxArtworkView(
                                    title: box.title,
                                    subtitle: box.category.rawValue,
                                    imageURL: box.imageURL,
                                    accent: boxColor(for: box.category)
                                )
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(box.title)
                                        .font(.system(size: 19, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("\(box.priceInCoins) 元气币 · \(box.keyCost) 把钥匙")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.66))
                                }
                            }
                            .padding(16)
                            .frame(width: 250, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title: "投放日历", action: "全部日历") {
                activeDestination = .blindBoxes
            }

            FrostCard {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(store.blindBoxes.enumerated()), id: \.element.id) { index, box in
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(boxColor(for: box.category))
                                    .frame(width: 10, height: 10)
                                if index != store.blindBoxes.count - 1 {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 1, height: 52)
                                }
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(box.releaseDateText)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(box.title)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.92))
                                Text("\(box.category.rawValue) · \(box.highlight)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.62))
                            }

                            Spacer()

                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
        }
    }

    private func mallStatCard(title: String, value: String) -> some View {
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
            .overlay(Capsule().stroke(tint.opacity(0.24), lineWidth: 1))
    }

    private func sectionTitle(title: String, action: String, handler: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Button(action, action: handler)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VitalityTheme.accent)
        }
        .padding(.horizontal, 4)
    }

    private func boxColor(for category: BlindBoxCategory) -> Color {
        switch category {
        case .daily: VitalityTheme.orange
        case .urban: VitalityTheme.cyan
        case .legend: VitalityTheme.pink
        }
    }
}

private struct MallDetailView: View {
    let destination: MallDestination
    let blindBoxes: [BlindBox]
    let collectibles: [Collectible]
    let creators: [CreatorProfile]
    let collectorRanks: [CollectorRank]

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: destination.rawValue, subtitle: destination.subtitle)

                    switch destination {
                    case .blindBoxes:
                        ForEach(blindBoxes) { box in
                            FrostCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    BlindBoxArtworkView(
                                        title: box.title,
                                        subtitle: box.subtitle,
                                        imageURL: box.imageURL,
                                        accent: destination.tint
                                    )
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                                    HStack {
                                        Text(box.title)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text(box.highlight)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(destination.tint)
                                    }
                                    Text(box.subtitle)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.68))
                                    HStack(spacing: 12) {
                                        detailInfo(title: "价格", value: "\(box.priceInCoins) 元气币")
                                        detailInfo(title: "钥匙", value: "\(box.keyCost) 把")
                                        detailInfo(title: "时间", value: box.releaseDateText)
                                    }
                                }
                            }
                        }

                    case .collectibles:
                        ForEach(collectibles) { item in
                            FrostCard {
                                HStack(spacing: 14) {
                                    CollectibleArtworkView(collectible: item)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .frame(width: 62, height: 78)

                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(item.name)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                            RarityBadge(rarity: item.rarity)
                                        }
                                        Text("\(item.series) · \(item.style)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.65))
                                    }
                                    Spacer()
                                    Text("\(item.chainValue)")
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundStyle(.mint)
                                }
                            }
                        }

                    case .creators:
                        ForEach(creators) { creator in
                            FrostCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(creator.name)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text(creator.tag)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(destination.tint)
                                    }
                                    Text(creator.focus)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.68))
                                }
                            }
                        }

                    case .ranking:
                        ForEach(Array(collectorRanks.enumerated()), id: \.element.id) { index, collector in
                            FrostCard {
                                HStack {
                                    Text("#\(index + 1)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(destination.tint)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(collector.name)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text(collector.level)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.65))
                                    }
                                    Spacer()
                                    Text("\(collector.collectionCount) 件")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func detailInfo(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BlindBoxDetailView: View {
    @EnvironmentObject private var store: VitalityStore
    @Environment(\.dismiss) private var dismiss

    let initialBox: BlindBox

    @State private var box: BlindBox
    @State private var selectedQuantity = 1
    @State private var isOpening = false
    @State private var showResult = false
    @State private var showBatchResult = false
    @State private var latestReward: Collectible?
    @State private var openingRewards: [Collectible] = []

    init(initialBox: BlindBox) {
        self.initialBox = initialBox
        _box = State(initialValue: initialBox)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    BlindBoxArtworkView(
                        title: box.title,
                        subtitle: box.subtitle,
                        imageURL: box.imageURL,
                        accent: accentColor
                    )
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        Text("限定系列")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.84))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(VitalityTheme.accent, in: Capsule())
                            .padding(16)
                    }

                    FrostCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(box.title)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("\(box.subtitle)。开启盲盒后可从当前系列中抽取卡片。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.72))

                            HStack(spacing: 10) {
                                detailPill(title: "钥匙消耗", value: "\(box.keyCost * selectedQuantity)")
                                detailPill(title: "元气币参考", value: "\(box.priceInCoins * selectedQuantity)")
                                detailPill(title: "剩余钥匙", value: "\(store.profile.keys)")
                            }
                        }
                    }

                    FrostCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("选择开启数量")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            HStack(spacing: 12) {
                                quantityButton(title: "单抽", value: 1)
                                quantityButton(title: "十连抽", value: 10)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("卡池预览")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(max(box.previewCards.count, 1)) 张")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(VitalityTheme.accent)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(displayCards) { card in
                                    VStack(alignment: .leading, spacing: 10) {
                                        BlindBoxCardArtworkView(title: card.name, rarity: card.rarity, imageURL: card.imageURL)
                                            .frame(width: 118, height: 148)
                                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                        HStack {
                                            Text(card.name)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            Spacer()
                                            RarityBadge(rarity: card.rarity)
                                        }
                                        Text(card.description)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.62))
                                            .lineLimit(2)
                                    }
                                    .frame(width: 150, alignment: .leading)
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .fill(Color.white.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }

                    Button {
                        startOpening()
                    } label: {
                        Text(selectedQuantity == 1 ? "确认开启" : "确认十连抽")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [VitalityTheme.pink, VitalityTheme.cyan, VitalityTheme.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                            )
                            .foregroundStyle(Color.black.opacity(0.84))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            box = await store.loadBlindBoxDetail(for: initialBox)
        }
        .fullScreenCover(isPresented: $isOpening) {
            BlindBoxOpeningExperienceView(box: box, quantity: selectedQuantity, rewards: $openingRewards)
        }
        .sheet(isPresented: $showResult) {
            if let latestReward {
                BlindBoxResultSheet(box: box, reward: latestReward, remainingKeys: store.profile.keys)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showBatchResult) {
            BlindBoxBatchResultSheet(box: box, rewards: openingRewards, remainingKeys: store.profile.keys)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var displayCards: [BlindBoxCardPreview] {
        if !box.previewCards.isEmpty {
            return box.previewCards
        }

        return [
            BlindBoxCardPreview(id: UUID(), remoteCardID: nil, name: "\(box.category.rawValue) 样卡", rarity: .r, description: "官方卡池展示藏品", imageURL: box.imageURL),
            BlindBoxCardPreview(id: UUID(), remoteCardID: nil, name: "闪耀进阶", rarity: .sr, description: "高稀有掉落预览", imageURL: nil),
            BlindBoxCardPreview(id: UUID(), remoteCardID: nil, name: "终极限定", rarity: .ssr, description: "稀有终极卡面", imageURL: nil)
        ]
    }

    private var accentColor: Color {
        switch box.category {
        case .daily: VitalityTheme.orange
        case .urban: VitalityTheme.cyan
        case .legend: VitalityTheme.pink
        }
    }

    private func detailPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func quantityButton(title: String, value: Int) -> some View {
        Button {
            selectedQuantity = value
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selectedQuantity == value ? Color.white.opacity(0.18) : Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedQuantity == value ? accentColor.opacity(0.66) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private func startOpening() {
        isOpening = true
        openingRewards = []
        latestReward = nil

        Task {
            try? await Task.sleep(for: .seconds(0.7))
            let rewards = await store.openBlindBoxAnimated(box, count: selectedQuantity)
            await MainActor.run {
                openingRewards = rewards
            }
            try? await Task.sleep(for: .seconds(selectedQuantity == 1 ? 3.0 : 2.8))

            await MainActor.run {
                isOpening = false
                if selectedQuantity == 1 {
                    latestReward = rewards.max(by: { $0.chainValue < $1.chainValue }) ?? rewards.first
                    showResult = latestReward != nil
                } else {
                    showBatchResult = !rewards.isEmpty
                }
            }
        }
    }
}

private struct BlindBoxOpeningExperienceView: View {
    let box: BlindBox
    let quantity: Int
    @Binding var rewards: [Collectible]
    @State private var animate = false
    @State private var revealCard = false

    var body: some View {
        ZStack {
            AppGradientBackground()

            Circle()
                .fill(VitalityTheme.pink.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .scaleEffect(animate ? 1.12 : 0.78)

            Circle()
                .stroke(
                    LinearGradient(colors: [VitalityTheme.pink, VitalityTheme.cyan, VitalityTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 3
                )
                .frame(width: 250, height: 250)
                .scaleEffect(animate ? 1.08 : 0.84)
                .opacity(animate ? 1 : 0.3)

            VStack(spacing: 22) {
                if quantity == 1 {
                    singleRevealStage
                } else {
                    tenDrawStage
                }

                VStack(spacing: 8) {
                    Text(rewards.isEmpty ? "正在开启盲盒" : (quantity == 1 ? "奖励已揭晓" : "十连结果已生成"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(rewards.isEmpty ? "能量汇聚中，请稍候..." : (quantity == 1 ? "高光卡面已翻出，准备收入背包" : "卡墙已展开，准备查看本次十连"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.68))
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            revealCard = false
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .onChange(of: rewards.count) { _, newValue in
            guard newValue > 0 else { return }
            withAnimation(.spring(duration: 0.55)) {
                revealCard = true
            }
        }
    }

    private var singleRevealStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .frame(width: 250, height: 344)
                .shadow(color: VitalityTheme.cyan.opacity(0.18), radius: 26, x: 0, y: 18)

            if let reward = rewards.first, revealCard {
                CollectibleArtworkView(collectible: reward)
                    .frame(width: 230, height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: reward.rarity.color.opacity(0.42), radius: 34, x: 0, y: 24)
                    .scaleEffect(animate ? 1.02 : 0.94)
                    .transition(.scale(scale: 0.84).combined(with: .opacity))
                    .overlay(alignment: .topTrailing) {
                        RarityBadge(rarity: reward.rarity)
                            .padding(18)
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reward.series)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(VitalityTheme.accent)
                            Text(reward.name)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                        }
                        .padding(18)
                    }
            } else {
                BlindBoxArtworkView(title: box.title, subtitle: box.category.rawValue, imageURL: box.imageURL, accent: .purple)
                    .frame(width: 230, height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: VitalityTheme.cyan.opacity(0.35), radius: 34, x: 0, y: 24)
                    .scaleEffect(animate ? 1 : 0.88)
                    .rotationEffect(.degrees(animate ? 0 : -8))
            }
        }
    }

    private var tenDrawStage: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            ForEach(Array(displayedRewards.enumerated()), id: \.offset) { index, reward in
                Group {
                    if let reward {
                        CollectibleArtworkView(collectible: reward)
                            .overlay(alignment: .topTrailing) {
                                RarityBadge(rarity: reward.rarity)
                                    .padding(10)
                            }
                    } else {
                        BlindBoxArtworkView(title: box.title, subtitle: nil, imageURL: box.imageURL, accent: .purple)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
                .frame(height: 136)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .scaleEffect(animate ? 1 : 0.96)
                .opacity(animate ? 1 : 0.78)
                .animation(.spring(duration: 0.45).delay(Double(index) * 0.05), value: rewards.count)
            }
        }
    }

    private var displayedRewards: [Collectible?] {
        let targetCount = max(quantity, 1)
        let rewardItems = rewards.map { Optional($0) }
        if rewardItems.count >= targetCount {
            return Array(rewardItems.prefix(targetCount))
        }
        return rewardItems + Array(repeating: nil, count: targetCount - rewardItems.count)
    }
}

private struct BlindBoxResultSheet: View {
    let box: BlindBox
    let reward: Collectible
    let remainingKeys: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text("开箱结果")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    InteractiveRewardCardView(box: box, reward: reward)
                        .frame(height: 340)

                    FrostCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(reward.name)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("\(reward.series) · \(reward.style)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.68))

                            HStack(spacing: 12) {
                                stat(title: "地板价", value: "\(reward.chainValue)")
                                stat(title: "剩余钥匙", value: "\(remainingKeys)")
                                stat(title: "来源", value: box.title)
                            }
                        }
                    }

                    Button("收下藏品") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(VitalityTheme.accent, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .foregroundStyle(Color.black.opacity(0.84))
                }
                .padding(18)
                .padding(.bottom, 30)
            }
        }
    }

    private func stat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct BlindBoxBatchResultSheet: View {
    let box: BlindBox
    let rewards: [Collectible]
    let remainingKeys: Int
    @Environment(\.dismiss) private var dismiss

    private var bestReward: Collectible? {
        rewards.max(by: { $0.chainValue < $1.chainValue })
    }

    @State private var previewReward: Collectible?

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text("十连结果")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if let bestReward {
                        FrostCard {
                            HStack(spacing: 14) {
                                CollectibleArtworkView(collectible: bestReward)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .frame(width: 92, height: 112)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("本次最高奖励")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(VitalityTheme.accent)
                                    Text(bestReward.name)
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("\(bestReward.series) · 地板价 \(bestReward.chainValue)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.66))
                                }
                                Spacer()
                            }
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(rewards) { reward in
                            Button {
                                previewReward = reward
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    CollectibleArtworkView(collectible: reward)
                                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                        .frame(height: 148)

                                    HStack {
                                        Text(reward.name)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Spacer()
                                        RarityBadge(rarity: reward.rarity)
                                    }

                                    Text("地板价 \(reward.chainValue)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.66))
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    FrostCard {
                        HStack(spacing: 12) {
                            stat(title: "获得数量", value: "\(rewards.count)")
                            stat(title: "剩余钥匙", value: "\(remainingKeys)")
                            stat(title: "来源", value: box.title)
                        }
                    }

                    Button("收下全部藏品") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(VitalityTheme.accent, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .foregroundStyle(Color.black.opacity(0.84))
                }
                .padding(18)
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(item: $previewReward) { reward in
            BlindBoxRewardPreviewOverlay(box: box, reward: reward)
        }
    }

    private func stat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct InteractiveRewardCardView: View {
    let box: BlindBox
    let reward: Collectible

    @State private var showingFront = true
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        let horizontalRotation = dragOffset.width / 10
        let verticalRotation = -dragOffset.height / 14

        ZStack {
            if showingFront {
                rewardFace
            } else {
                backFace
            }
        }
        .rotation3DEffect(.degrees(showingFront ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .rotation3DEffect(.degrees(verticalRotation), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(horizontalRotation), axis: (x: 0, y: 1, z: 0))
        .offset(x: dragOffset.width * 0.08, y: dragOffset.height * 0.05)
        .shadow(color: reward.rarity.color.opacity(0.35), radius: 28, x: 0, y: 18)
        .onTapGesture {
            withAnimation(.spring(duration: 0.55)) {
                showingFront.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring(duration: 0.45)) {
                        dragOffset = .zero
                    }
                }
        )
        .overlay(alignment: .bottom) {
            Text("左右拖动查看角度，轻点翻看背面")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))
                .padding(.bottom, -28)
        }
    }

    private var rewardFace: some View {
        CollectibleArtworkView(collectible: reward)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(alignment: .topTrailing) {
                RarityBadge(rarity: reward.rarity)
                    .padding(18)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reward.series)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(VitalityTheme.accent)
                    Text(reward.name)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(18)
            }
    }

    private var backFace: some View {
        BlindBoxArtworkView(title: box.title, subtitle: "CARD BACK", imageURL: box.imageURL, accent: .purple)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white.opacity(0.88))
                    Text("盲盒卡背")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
    }
}

private struct BlindBoxRewardPreviewOverlay: View {
    let box: BlindBox
    let reward: Collectible
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white.opacity(0.84))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                InteractiveRewardCardView(box: box, reward: reward)
                    .frame(width: 260, height: 390)

                VStack(spacing: 8) {
                    Text(reward.name)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(reward.series) · 地板价 \(reward.chainValue)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()
            }
        }
    }
}
