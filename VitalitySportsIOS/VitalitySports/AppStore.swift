import Foundation

@MainActor
final class VitalityStore: ObservableObject {
    @Published var profile = UserProfile(
        userId: "local-demo",
        name: "元气跑者 001",
        email: nil,
        vitalityCoins: 1280,
        keys: 5,
        totalBoxes: 12
    )

    @Published var health = HealthSnapshot(
        moveCalories: 468,
        steps: 8672,
        distance: 6.3,
        standHours: 10,
        winStreak: 6,
        weeklyGoalHits: 5,
        goalCalories: 500
    )

    @Published var blindBoxes: [BlindBox] = VitalityStore.defaultBlindBoxes
    @Published var collectibles: [Collectible] = VitalityStore.defaultCollectibles
    @Published var marketListings: [MarketListing] = VitalityStore.defaultMarketListings
    @Published var activities: [ActivityEntry] = VitalityStore.defaultActivities
    @Published var toastMessage: String?

    private let api = VitalityAPI()
    private let defaults = UserDefaults.standard
    private let demoPassword = "VitalityDemo2026!"

    private var hasLoadedRemote = false
    private var isLoadingRemote = false
    private var isDrawingBlindBox = false

    private var cachedUserID: String? {
        defaults.string(forKey: "vitality.demo.userId")
    }

    private var cachedDemoIdentity: String {
        if let identity = defaults.string(forKey: "vitality.demo.identity") {
            return identity
        }
        let identity = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        defaults.set(identity, forKey: "vitality.demo.identity")
        return identity
    }

    var canClaimCoins: Bool {
        health.moveCalories > 0
    }

    func loadIfNeeded() async {
        guard !hasLoadedRemote, !isLoadingRemote else { return }
        await loadRemoteData()
    }

    func claimCoinsFromCalories() {
        guard canClaimCoins else { return }
        let reward = max(health.moveCalories / 10, 1)
        profile.vitalityCoins += reward
        toastMessage = "已按热量兑换 \(reward) 元气币"
        prependActivity(title: "兑换元气币", detail: "今日消耗热量已兑换 \(reward) 元气币", timestamp: "刚刚")
    }

    func buyKeys(count: Int = 1) {
        let totalCost = 120 * count
        guard profile.vitalityCoins >= totalCost else {
            toastMessage = "元气币不足，无法购买钥匙"
            return
        }
        profile.vitalityCoins -= totalCost
        profile.keys += count
        toastMessage = "购买成功，获得 \(count) 把钥匙"
        prependActivity(title: "购买钥匙", detail: "消耗 \(totalCost) 元气币，获得 \(count) 把钥匙", timestamp: "刚刚")
    }

    func openBlindBox(_ box: BlindBox) {
        Task {
            _ = await openBlindBoxAnimated(box, count: 1)
        }
    }

    func openBlindBoxAnimated(_ box: BlindBox, count: Int) async -> [Collectible] {
        guard profile.keys >= box.keyCost * count else {
            toastMessage = "钥匙不足，无法开启 \(box.title)"
            return []
        }

        guard let remoteSeriesID = box.remoteSeriesID, let userID = cachedUserID else {
            return openBlindBoxLocally(box, count: count)
        }

        return await drawBlindBoxRemotely(box, seriesID: remoteSeriesID, userID: userID, count: count)
    }

    func dismissToast() {
        toastMessage = nil
    }

    func loadBlindBoxDetail(for box: BlindBox) async -> BlindBox {
        guard let remoteSeriesID = box.remoteSeriesID else {
            return box
        }

        do {
            let detail = try await api.fetchSeriesDetail(seriesId: remoteSeriesID)
            let enriched = BlindBox(
                id: box.id,
                remoteSeriesID: box.remoteSeriesID,
                title: detail.name,
                category: box.category,
                subtitle: detail.description.nilIfBlank ?? box.subtitle,
                releaseDateText: box.releaseDateText,
                priceInCoins: detail.priceGoldCoins.map { NSDecimalNumber(decimal: $0).intValue } ?? box.priceInCoins,
                keyCost: max(detail.priceKeys ?? box.keyCost, 1),
                highlight: box.highlight,
                rarityRates: box.rarityRates,
                imageURL: detail.imageUrl ?? box.imageURL,
                previewCards: detail.cards.compactMap { card in
                    guard let rarity = RarityTier(rawValue: card.rarity.uppercased()) else { return nil }
                    return BlindBoxCardPreview(
                        id: UUID(),
                        remoteCardID: card.id,
                        name: card.name,
                        rarity: rarity,
                        description: card.description.nilIfBlank ?? "官方卡池展示藏品",
                        imageURL: card.imageUrl
                    )
                }
            )

            if let index = blindBoxes.firstIndex(where: { $0.id == box.id }) {
                blindBoxes[index] = enriched
            }
            return enriched
        } catch {
            return box
        }
    }

    private func loadRemoteData(force: Bool = false) async {
        guard force || !hasLoadedRemote, !isLoadingRemote else { return }
        isLoadingRemote = true
        defer { isLoadingRemote = false }

        do {
            let user = try await api.ensureDemoUser(
                identity: cachedDemoIdentity,
                password: demoPassword,
                cachedUserID: cachedUserID
            )
            defaults.set(user.userId, forKey: "vitality.demo.userId")

            let bootstrap = try await api.bootstrap(userId: user.userId)
            apply(bootstrap: bootstrap)

            if let remoteBlindBoxes = try? await api.fetchActiveSeries(), !remoteBlindBoxes.isEmpty {
                blindBoxes = remoteBlindBoxes.map { series in
                    BlindBox(
                        id: UUID(),
                        remoteSeriesID: series.id,
                        title: series.name,
                        category: Self.category(for: series.name, keyCost: series.priceKeys),
                        subtitle: series.description.nilIfBlank ?? "官方发布盲盒系列",
                        releaseDateText: Self.releaseDateText(createdAt: series.createdAt),
                        priceInCoins: series.priceGoldCoins.map { NSDecimalNumber(decimal: $0).intValue } ?? max(series.priceKeys * 120, 120),
                        keyCost: max(series.priceKeys, 1),
                        highlight: Self.highlight(for: series.status, totalItems: series.totalItems),
                        rarityRates: Self.defaultRarityRates(for: Self.category(for: series.name, keyCost: series.priceKeys)),
                        imageURL: series.imageUrl,
                        previewCards: []
                    )
                }
            }

            if let remoteCollectibles = try? await api.fetchOwnedCollectibles(userId: user.userId), !remoteCollectibles.isEmpty {
                collectibles = remoteCollectibles
            }

            prependActivity(title: "后端同步完成", detail: "已接入旧后端数据，盲盒与收藏从服务端加载", timestamp: "刚刚")
            hasLoadedRemote = true
        } catch {
            prependActivity(title: "模拟模式", detail: "旧后端暂不可用，当前继续展示本地模拟数据", timestamp: "刚刚")
            toastMessage = "后端未连接，当前展示模拟数据"
        }
    }

    private func apply(bootstrap: VitalityAPI.BootstrapResponse) {
        let balance = bootstrap.balance
        let statistics = bootstrap.statistics

        profile.userId = bootstrap.userId
        profile.name = bootstrap.username.nilIfBlank ?? profile.name
        profile.email = bootstrap.email
        profile.vitalityCoins = NSDecimalNumber(decimal: (balance?.vitalityCoins ?? Decimal(profile.vitalityCoins)).rounded(scale: 0)).intValue
        profile.keys = balance?.keysCount ?? profile.keys
        profile.totalBoxes = max(statistics?.totalDrawsCount ?? 0, profile.totalBoxes)

        health = HealthSnapshot(
            moveCalories: health.moveCalories,
            steps: health.steps,
            distance: health.distance,
            standHours: health.standHours,
            winStreak: max(statistics?.currentCheckinStreak ?? 0, 1),
            weeklyGoalHits: min(max(statistics?.totalCheckins ?? health.weeklyGoalHits, 1), 7),
            goalCalories: health.goalCalories
        )
    }

    private func drawBlindBoxRemotely(_ box: BlindBox, seriesID: Int, userID: String, count: Int) async -> [Collectible] {
        guard !isDrawingBlindBox else { return [] }
        isDrawingBlindBox = true
        defer { isDrawingBlindBox = false }

        do {
            let result = try await api.draw(userId: userID, seriesId: seriesID, count: count)
            profile.keys = result.remainingKeys
            profile.totalBoxes += result.count

            let rewards = result.cards.compactMap { apiCard in
                collectible(from: apiCard, fallbackSeries: box.category.rawValue)
            }

            if rewards.isEmpty {
                return openBlindBoxLocally(box, count: count)
            }

            collectibles.insert(contentsOf: rewards.reversed(), at: 0)
            if count > 1 {
                let bestReward = rewards.max(by: { $0.chainValue < $1.chainValue }) ?? rewards[0]
                toastMessage = "十连开启成功，获得 \(rewards.count) 张藏品，最高《\(bestReward.name)》"
                prependActivity(
                    title: "十连开启\(box.title)",
                    detail: "获得 \(rewards.count) 张藏品，最高为 \(bestReward.rarity.rawValue)《\(bestReward.name)》",
                    timestamp: "刚刚"
                )
            } else if let bestReward = rewards.first {
                toastMessage = "开箱成功，获得 \(bestReward.rarity.rawValue) 藏品《\(bestReward.name)》"
                prependActivity(
                    title: "开启\(box.title)",
                    detail: "获得 \(bestReward.rarity.rawValue) 藏品《\(bestReward.name)》",
                    timestamp: "刚刚"
                )
            } else {
                toastMessage = "开箱成功"
            }
            return rewards
        } catch {
            let rewards = openBlindBoxLocally(box, count: count)
            toastMessage = "后端抽盒失败，已切换模拟开箱"
            return rewards
        }
    }

    private func openBlindBoxLocally(_ box: BlindBox, count: Int) -> [Collectible] {
        guard profile.keys >= box.keyCost * count else {
            toastMessage = "钥匙不足，无法开启 \(box.title)"
            return []
        }

        profile.keys -= box.keyCost * count
        profile.totalBoxes += count

        let rewards: [Collectible] = (0..<count).map { _ in
            let rarity = randomRarity(using: box.rarityRates)
            return Collectible(
                id: UUID(),
                remoteCardID: nil,
                name: generatedRewardName(for: box.category, rarity: rarity),
                series: box.category.rawValue,
                rarity: rarity,
                style: rarity == .ssr ? "限定动态卡" : "收藏卡",
                chainValue: Int.random(in: 150...2800),
                isFavorite: rarity == .sr || rarity == .ssr,
                imageURL: nil,
                ownedCount: 1
            )
        }

        collectibles.insert(contentsOf: rewards.reversed(), at: 0)

        if count > 1 {
            let bestReward = rewards.max(by: { $0.chainValue < $1.chainValue }) ?? rewards[0]
            toastMessage = "十连开启成功，获得 \(rewards.count) 张藏品"
            prependActivity(
                title: "十连开启\(box.title)",
                detail: "最高为 \(bestReward.rarity.rawValue)《\(bestReward.name)》",
                timestamp: "刚刚"
            )
        } else if let reward = rewards.first {
            toastMessage = "开箱成功，获得 \(reward.rarity.rawValue) 藏品《\(reward.name)》"
            prependActivity(title: "开启\(box.title)", detail: "获得 \(reward.rarity.rawValue) 藏品《\(reward.name)》", timestamp: "刚刚")
        }

        return rewards
    }

    private func collectible(from apiCard: VitalityAPI.CollectedCard) -> Collectible? {
        guard let rarity = RarityTier(rawValue: apiCard.rarity.uppercased()) else {
            return nil
        }

        return Collectible(
            id: UUID(),
            remoteCardID: apiCard.id,
            name: apiCard.name,
            series: apiCard.seriesName ?? "未知系列",
            rarity: rarity,
            style: apiCard.ownedCount > 1 ? "重复收藏 x\(apiCard.ownedCount)" : "收藏卡",
            chainValue: Self.simulatedFloorPrice(for: rarity, ownedCount: apiCard.ownedCount),
            isFavorite: rarity == .sr || rarity == .ssr,
            imageURL: apiCard.imageUrl,
            ownedCount: max(apiCard.ownedCount, 1)
        )
    }

    private func collectible(from apiCard: VitalityAPI.DrawnCard, fallbackSeries: String) -> Collectible? {
        guard let rarity = RarityTier(rawValue: apiCard.rarity.uppercased()) else {
            return nil
        }

        return Collectible(
            id: UUID(),
            remoteCardID: apiCard.id,
            name: apiCard.name,
            series: fallbackSeries,
            rarity: rarity,
            style: apiCard.assetNumber.map { "资产编号 #\($0)" } ?? "官方藏品",
            chainValue: Self.simulatedFloorPrice(for: rarity, ownedCount: 1),
            isFavorite: rarity == .sr || rarity == .ssr,
            imageURL: apiCard.imageUrl,
            ownedCount: 1
        )
    }

    private func prependActivity(title: String, detail: String, timestamp: String) {
        activities.insert(
            ActivityEntry(id: UUID(), title: title, detail: detail, timestamp: timestamp),
            at: 0
        )
        if activities.count > 12 {
            activities = Array(activities.prefix(12))
        }
    }

    private func randomRarity(using rates: [RarityTier: Int]) -> RarityTier {
        let roll = Int.random(in: 1...100)
        var current = 0
        for tier in [RarityTier.n, .r, .sr, .ssr] {
            current += rates[tier, default: 0]
            if roll <= current {
                return tier
            }
        }
        return .n
    }

    private func generatedRewardName(for category: BlindBoxCategory, rarity: RarityTier) -> String {
        switch (category, rarity) {
        case (.daily, .n): return "热身节拍"
        case (.daily, .r): return "晨曦补给"
        case (.daily, .sr): return "耐力回响"
        case (.daily, .ssr): return "满格觉醒"
        case (.urban, .n): return "路灯切片"
        case (.urban, .r): return "街角起跑"
        case (.urban, .sr): return "霓虹滑步"
        case (.urban, .ssr): return "极夜跨栏"
        case (.legend, .n): return "冠军徽章"
        case (.legend, .r): return "热浪冲刺"
        case (.legend, .sr): return "风暴冲线"
        case (.legend, .ssr): return "终局登顶"
        }
    }
}

private extension VitalityStore {
    static let defaultBlindBoxes: [BlindBox] = [
        BlindBox(
            id: UUID(),
            remoteSeriesID: nil,
            title: "晨光燃脂盲盒",
            category: .daily,
            subtitle: "面向日常运动用户的基础系列",
            releaseDateText: "2026.04.02 10:00",
            priceInCoins: 180,
            keyCost: BlindBoxCategory.daily.keyCost,
            highlight: "适合新手收藏",
            rarityRates: [.n: 62, .r: 25, .sr: 10, .ssr: 3],
            imageURL: nil,
            previewCards: []
        ),
        BlindBox(
            id: UUID(),
            remoteSeriesID: nil,
            title: "夜跑都市盲盒",
            category: .urban,
            subtitle: "霓虹城市主题的潮流系列",
            releaseDateText: "2026.04.06 20:00",
            priceInCoins: 320,
            keyCost: BlindBoxCategory.urban.keyCost,
            highlight: "即将限量发售",
            rarityRates: [.n: 50, .r: 30, .sr: 15, .ssr: 5],
            imageURL: nil,
            previewCards: []
        ),
        BlindBox(
            id: UUID(),
            remoteSeriesID: nil,
            title: "冠军秘藏盲盒",
            category: .legend,
            subtitle: "面向高稀有藏品的进阶系列",
            releaseDateText: "2026.04.12 12:00",
            priceInCoins: 520,
            keyCost: BlindBoxCategory.legend.keyCost,
            highlight: "SSR 概率更高",
            rarityRates: [.n: 35, .r: 35, .sr: 20, .ssr: 10],
            imageURL: nil,
            previewCards: []
        )
    ]

    static let defaultCollectibles: [Collectible] = [
        Collectible(id: UUID(), remoteCardID: nil, name: "风暴冲线", series: "冠军传说", rarity: .ssr, style: "动态卡", chainValue: 2680, isFavorite: true, imageURL: nil, ownedCount: 1),
        Collectible(id: UUID(), remoteCardID: nil, name: "霓虹滑步", series: "城市跑场", rarity: .sr, style: "闪卡", chainValue: 1260, isFavorite: true, imageURL: nil, ownedCount: 1),
        Collectible(id: UUID(), remoteCardID: nil, name: "晨曦补给", series: "活力日常", rarity: .r, style: "普通卡", chainValue: 560, isFavorite: false, imageURL: nil, ownedCount: 1),
        Collectible(id: UUID(), remoteCardID: nil, name: "心率引擎", series: "活力日常", rarity: .n, style: "普通卡", chainValue: 180, isFavorite: false, imageURL: nil, ownedCount: 1),
        Collectible(id: UUID(), remoteCardID: nil, name: "极夜跨栏", series: "城市跑场", rarity: .sr, style: "动态卡", chainValue: 1420, isFavorite: true, imageURL: nil, ownedCount: 1)
    ]

    static let defaultMarketListings: [MarketListing] = [
        MarketListing(id: UUID(), title: "冠军秘藏钥匙", type: .key, price: 240, chainValue: 83, seller: "跑者阿宇", subtitle: "链上估值 83 GAS"),
        MarketListing(id: UUID(), title: "晨光燃脂钥匙", type: .key, price: 95, chainValue: 24, seller: "元气拾荒者", subtitle: "适合低门槛开箱"),
        MarketListing(id: UUID(), title: "霓虹滑步", type: .collectible, price: 1380, chainValue: 426, seller: "夜跑收藏家", subtitle: "SR 闪卡，可单独转售"),
        MarketListing(id: UUID(), title: "心率引擎", type: .collectible, price: 240, chainValue: 76, seller: "体能训练营", subtitle: "N 级基础补完卡")
    ]

    static let defaultActivities: [ActivityEntry] = [
        ActivityEntry(id: UUID(), title: "兑换元气币", detail: "今日消耗热量已兑换 46 元气币", timestamp: "今天 09:20"),
        ActivityEntry(id: UUID(), title: "开启夜跑都市盲盒", detail: "获得 SR 藏品《霓虹滑步》", timestamp: "昨天 21:06"),
        ActivityEntry(id: UUID(), title: "挂单出售藏品", detail: "《晨曦补给》已在市场中心上架", timestamp: "昨天 14:12")
    ]

    nonisolated static func category(for seriesName: String, keyCost: Int) -> BlindBoxCategory {
        if seriesName.contains("夜") || seriesName.contains("城") || keyCost == 2 {
            return .urban
        }
        if seriesName.contains("冠") || seriesName.contains("传说") || seriesName.contains("秘藏") || keyCost >= 3 {
            return .legend
        }
        return .daily
    }

    nonisolated static func highlight(for status: String, totalItems: Int) -> String {
        switch status.lowercased() {
        case "active":
            return totalItems > 0 ? "在售 \(totalItems) 款藏品" : "正在发售"
        case "inactive":
            return "暂未开放"
        default:
            return "官方系列"
        }
    }

    nonisolated static func defaultRarityRates(for category: BlindBoxCategory) -> [RarityTier: Int] {
        switch category {
        case .daily:
            return [.n: 62, .r: 25, .sr: 10, .ssr: 3]
        case .urban:
            return [.n: 50, .r: 30, .sr: 15, .ssr: 5]
        case .legend:
            return [.n: 35, .r: 35, .sr: 20, .ssr: 10]
        }
    }

    nonisolated static func simulatedFloorPrice(for rarity: RarityTier, ownedCount: Int) -> Int {
        let base: Int
        switch rarity {
        case .n: base = 180
        case .r: base = 520
        case .sr: base = 1280
        case .ssr: base = 2680
        }
        return base + max(ownedCount - 1, 0) * 36
    }

    nonisolated static func releaseDateText(createdAt: String?) -> String {
        guard let createdAt, !createdAt.isEmpty else {
            return "近期发售"
        }
        return createdAt.replacingOccurrences(of: "T", with: " ")
    }
}

private struct VitalityAPI {
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()

    private var baseURLs: [URL] {
        [
            URL(string: "http://127.0.0.1:8080/api")!,
            URL(string: "http://localhost:8080/api")!
        ]
    }

    func ensureDemoUser(identity: String, password: String, cachedUserID: String?) async throws -> AuthResponse {
        if let cachedUserID, !cachedUserID.isEmpty {
            return AuthResponse(userId: cachedUserID, username: "元气跑者", email: demoEmail(for: identity))
        }

        let request = RegisterRequest(
            username: "元气跑者\(identity.suffix(4))",
            email: demoEmail(for: identity),
            password: password
        )

        do {
            return try await post(path: "auth/register", body: request, responseType: AuthResponse.self)
        } catch {
            return try await post(
                path: "auth/login",
                body: LoginRequest(email: demoEmail(for: identity), password: password),
                responseType: AuthResponse.self
            )
        }
    }

    func bootstrap(userId: String) async throws -> BootstrapResponse {
        try await get(path: "auth/bootstrap/\(userId)", responseType: BootstrapResponse.self)
    }

    func fetchActiveSeries() async throws -> [SeriesResponse] {
        try await get(path: "blindbox/series/active", responseType: [SeriesResponse].self)
    }

    func fetchSeriesDetail(seriesId: Int) async throws -> SeriesDetailResponse {
        try await get(path: "blindbox/series/\(seriesId)", responseType: SeriesDetailResponse.self)
    }

    func fetchOwnedCollectibles(userId: String) async throws -> [Collectible] {
        let ownedSeries = try await get(path: "blindbox/collection/\(userId)/series", responseType: [OwnedSeriesResponse].self)
        guard !ownedSeries.isEmpty else { return [] }

        var result: [Collectible] = []
        for series in ownedSeries {
            let detail = try await get(
                path: "blindbox/collection/\(userId)/series/\(series.id)",
                responseType: OwnedSeriesDetailResponse.self
            )

            let cards = detail.cards.compactMap { card -> Collectible? in
                guard card.ownedCount > 0, let rarity = RarityTier(rawValue: card.rarity.uppercased()) else {
                    return nil
                }

                return Collectible(
                    id: UUID(),
                    remoteCardID: card.id,
                    name: card.name,
                    series: detail.name,
                    rarity: rarity,
                    style: card.ownedCount > 1 ? "重复收藏 x\(card.ownedCount)" : "官方藏品",
                    chainValue: VitalityStore.simulatedFloorPrice(for: rarity, ownedCount: card.ownedCount),
                    isFavorite: rarity == .sr || rarity == .ssr,
                    imageURL: card.imageUrl,
                    ownedCount: card.ownedCount
                )
            }

            result.append(contentsOf: cards)
        }
        return result.sorted(by: { $0.chainValue > $1.chainValue })
    }

    func draw(userId: String, seriesId: Int, count: Int) async throws -> DrawResponse {
        try await post(
            path: "blindbox/draw",
            body: DrawRequest(userId: userId, seriesId: seriesId, count: count),
            responseType: DrawResponse.self
        )
    }

    private func demoEmail(for identity: String) -> String {
        "demo+\(identity.prefix(12))@vitality.local"
    }

    private func get<T: Decodable>(path: String, responseType: T.Type) async throws -> T {
        try await request(path: path, method: "GET", body: Optional<Data>.none, responseType: responseType)
    }

    private func post<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request,
        responseType: Response.Type
    ) async throws -> Response {
        let bodyData = try JSONEncoder().encode(body)
        return try await request(path: path, method: "POST", body: bodyData, responseType: responseType)
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        responseType: T.Type
    ) async throws -> T {
        var lastError: Error?

        for baseURL in baseURLs {
            do {
                var request = URLRequest(url: baseURL.appendingPathComponent(path))
                request.httpMethod = method
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 12
                request.httpBody = body

                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.httpStatus(httpResponse.statusCode)
                }

                let envelope = try decoder.decode(APIEnvelope<T>.self, from: data)
                guard envelope.code == 200 else {
                    throw APIError.message(envelope.message ?? "服务端返回异常")
                }
                guard let payload = envelope.data else {
                    throw APIError.message("服务端未返回数据")
                }
                return payload
            } catch {
                lastError = error
            }
        }

        throw lastError ?? APIError.message("无法连接旧后端")
    }
}

private extension VitalityAPI {
    struct APIEnvelope<T: Decodable>: Decodable {
        let code: Int
        let message: String?
        let data: T?
    }

    struct RegisterRequest: Encodable {
        let username: String
        let email: String
        let password: String
    }

    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    struct DrawRequest: Encodable {
        let userId: String
        let seriesId: Int
        let count: Int
    }

    struct AuthResponse: Decodable {
        let userId: String
        let username: String
        let email: String
    }

    struct BootstrapResponse: Decodable {
        let userId: String
        let username: String?
        let email: String?
        let status: String?
        let balance: BalanceResponse?
        let statistics: StatisticsResponse?
        let checkedInToday: Bool
    }

    struct BalanceResponse: Decodable {
        let vitalityCoins: Decimal?
        let keysCount: Int?
        let goldCoins: Decimal?
    }

    struct StatisticsResponse: Decodable {
        let totalCheckins: Int?
        let currentCheckinStreak: Int?
        let totalCardsObtained: Int?
        let totalDrawsCount: Int?
    }

    struct SeriesResponse: Decodable {
        let id: Int
        let name: String
        let description: String?
        let totalItems: Int
        let status: String
        let imageUrl: String?
        let priceKeys: Int
        let priceGoldCoins: Decimal?
        let createdAt: String?
    }

    struct OwnedSeriesResponse: Decodable {
        let id: Int
        let name: String
    }

    struct SeriesDetailResponse: Decodable {
        let id: Int
        let name: String
        let description: String?
        let imageUrl: String?
        let priceKeys: Int?
        let priceGoldCoins: Decimal?
        let cards: [SeriesDetailCard]
    }

    struct SeriesDetailCard: Decodable {
        let id: Int
        let seriesId: Int?
        let name: String
        let rarity: String
        let probability: Double?
        let imageUrl: String?
        let description: String?
    }

    struct OwnedSeriesDetailResponse: Decodable {
        let id: Int
        let name: String
        let cards: [CollectedCard]
    }

    struct CollectedCard: Decodable {
        let id: Int
        let seriesId: Int?
        let name: String
        let rarity: String
        let imageUrl: String?
        let description: String?
        let ownedCount: Int

        var seriesName: String? { nil }
    }

    struct DrawResponse: Decodable {
        let card: DrawnCard?
        let cards: [DrawnCard]
        let isDuplicate: Bool?
        let keysUsed: Int
        let remainingKeys: Int
        let goldUsed: Decimal?
        let remainingGold: Decimal?
        let count: Int
        let drawRecordId: Int?
        let transactionId: String?
    }

    struct DrawnCard: Decodable {
        let id: Int
        let seriesId: Int?
        let name: String
        let rarity: String
        let probability: Double?
        let imageUrl: String?
        let description: String?
        let cardInstanceId: Int?
        let assetNumber: Int?
    }

    enum APIError: LocalizedError {
        case invalidResponse
        case httpStatus(Int)
        case message(String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "服务端响应无效"
            case .httpStatus(let statusCode):
                return "服务端状态码异常：\(statusCode)"
            case .message(let message):
                return message
            }
        }
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var original = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &original, scale, .plain)
        return rounded
    }
}

private extension Optional where Wrapped == String {
    var nilIfBlank: String? {
        switch self?.trimmingCharacters(in: .whitespacesAndNewlines) {
        case .some(let value) where !value.isEmpty:
            return value
        default:
            return nil
        }
    }
}
