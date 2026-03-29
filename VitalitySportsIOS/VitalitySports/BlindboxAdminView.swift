import SwiftUI

// MARK: - Admin Data Models

struct AdminSeries: Identifiable, Codable {
    let id: Int
    let seriesCode: String
    let name: String
    let creator: String
    let description: String?
    let coverImage: String?
    let coverColor: String?
    let priceType: String?
    let priceKeys: Int?
    let priceGoldCoins: Double?
    let totalCards: Int?
    let isActive: Bool?
    let totalStock: Int?
    let soldCount: Int?
    let maxPerUser: Int?
}

struct AdminCard: Identifiable, Codable {
    let id: Int
    let cardCode: String
    let blindboxSeriesId: Int
    let name: String
    let rarity: String
    let frontImageUrl: String?
    let backImageUrl: String?
    let description: String?
    let totalSupply: Int?
    let assetNumberStart: Int?
    let assetNumberEnd: Int?
    let mintedCount: Int?
    let isActive: Bool?
    let isTradable: Bool?
}

struct AdminPoolEntry: Identifiable, Codable {
    let id: Int
    let blindboxSeriesId: Int
    let cardDesignId: Int
    let dropWeight: Int
    let poolType: String?
    let isActive: Bool?
}

struct CardWithPool: Identifiable {
    let card: AdminCard
    let poolEntry: AdminPoolEntry?
    var id: Int { card.id }
}

// MARK: - Admin API

private struct AdminAPI {
    private let session = URLSession.shared
    private let baseURLs = [
        URL(string: "http://127.0.0.1:8080/api")!,
        URL(string: "http://localhost:8080/api")!
    ]

    // Series
    func listSeries() async throws -> [AdminSeries] {
        try await get("admin/blindbox/series")
    }
    func createSeries(_ body: CreateSeriesBody) async throws -> AdminSeries {
        try await post("admin/blindbox/series", body: body)
    }
    func updateSeries(id: Int, _ body: UpdateSeriesBody) async throws -> AdminSeries {
        try await send("admin/blindbox/series/\(id)", method: "PUT", body: body)
    }
    func deleteSeries(id: Int) async throws {
        try await deleteRequest("admin/blindbox/series/\(id)")
    }

    // Cards
    func listCards(seriesId: Int) async throws -> [AdminCard] {
        try await get("admin/blindbox/series/\(seriesId)/cards")
    }
    func createCard(_ body: CreateCardBody) async throws -> AdminCard {
        try await post("admin/blindbox/cards", body: body)
    }
    func updateCard(id: Int, _ body: UpdateCardBody) async throws -> AdminCard {
        try await send("admin/blindbox/cards/\(id)", method: "PUT", body: body)
    }
    func deleteCard(id: Int) async throws {
        try await deleteRequest("admin/blindbox/cards/\(id)")
    }

    // Pool
    func listPool(seriesId: Int) async throws -> [AdminPoolEntry] {
        try await get("admin/blindbox/series/\(seriesId)/pool")
    }
    func addToPool(_ body: AddPoolBody) async throws -> AdminPoolEntry {
        try await post("admin/blindbox/pool", body: body)
    }
    func updatePool(id: Int, _ body: UpdatePoolBody) async throws -> AdminPoolEntry {
        try await send("admin/blindbox/pool/\(id)", method: "PUT", body: body)
    }
    func removeFromPool(id: Int) async throws {
        try await deleteRequest("admin/blindbox/pool/\(id)")
    }

    // HTTP Helpers
    private func get<T: Decodable>(_ path: String) async throws -> T {
        try await request(path: path, method: "GET", body: nil as Data?)
    }
    private func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        try await send(path, method: "POST", body: body)
    }
    private func send<B: Encodable, T: Decodable>(_ path: String, method: String, body: B) async throws -> T {
        let data = try JSONEncoder().encode(body)
        return try await request(path: path, method: method, body: data)
    }
    private func deleteRequest(_ path: String) async throws {
        var lastError: Error = URLError(.cannotConnectToHost)
        for base in baseURLs {
            do {
                var urlReq = URLRequest(url: base.appendingPathComponent(path))
                urlReq.httpMethod = "DELETE"
                urlReq.timeoutInterval = 12
                let (data, response) = try await session.data(for: urlReq)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw AdminAPIError.httpError
                }
                if let env = try? JSONDecoder().decode(SimpleEnvelope.self, from: data), env.code != 200 {
                    throw AdminAPIError.serverError(env.message ?? "操作失败")
                }
                return
            } catch let e as AdminAPIError {
                throw e
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    private func request<T: Decodable>(path: String, method: String, body: Data?) async throws -> T {
        var lastError: Error = URLError(.cannotConnectToHost)
        for base in baseURLs {
            do {
                var req = URLRequest(url: base.appendingPathComponent(path))
                req.httpMethod = method
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.timeoutInterval = 12
                req.httpBody = body
                let (data, response) = try await session.data(for: req)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw AdminAPIError.httpError
                }
                let envelope = try JSONDecoder().decode(Envelope<T>.self, from: data)
                guard envelope.code == 200 else {
                    throw AdminAPIError.serverError(envelope.message ?? "服务端错误")
                }
                guard let payload = envelope.data else {
                    throw AdminAPIError.serverError("服务端未返回数据")
                }
                return payload
            } catch let e as AdminAPIError {
                throw e
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    struct Envelope<T: Decodable>: Decodable {
        let code: Int
        let message: String?
        let data: T?
    }
    struct SimpleEnvelope: Decodable {
        let code: Int
        let message: String?
    }
}

enum AdminAPIError: LocalizedError {
    case httpError
    case serverError(String)
    var errorDescription: String? {
        switch self {
        case .httpError: return "HTTP 请求失败"
        case .serverError(let msg): return msg
        }
    }
}

// MARK: - Request Bodies

struct CreateSeriesBody: Encodable {
    var seriesCode: String
    var name: String
    var creator: String
    var description: String
    var coverImage: String
    var priceType: String = "KEYS_ONLY"
    var priceKeys: Int = 1
    var isActive: Bool = true
    var totalStock: Int?
}

struct UpdateSeriesBody: Encodable {
    var name: String?
    var creator: String?
    var description: String?
    var coverImage: String?
    var priceType: String?
    var priceKeys: Int?
    var isActive: Bool?
    var totalStock: Int?
}

struct CreateCardBody: Encodable {
    var blindboxSeriesId: Int
    var cardCode: String
    var name: String
    var rarity: String
    var frontImageUrl: String
    var description: String
    var totalSupply: Int = 100
    var assetNumberStart: Int = 1
    var dropWeight: Int = 10
}

struct UpdateCardBody: Encodable {
    var name: String?
    var rarity: String?
    var frontImageUrl: String?
    var description: String?
    var isActive: Bool?
    var dropWeight: Int?
}

struct AddPoolBody: Encodable {
    var blindboxSeriesId: Int
    var cardDesignId: Int
    var dropWeight: Int
}

struct UpdatePoolBody: Encodable {
    var dropWeight: Int?
    var isActive: Bool?
}

// MARK: - Image Thumbnail Component

private struct AdminThumbnail: View {
    let urlString: String?
    var size: CGFloat = 48
    var cornerRadius: CGFloat = 10

    var body: some View {
        Group {
            if let urlString, !urlString.isEmpty, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: size * 0.35))
                    .foregroundStyle(.white.opacity(0.25))
            )
    }
}

// MARK: - Inline Image Preview Component

private struct ImagePreviewRow: View {
    let urlString: String

    var body: some View {
        if !urlString.isEmpty, let url = URL(string: urlString) {
            HStack {
                Spacer()
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    case .failure:
                        Label("图片加载失败", systemImage: "exclamationmark.triangle")
                            .font(.system(size: 12))
                            .foregroundStyle(.red.opacity(0.7))
                    case .empty:
                        ProgressView().tint(VitalityTheme.accent)
                    @unknown default:
                        EmptyView()
                    }
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Main Admin View

struct BlindboxAdminView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var series: [AdminSeries] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCreateSeries = false
    @State private var deletingId: Int?

    private let api = AdminAPI()

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()

                Group {
                    if isLoading && series.isEmpty {
                        ProgressView()
                            .tint(VitalityTheme.accent)
                            .scaleEffect(1.5)
                    } else {
                        seriesList
                    }
                }
            }
            .navigationTitle("盲盒管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(VitalityTheme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSeries = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(VitalityTheme.accent)
                    }
                }
            }
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $showCreateSeries) {
                CreateSeriesSheet { newSeries in
                    series.insert(newSeries, at: 0)
                }
            }
            .task { await loadSeries() }
        }
    }

    private var seriesList: some View {
        List {
            if series.isEmpty && !isLoading {
                ContentUnavailableView("暂无盲盒系列", systemImage: "shippingbox")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(series) { item in
                    NavigationLink {
                        AdminSeriesDetailView(series: item)
                    } label: {
                        SeriesRowView(series: item)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(VitalityTheme.card)
                            .padding(.vertical, 2)
                    )
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task { await deleteSeries(item) }
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { await loadSeries() }
    }

    private func loadSeries() async {
        isLoading = true
        do {
            series = try await api.listSeries()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func deleteSeries(_ item: AdminSeries) async {
        do {
            try await api.deleteSeries(id: item.id)
            series.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct SeriesRowView: View {
    let series: AdminSeries

    var body: some View {
        HStack(spacing: 12) {
            AdminThumbnail(urlString: series.coverImage, size: 48)
                .overlay(
                    series.coverImage == nil || series.coverImage!.isEmpty
                    ? AnyView(
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(VitalityTheme.orange)
                    )
                    : AnyView(EmptyView())
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(series.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    activePill
                }
                HStack(spacing: 6) {
                    Text(series.seriesCode)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("·")
                        .foregroundStyle(.white.opacity(0.3))
                    Text("\(series.totalCards ?? 0) 件藏品")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    if let keys = series.priceKeys {
                        Text("·")
                            .foregroundStyle(.white.opacity(0.3))
                        Text("\(keys) 钥匙")
                            .font(.system(size: 12))
                            .foregroundStyle(VitalityTheme.accent.opacity(0.8))
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var activePill: some View {
        Text(series.isActive == true ? "上架" : "下架")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(series.isActive == true ? VitalityTheme.accent : .white.opacity(0.4))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(series.isActive == true
                          ? VitalityTheme.accent.opacity(0.15)
                          : Color.white.opacity(0.08))
            )
    }
}

// MARK: - Series Detail View

struct AdminSeriesDetailView: View {
    let series: AdminSeries
    @State private var cards: [AdminCard] = []
    @State private var poolEntries: [AdminPoolEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCreateCard = false
    @State private var showEditSeries = false
    @State private var editingCard: AdminCard?
    @State private var currentSeries: AdminSeries

    private let api = AdminAPI()

    init(series: AdminSeries) {
        self.series = series
        _currentSeries = State(initialValue: series)
    }

    var cardsWithPool: [CardWithPool] {
        cards.map { card in
            CardWithPool(
                card: card,
                poolEntry: poolEntries.first { $0.cardDesignId == card.id }
            )
        }
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            List {
                // Series info header
                seriesInfoSection
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                // Cards section header
                Section {
                    if isLoading && cards.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView().tint(VitalityTheme.accent)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else if cardsWithPool.isEmpty {
                        Text("暂无藏品，点击 + 添加")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.4))
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(cardsWithPool) { item in
                            Button {
                                editingCard = item.card
                            } label: {
                                CardWithPoolRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(VitalityTheme.card)
                                    .padding(.vertical, 2)
                            )
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task { await deleteCard(item.card) }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("藏品列表")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .textCase(nil)
                        Spacer()
                        Button {
                            showCreateCard = true
                        } label: {
                            Label("添加藏品", systemImage: "plus.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(VitalityTheme.accent)
                        }
                    }
                    .padding(.bottom, 4)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(currentSeries.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") { showEditSeries = true }
                    .foregroundStyle(VitalityTheme.accent)
            }
        }
        .alert("错误", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("确定") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showCreateCard) {
            CreateCardSheet(seriesId: currentSeries.id) { newCard in
                cards.append(newCard)
            }
        }
        .sheet(isPresented: $showEditSeries) {
            EditSeriesSheet(series: currentSeries) { updated in
                currentSeries = updated
            }
        }
        .sheet(item: $editingCard) { card in
            EditCardSheet(card: card, poolEntry: poolEntries.first { $0.cardDesignId == card.id }) { updatedCard, updatedPool in
                if let idx = cards.firstIndex(where: { $0.id == updatedCard.id }) {
                    cards[idx] = updatedCard
                }
                if let pool = updatedPool {
                    if let idx = poolEntries.firstIndex(where: { $0.cardDesignId == pool.cardDesignId }) {
                        poolEntries[idx] = pool
                    } else {
                        poolEntries.append(pool)
                    }
                }
            }
        }
        .refreshable { await loadData() }
        .task { await loadData() }
    }

    private var seriesInfoSection: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 14) {
                // 封面图
                if let cover = currentSeries.coverImage, !cover.isEmpty {
                    AdminThumbnail(urlString: cover, size: UIScreen.main.bounds.width - 64, cornerRadius: 10)
                        .frame(height: 140)
                        .clipped()
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentSeries.name)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(currentSeries.seriesCode)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Text(currentSeries.isActive == true ? "上架中" : "已下架")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(currentSeries.isActive == true ? VitalityTheme.accent : .white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(
                            currentSeries.isActive == true
                            ? VitalityTheme.accent.opacity(0.15)
                            : Color.white.opacity(0.08)
                        ))
                }

                Divider().background(Color.white.opacity(0.1))

                HStack(spacing: 20) {
                    infoCell(label: "价格", value: "\(currentSeries.priceKeys ?? 1) 钥匙")
                    infoCell(label: "总藏品", value: "\(currentSeries.totalCards ?? 0) 件")
                    infoCell(label: "已售", value: "\(currentSeries.soldCount ?? 0) 次")
                    if let stock = currentSeries.totalStock {
                        infoCell(label: "库存", value: "\(stock)")
                    }
                }

                if let desc = currentSeries.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func infoCell(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private func loadData() async {
        isLoading = true
        async let cardsTask: [AdminCard] = (try? api.listCards(seriesId: currentSeries.id)) ?? []
        async let poolTask: [AdminPoolEntry] = (try? api.listPool(seriesId: currentSeries.id)) ?? []
        let (c, p) = await (cardsTask, poolTask)
        cards = c
        poolEntries = p
        isLoading = false
    }

    private func deleteCard(_ card: AdminCard) async {
        do {
            try await api.deleteCard(id: card.id)
            cards.removeAll { $0.id == card.id }
            poolEntries.removeAll { $0.cardDesignId == card.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct CardWithPoolRow: View {
    let item: CardWithPool

    var rarityColor: Color {
        switch item.card.rarity.uppercased() {
        case "SSR": return VitalityTheme.orange
        case "SR": return .purple
        case "R": return VitalityTheme.cyan
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AdminThumbnail(urlString: item.card.frontImageUrl, size: 48, cornerRadius: 10)
                    .overlay(
                        item.card.frontImageUrl == nil || item.card.frontImageUrl!.isEmpty
                        ? AnyView(
                            Text(item.card.rarity.uppercased())
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(rarityColor)
                        )
                        : AnyView(EmptyView())
                    )
                // 稀有度小标签
                Text(item.card.rarity.uppercased())
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(rarityColor))
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.card.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text(item.card.cardCode)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                    if let supply = item.card.totalSupply {
                        Text("·")
                            .foregroundStyle(.white.opacity(0.3))
                        let minted = item.card.mintedCount ?? 0
                        Text("\(minted)/\(supply)")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let pool = item.poolEntry {
                    Text("权重 \(pool.dropWeight)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VitalityTheme.accent)
                    Text(pool.isActive == true ? "在池" : "未启用")
                        .font(.system(size: 11))
                        .foregroundStyle(pool.isActive == true ? .green : .white.opacity(0.3))
                } else {
                    Text("未入池")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Create Series Sheet

struct CreateSeriesSheet: View {
    let onCreated: (AdminSeries) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var name = ""
    @State private var creator = ""
    @State private var description = ""
    @State private var coverImage = ""
    @State private var priceKeys = "1"
    @State private var priceType = "KEYS_ONLY"
    @State private var totalStock = ""
    @State private var isActive = true
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = AdminAPI()
    private let priceTypeOptions = ["KEYS_ONLY", "KEYS_AND_CASH", "CASH_ONLY"]
    private let priceTypeLabels = ["仅钥匙", "钥匙+金币", "仅金币"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()
                adminForm
            }
            .navigationTitle("创建盲盒系列")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView().tint(VitalityTheme.accent)
                    } else {
                        Button("创建") { Task { await submit() } }
                            .foregroundStyle(VitalityTheme.accent)
                            .disabled(code.isEmpty || name.isEmpty)
                    }
                }
            }
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private var adminForm: some View {
        Form {
            Section("基本信息") {
                AdminTextField(label: "系列代码 *", placeholder: "如 URBAN_001", text: $code)
                AdminTextField(label: "系列名称 *", placeholder: "如 城市跑场系列", text: $name)
                AdminTextField(label: "创作者", placeholder: "如 YQ Motion Lab", text: $creator)
                AdminTextField(label: "简介", placeholder: "系列简介", text: $description)
                AdminTextField(label: "封面图 URL", placeholder: "https://...", text: $coverImage)
                ImagePreviewRow(urlString: coverImage)
            }
            .listRowBackground(VitalityTheme.card)

            Section("价格设置") {
                Picker("支付方式", selection: $priceType) {
                    ForEach(0..<priceTypeOptions.count, id: \.self) { i in
                        Text(priceTypeLabels[i]).tag(priceTypeOptions[i])
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(VitalityTheme.card)

                AdminTextField(label: "钥匙数量", placeholder: "1", text: $priceKeys)
                    .keyboardType(.numberPad)
            }
            .listRowBackground(VitalityTheme.card)

            Section("库存与状态") {
                AdminTextField(label: "总库存（空=不限）", placeholder: "", text: $totalStock)
                    .keyboardType(.numberPad)
                Toggle("立即上架", isOn: $isActive)
                    .tint(VitalityTheme.accent)
            }
            .listRowBackground(VitalityTheme.card)
        }
        .scrollContentBackground(.hidden)
        .foregroundStyle(.white)
    }

    private func submit() async {
        isLoading = true
        let body = CreateSeriesBody(
            seriesCode: code.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces),
            creator: creator.isEmpty ? "管理员" : creator,
            description: description,
            coverImage: coverImage,
            priceType: priceType,
            priceKeys: Int(priceKeys) ?? 1,
            isActive: isActive,
            totalStock: totalStock.isEmpty ? nil : Int(totalStock)
        )
        do {
            let created = try await api.createSeries(body)
            onCreated(created)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Edit Series Sheet

struct EditSeriesSheet: View {
    let series: AdminSeries
    let onUpdated: (AdminSeries) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var creator: String
    @State private var description: String
    @State private var coverImage: String
    @State private var priceKeys: String
    @State private var priceType: String
    @State private var totalStock: String
    @State private var isActive: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = AdminAPI()
    private let priceTypeOptions = ["KEYS_ONLY", "KEYS_AND_CASH", "CASH_ONLY"]
    private let priceTypeLabels = ["仅钥匙", "钥匙+金币", "仅金币"]

    init(series: AdminSeries, onUpdated: @escaping (AdminSeries) -> Void) {
        self.series = series
        self.onUpdated = onUpdated
        _name = State(initialValue: series.name)
        _creator = State(initialValue: series.creator)
        _description = State(initialValue: series.description ?? "")
        _coverImage = State(initialValue: series.coverImage ?? "")
        _priceKeys = State(initialValue: "\(series.priceKeys ?? 1)")
        _priceType = State(initialValue: series.priceType ?? "KEYS_ONLY")
        _totalStock = State(initialValue: series.totalStock.map { "\($0)" } ?? "")
        _isActive = State(initialValue: series.isActive ?? true)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()

                Form {
                    Section("基本信息") {
                        AdminTextField(label: "系列名称", placeholder: "", text: $name)
                        AdminTextField(label: "创作者", placeholder: "", text: $creator)
                        AdminTextField(label: "简介", placeholder: "", text: $description)
                        AdminTextField(label: "封面图 URL", placeholder: "", text: $coverImage)
                        ImagePreviewRow(urlString: coverImage)
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("价格设置") {
                        Picker("支付方式", selection: $priceType) {
                            ForEach(0..<priceTypeOptions.count, id: \.self) { i in
                                Text(priceTypeLabels[i]).tag(priceTypeOptions[i])
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(VitalityTheme.card)

                        AdminTextField(label: "钥匙数量", placeholder: "", text: $priceKeys)
                            .keyboardType(.numberPad)
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("库存与状态") {
                        AdminTextField(label: "总库存（空=不限）", placeholder: "", text: $totalStock)
                            .keyboardType(.numberPad)
                        Toggle("上架状态", isOn: $isActive)
                            .tint(VitalityTheme.accent)
                    }
                    .listRowBackground(VitalityTheme.card)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
            }
            .navigationTitle("编辑系列")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView().tint(VitalityTheme.accent)
                    } else {
                        Button("保存") { Task { await submit() } }
                            .foregroundStyle(VitalityTheme.accent)
                    }
                }
            }
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func submit() async {
        isLoading = true
        let body = UpdateSeriesBody(
            name: name.isEmpty ? nil : name,
            creator: creator.isEmpty ? nil : creator,
            description: description.isEmpty ? nil : description,
            coverImage: coverImage.isEmpty ? nil : coverImage,
            priceType: priceType,
            priceKeys: Int(priceKeys),
            isActive: isActive,
            totalStock: totalStock.isEmpty ? nil : Int(totalStock)
        )
        do {
            let updated = try await api.updateSeries(id: series.id, body)
            onUpdated(updated)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Create Card Sheet

struct CreateCardSheet: View {
    let seriesId: Int
    let onCreated: (AdminCard) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var name = ""
    @State private var rarity = "N"
    @State private var frontImageUrl = ""
    @State private var description = ""
    @State private var totalSupply = "100"
    @State private var assetStart = "1"
    @State private var dropWeight = "10"
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = AdminAPI()
    private let rarities = ["N", "R", "SR", "SSR"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()

                Form {
                    Section("基本信息") {
                        AdminTextField(label: "卡片代码 *", placeholder: "如 CARD_001", text: $code)
                        AdminTextField(label: "藏品名称 *", placeholder: "如 城市疾风者", text: $name)
                        AdminTextField(label: "简介", placeholder: "藏品描述", text: $description)
                        AdminTextField(label: "正面图片 URL", placeholder: "https://...", text: $frontImageUrl)
                        ImagePreviewRow(urlString: frontImageUrl)
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("稀有度") {
                        Picker("稀有度", selection: $rarity) {
                            ForEach(rarities, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(VitalityTheme.card)

                        rarityPreview
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("发行设置") {
                        AdminTextField(label: "总发行量", placeholder: "100", text: $totalSupply)
                            .keyboardType(.numberPad)
                        AdminTextField(label: "起始编号", placeholder: "1", text: $assetStart)
                            .keyboardType(.numberPad)
                        AdminTextField(label: "卡池权重", placeholder: "10", text: $dropWeight)
                            .keyboardType(.numberPad)
                        Text("权重说明：N=90，R=8，SR=2，SSR=1（参考值）")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .listRowBackground(VitalityTheme.card)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
            }
            .navigationTitle("添加藏品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView().tint(VitalityTheme.accent)
                    } else {
                        Button("添加") { Task { await submit() } }
                            .foregroundStyle(VitalityTheme.accent)
                            .disabled(code.isEmpty || name.isEmpty)
                    }
                }
            }
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private var rarityPreview: some View {
        HStack {
            Text("预览")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            RarityBadge(rarity: RarityTier(rawValue: rarity) ?? .n)
        }
    }

    private func submit() async {
        isLoading = true
        let body = CreateCardBody(
            blindboxSeriesId: seriesId,
            cardCode: code.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces),
            rarity: rarity,
            frontImageUrl: frontImageUrl,
            description: description,
            totalSupply: Int(totalSupply) ?? 100,
            assetNumberStart: Int(assetStart) ?? 1,
            dropWeight: Int(dropWeight) ?? 10
        )
        do {
            let created = try await api.createCard(body)
            onCreated(created)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Edit Card Sheet

struct EditCardSheet: View {
    let card: AdminCard
    let poolEntry: AdminPoolEntry?
    let onUpdated: (AdminCard, AdminPoolEntry?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var rarity: String
    @State private var frontImageUrl: String
    @State private var description: String
    @State private var dropWeight: String
    @State private var isActive: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = AdminAPI()
    private let rarities = ["N", "R", "SR", "SSR"]

    init(card: AdminCard, poolEntry: AdminPoolEntry?, onUpdated: @escaping (AdminCard, AdminPoolEntry?) -> Void) {
        self.card = card
        self.poolEntry = poolEntry
        self.onUpdated = onUpdated
        _name = State(initialValue: card.name)
        _rarity = State(initialValue: card.rarity.uppercased())
        _frontImageUrl = State(initialValue: card.frontImageUrl ?? "")
        _description = State(initialValue: card.description ?? "")
        _dropWeight = State(initialValue: poolEntry.map { "\($0.dropWeight)" } ?? "10")
        _isActive = State(initialValue: card.isActive ?? true)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradientBackground()

                Form {
                    Section("藏品信息") {
                        AdminTextField(label: "藏品名称", placeholder: "", text: $name)
                        AdminTextField(label: "正面图片 URL", placeholder: "", text: $frontImageUrl)
                        ImagePreviewRow(urlString: frontImageUrl)
                        AdminTextField(label: "简介", placeholder: "", text: $description)

                        HStack {
                            Text("代码")
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            Text(card.cardCode)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        if let supply = card.totalSupply {
                            HStack {
                                Text("发行量")
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("\(card.mintedCount ?? 0) / \(supply)")
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("稀有度") {
                        Picker("稀有度", selection: $rarity) {
                            ForEach(rarities, id: \.self) { r in
                                Text(r).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(VitalityTheme.card)

                        HStack {
                            Text("预览")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.5))
                            Spacer()
                            RarityBadge(rarity: RarityTier(rawValue: rarity) ?? .n)
                        }
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("卡池设置") {
                        AdminTextField(
                            label: "卡池权重",
                            placeholder: poolEntry == nil ? "填写后将加入卡池" : "",
                            text: $dropWeight
                        )
                        .keyboardType(.numberPad)

                        if poolEntry != nil {
                            Text("修改权重后自动同步卡池")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                        } else {
                            Text("当前未在卡池中，保存后将自动加入")
                                .font(.system(size: 12))
                                .foregroundStyle(VitalityTheme.orange.opacity(0.8))
                        }
                    }
                    .listRowBackground(VitalityTheme.card)

                    Section("状态") {
                        Toggle("启用藏品", isOn: $isActive)
                            .tint(VitalityTheme.accent)
                    }
                    .listRowBackground(VitalityTheme.card)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
            }
            .navigationTitle("编辑藏品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView().tint(VitalityTheme.accent)
                    } else {
                        Button("保存") { Task { await submit() } }
                            .foregroundStyle(VitalityTheme.accent)
                    }
                }
            }
            .alert("错误", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func submit() async {
        isLoading = true
        let weight = Int(dropWeight)
        let body = UpdateCardBody(
            name: name.isEmpty ? nil : name,
            rarity: rarity,
            frontImageUrl: frontImageUrl.isEmpty ? nil : frontImageUrl,
            description: description.isEmpty ? nil : description,
            isActive: isActive,
            dropWeight: weight
        )
        do {
            let updatedCard = try await api.updateCard(id: card.id, body)
            var updatedPool: AdminPoolEntry? = nil

            if let weight, weight > 0 {
                if let existing = poolEntry {
                    updatedPool = try await api.updatePool(id: existing.id, UpdatePoolBody(dropWeight: weight))
                } else {
                    updatedPool = try await api.addToPool(AddPoolBody(
                        blindboxSeriesId: card.blindboxSeriesId,
                        cardDesignId: card.id,
                        dropWeight: weight
                    ))
                }
            }

            onUpdated(updatedCard, updatedPool)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Shared Admin Form Component

private struct AdminTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
                .tint(VitalityTheme.accent)
        }
        .padding(.vertical, 2)
    }
}
