import SwiftUI

enum VitalityTheme {
    static let accent = Color(red: 0.76, green: 0.97, blue: 0.36)
    static let cyan = Color(red: 0.12, green: 0.80, blue: 0.95)
    static let orange = Color(red: 1.00, green: 0.53, blue: 0.16)
    static let pink = Color(red: 0.95, green: 0.28, blue: 0.60)
    static let card = Color.white.opacity(0.08)
    static let stroke = Color.white.opacity(0.10)
}

struct AppGradientBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.05, blue: 0.10),
                    Color(red: 0.07, green: 0.10, blue: 0.19),
                    Color(red: 0.02, green: 0.03, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    VitalityTheme.cyan.opacity(0.28),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 280
            )
            .offset(x: 90, y: -80)

            RadialGradient(
                colors: [
                    VitalityTheme.pink.opacity(0.20),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 260
            )
            .offset(x: -80, y: 120)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 999)
                .fill(VitalityTheme.accent.opacity(0.06))
                .frame(width: 220, height: 220)
                .blur(radius: 30)
                .offset(x: -90, y: -70)
        }
        .ignoresSafeArea()
    }
}

struct FrostCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(VitalityTheme.stroke, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

struct RarityBadge: View {
    let rarity: RarityTier

    var body: some View {
        Text(rarity.rawValue)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(rarity.color.gradient, in: Capsule())
    }
}

struct ToastOverlay: View {
    let message: String?

    var body: some View {
        VStack {
            Spacer()
            if let message {
                Text(message)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35), value: message)
    }
}

private enum BlindboxBundleAssetResolver {
    static func coverImage(title: String, imageSource: String?) -> UIImage? {
        image(named: coverAssetName(title: title, imageSource: imageSource))
    }

    static func cardImage(title: String, imageSource: String?) -> UIImage? {
        image(named: cardAssetName(title: title, imageSource: imageSource))
    }

    private static func image(named name: String?) -> UIImage? {
        guard
            let name,
            let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "BlindboxAssets")
        else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    private static func coverAssetName(title: String, imageSource: String?) -> String? {
        if let mapped = assetName(from: imageSource), mapped.hasSuffix("Cover") || mapped.hasSuffix("Back") {
            return mapped
        }

        switch normalizedTitle(title) {
        case "flutter series 01":
            return "Series1Cover"
        case "flutter series 02":
            return "Series2Cover"
        default:
            return nil
        }
    }

    private static func cardAssetName(title: String, imageSource: String?) -> String? {
        if let mapped = assetName(from: imageSource) {
            return mapped
        }

        let normalized = normalizedTitle(title)
        if normalized.hasPrefix("flutter series 01 #"),
           let suffix = normalized.split(separator: "#").last {
            return "Series1_" + fileNameForCardIndex(String(suffix), series: 1)
        }

        if normalized.hasPrefix("flutter series 02 #"),
           let suffix = normalized.split(separator: "#").last {
            return "Series2_" + fileNameForCardIndex(String(suffix), series: 2)
        }

        return nil
    }

    private static func fileNameForCardIndex(_ indexText: String, series: Int) -> String {
        let series1 = [
            "3c06cc41d11af8ed86888f1b624301d3",
            "4a5f2d49b7395f9cb06e70abf83be772",
            "7fc0d5faf1c0344750b36ae01c86d6ef",
            "9d91b21ee08b591a98878ba41e120a0c",
            "a176385bbc8f4a82d8c5deed0f2b061d",
            "bd70df3c780916e18984409dcd339714",
            "ccff09c6df094adc5f44338f20252ac9",
            "d2aed75787e5397cd4d62ad1aa855164",
            "da2f645430ba9403e498d8c85a16e169",
            "df2322d1a4a878bfeea11f9e9d841be6"
        ]

        let series2 = [
            "1ad25512582beaa25f9d4434fc28a7d8",
            "2199211a9988643744dbb43efba55772",
            "2d136ca7efc0a76989d7ed8b0d451031",
            "3a4b7ea4b416980c697f784bd20b3fe6",
            "4d38e7da2bae15dce359f2325797a420",
            "65c2849fae6d951101a2f03534651d95",
            "771b47bdbc8ffd6bf6154c3ca25196d2",
            "9bedc9c1b3549fb1c3b00af335cc3832",
            "b32afa31845b58d210c0ba5d5f7984d4",
            "db11ab33364f8a9e5d442cb8ca31d97d"
        ]

        let cardIndex = max((Int(indexText) ?? 1) - 1, 0)
        if series == 1 {
            return series1[min(cardIndex, series1.count - 1)]
        }
        return series2[min(cardIndex, series2.count - 1)]
    }

    private static func assetName(from imageSource: String?) -> String? {
        guard
            let imageSource,
            let url = URL(string: imageSource),
            url.isFileURL
        else {
            return nil
        }

        let path = url.path.lowercased()
        let fileName = url.deletingPathExtension().lastPathComponent
        let originalFileName = url.lastPathComponent

        let prefix: String?
        if path.contains("/series1/") {
            prefix = "Series1"
        } else if path.contains("/series2/") {
            prefix = "Series2"
        } else {
            prefix = nil
        }

        guard let prefix else { return nil }

        if originalFileName == "盲盒系列.PNG" {
            return prefix + "Cover"
        }

        if originalFileName == "背面.PNG" {
            return prefix + "Back"
        }

        return "\(prefix)_\(fileName)"
    }

    private static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

func normalizedBlindBoxURL(_ source: String?) -> URL? {
    guard let source, !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return nil
    }

    if source.hasPrefix("http://") || source.hasPrefix("https://") {
        return URL(string: source)
    }

    if source.hasPrefix("/") {
        return URL(fileURLWithPath: source)
    }

    return nil
}

struct BlindBoxArtworkView: View {
    let title: String
    let subtitle: String?
    let imageURL: String?
    let accent: Color

    var body: some View {
        Group {
            if let localImage = BlindboxBundleAssetResolver.coverImage(title: title, imageSource: imageURL) {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageURL = normalizedBlindBoxURL(imageURL),
               imageURL.pathExtension.lowercased() != "svg" {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .overlay(
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.16), Color.black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipped()
    }

    private var placeholder: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [accent.opacity(0.95), VitalityTheme.cyan.opacity(0.72), Color(red: 0.05, green: 0.07, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.20), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 180
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.74))
                        .lineLimit(2)
                }
            }
            .padding(18)
        }
    }
}

struct BlindBoxCardArtworkView: View {
    let title: String
    let rarity: RarityTier
    let imageURL: String?

    var body: some View {
        Group {
            if let localImage = BlindboxBundleAssetResolver.cardImage(title: title, imageSource: imageURL) {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageURL = normalizedBlindBoxURL(imageURL),
               imageURL.pathExtension.lowercased() != "svg" {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .overlay(
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.68)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [rarity.color.opacity(0.90), VitalityTheme.cyan.opacity(0.70), Color.black.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 10) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                Text(rarity.rawValue)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
            }
        }
    }
}

struct CollectibleArtworkView: View {
    let collectible: Collectible

    var body: some View {
        BlindBoxCardArtworkView(
            title: collectible.name,
            rarity: collectible.rarity,
            imageURL: collectible.imageURL
        )
    }
}
