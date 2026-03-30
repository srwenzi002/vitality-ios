import SwiftUI
import UIKit
import SceneKit
import ObjectiveC

struct LegacyBlindboxSingleDrawPayload: Identifiable {
    let id = UUID()
    let box: BlindBox
    let reward: Collectible
    let remainingKeys: Int
}

struct LegacyBlindboxBatchDrawPayload: Identifiable {
    let id = UUID()
    let box: BlindBox
    let rewards: [Collectible]
    let remainingKeys: Int
}

struct LegacyBlindboxSingleDrawCover: UIViewControllerRepresentable {
    let payload: LegacyBlindboxSingleDrawPayload
    let onFinished: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let host = UIViewController()
        host.view.backgroundColor = .clear

        let controller = LegacyBlindboxSingleDrawController(
            series: LegacyBlindboxSeriesData(from: payload.box),
            resultCard: LegacyBlindboxCardDisplay(from: payload.reward),
            remainingKeysText: "剩余钥匙 \(payload.remainingKeys)"
        )
        controller.onFinished = onFinished

        host.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: host.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: host.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: host.view.bottomAnchor),
        ])
        controller.didMove(toParent: host)
        return host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct LegacyBlindboxBatchDrawCover: UIViewControllerRepresentable {
    let payload: LegacyBlindboxBatchDrawPayload
    let onFinished: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let host = UIViewController()
        host.view.backgroundColor = .clear

        let controller = LegacyBlindboxBatchDrawController(
            series: LegacyBlindboxSeriesData(from: payload.box),
            resultCards: payload.rewards.map { LegacyBlindboxCardDisplay(from: $0) },
            onFinished: onFinished
        )

        host.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: host.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: host.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: host.view.bottomAnchor),
        ])
        controller.didMove(toParent: host)
        return host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private struct LegacyBlindboxCardDisplay {
    let title: String
    let rarity: String
    let localImageName: String?
    let remoteImageURL: URL?
    let assetNumber: Int?

    init(from reward: Collectible) {
        self.title = reward.name
        self.rarity = reward.rarity.rawValue
        self.localImageName = legacyCardAssetName(title: reward.name, imageSource: reward.imageURL)
        self.remoteImageURL = legacyNormalizedImageURL(from: reward.imageURL)
        self.assetNumber = reward.assetNumber
    }
}

private struct LegacyBlindboxSeriesData {
    let title: String
    let subtitle: String
    let coverImageName: String?
    let coverImageURL: URL?
    let backImageName: String?
    let accent: UIColor

    init(from box: BlindBox) {
        self.title = box.title
        self.subtitle = box.subtitle
        self.coverImageName = legacyCoverAssetName(title: box.title, imageSource: box.imageURL)
        self.coverImageURL = legacyNormalizedImageURL(from: box.imageURL)
        self.backImageName = legacyBackAssetName(title: box.title, imageSource: box.imageURL)
        switch box.category {
        case .daily:
            self.accent = UIColor(hex: 0xFF6A00)
        case .urban:
            self.accent = UIColor(hex: 0x37D7FF)
        case .legend:
            self.accent = UIColor(hex: 0xD929FA)
        }
    }
}

private final class LegacyCompactRevealCardView: UIControl {
    private let glowView = UIView()
    private let cardView = UIView()
    private let imageView = UIImageView()
    private let shineView = UIView()

    private(set) var cardItem: LegacyBlindboxCardDisplay?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var displayedImage: UIImage? { imageView.image }

    func applyBack(localBackImageName: String?, accent: UIColor) {
        cardItem = nil
        glowView.backgroundColor = accent.withAlphaComponent(0.10)
        glowView.alpha = 1
        glowView.layer.shadowColor = accent.cgColor
        glowView.layer.shadowOpacity = 0.18
        glowView.layer.shadowRadius = 18
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        shineView.alpha = 0.32
        imageView.setBlindboxImage(
            localName: localBackImageName,
            remoteURL: nil,
            placeholderTitle: "CARD BACK",
            accent: UIColor(hex: 0x8B80FF)
        )
    }

    func reveal(cardItem: LegacyBlindboxCardDisplay, animated: Bool = true) {
        self.cardItem = cardItem
        let accent = legacyRarityAccentColor(for: cardItem.rarity)
        glowView.backgroundColor = accent.withAlphaComponent(cardItem.rarity == "N" ? 0.10 : 0.16)
        glowView.layer.shadowColor = accent.cgColor
        glowView.layer.shadowOpacity = cardItem.rarity == "N" ? 0.16 : 0.26
        glowView.layer.shadowRadius = cardItem.rarity == "N" ? 18 : 24
        cardView.layer.borderColor = accent.withAlphaComponent(cardItem.rarity == "N" ? 0.16 : 0.30).cgColor
        imageView.setBlindboxImage(
            localName: cardItem.localImageName,
            remoteURL: cardItem.remoteImageURL,
            placeholderTitle: cardItem.title,
            accent: accent
        )
        if animated {
            UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseOut]) {
                self.shineView.alpha = 0.18
            } completion: { _ in
                UIView.animate(withDuration: 0.24, delay: 0.0, options: [.curveEaseOut]) {
                    self.shineView.alpha = 0
                }
            }
        } else {
            shineView.alpha = 0
        }
    }

    func setDimmed(_ dimmed: Bool, selected: Bool, animated: Bool) {
        let changes = {
            self.alpha = dimmed ? 0.24 : 1.0
            self.glowView.alpha = selected ? 0.92 : (dimmed ? 0.18 : 1.0)
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0.0, options: [.curveEaseOut], animations: changes)
        } else {
            changes()
        }
    }

    func resetHighlight(animated: Bool) {
        let changes = {
            self.alpha = 1
            self.glowView.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0.0, options: [.curveEaseOut], animations: changes)
        } else {
            changes()
        }
    }

    func makeSnapshotView() -> UIView {
        let snapshot = UIView(frame: bounds)
        snapshot.backgroundColor = .clear

        let glow = UIView(frame: bounds.insetBy(dx: 8, dy: 12))
        glow.backgroundColor = glowView.backgroundColor
        glow.layer.cornerRadius = 16
        glow.layer.shadowColor = glowView.layer.shadowColor
        glow.layer.shadowOpacity = glowView.layer.shadowOpacity
        glow.layer.shadowRadius = glowView.layer.shadowRadius
        glow.layer.shadowOffset = .zero
        snapshot.addSubview(glow)

        let card = UIView(frame: bounds)
        card.backgroundColor = cardView.backgroundColor
        card.layer.cornerRadius = cardView.layer.cornerRadius
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = cardView.layer.borderWidth
        card.layer.borderColor = cardView.layer.borderColor
        card.clipsToBounds = true
        snapshot.addSubview(card)

        let image = UIImageView(frame: card.bounds)
        image.contentMode = .scaleAspectFill
        image.image = imageView.image
        image.clipsToBounds = true
        card.addSubview(image)

        return snapshot
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.isUserInteractionEnabled = false
        glowView.layer.cornerRadius = 18
        addSubview(glowView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.isUserInteractionEnabled = false
        cardView.backgroundColor = UIColor(hex: 0x101723, alpha: 0.92)
        cardView.layer.cornerRadius = 16
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderWidth = 0.7
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        cardView.clipsToBounds = true
        addSubview(cardView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        cardView.addSubview(imageView)

        shineView.translatesAutoresizingMaskIntoConstraints = false
        shineView.isUserInteractionEnabled = false
        shineView.alpha = 0
        let shine = CAGradientLayer()
        shine.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.72).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        shine.locations = [0.0, 0.52, 1.0]
        shine.startPoint = CGPoint(x: 0.0, y: 0.5)
        shine.endPoint = CGPoint(x: 1.0, y: 0.5)
        shine.frame = CGRect(x: -80, y: 0, width: 80, height: 150)
        shine.transform = CATransform3DMakeRotation(-0.32, 0, 0, 1)
        shineView.layer.addSublayer(shine)
        cardView.addSubview(shineView)

        NSLayoutConstraint.activate([
            glowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            glowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            glowView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            glowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            shineView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            shineView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            shineView.topAnchor.constraint(equalTo: cardView.topAnchor),
            shineView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])
    }
}

private final class LegacyBlindboxBatchDrawController: UIViewController {
    private let series: LegacyBlindboxSeriesData
    private let resultCards: [LegacyBlindboxCardDisplay]
    private let onFinished: () -> Void

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let dimmingView = UIView()
    private let flashView = UIView()
    private let portalGlowView = UIView()
    private let portalCoreView = UIView()
    private let floorGlowView = UIView()
    private let revealSlitView = UIView()
    private let compactStageView = UIView()
    private let compactGridStack = UIStackView()
    private let compactPreviewDismissView = UIControl()
    private let closeButton = UIButton(type: .system)
    private let sceneRewardCardView = LegacySceneKitRewardCardView(frame: .zero)
    private let ringLayer = CAShapeLayer()
    private let secondaryRingLayer = CAShapeLayer()
    private let burstEmitter = CAEmitterLayer()
    private let streakEmitter = CAEmitterLayer()
    private let dustEmitter = CAEmitterLayer()

    private var compactBackCardViews: [LegacyCompactRevealCardView] = []
    private var compactBackCardRestingTransforms: [CGAffineTransform] = []
    private var compactPreviewIndex: Int?
    private var hasPlayed = false
    private var isCompactResultEnabled = false

    init(series: LegacyBlindboxSeriesData, resultCards: [LegacyBlindboxCardDisplay], onFinished: @escaping () -> Void) {
        self.series = series
        self.resultCards = Array(resultCards.prefix(10))
        self.onFinished = onFinished
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasPlayed else { return }
        hasPlayed = true
        playCompactRevealAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        burstEmitter.frame = view.bounds
        streakEmitter.frame = view.bounds
        dustEmitter.frame = view.bounds
        ringLayer.path = UIBezierPath(roundedRect: compactStageView.frame.insetBy(dx: -18, dy: -18), cornerRadius: 36).cgPath
        secondaryRingLayer.path = UIBezierPath(roundedRect: compactStageView.frame.insetBy(dx: -8, dy: -8), cornerRadius: 26).cgPath
        refreshAtmosphereLayers()
        refreshRevealSlitLayers()
    }

    private func setupLayout() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        dimmingView.alpha = 0
        view.addSubview(dimmingView)

        flashView.translatesAutoresizingMaskIntoConstraints = false
        flashView.backgroundColor = .white
        flashView.alpha = 0
        view.addSubview(flashView)

        portalGlowView.translatesAutoresizingMaskIntoConstraints = false
        portalGlowView.alpha = 0
        portalGlowView.layer.shadowOpacity = 0.14
        portalGlowView.layer.shadowRadius = 58
        portalGlowView.layer.shadowOffset = .zero
        view.addSubview(portalGlowView)

        portalCoreView.translatesAutoresizingMaskIntoConstraints = false
        portalCoreView.alpha = 0
        portalCoreView.layer.shadowOpacity = 0.12
        portalCoreView.layer.shadowRadius = 36
        portalCoreView.layer.shadowOffset = .zero
        view.addSubview(portalCoreView)

        floorGlowView.translatesAutoresizingMaskIntoConstraints = false
        floorGlowView.alpha = 0
        floorGlowView.layer.shadowOpacity = 0.08
        floorGlowView.layer.shadowRadius = 28
        floorGlowView.layer.shadowOffset = .zero
        floorGlowView.transform = CGAffineTransform(scaleX: 1.02, y: 0.78)
        view.addSubview(floorGlowView)

        revealSlitView.translatesAutoresizingMaskIntoConstraints = false
        revealSlitView.alpha = 0
        revealSlitView.layer.cornerRadius = 18
        revealSlitView.layer.cornerCurve = .continuous
        revealSlitView.layer.shadowOpacity = 0.22
        revealSlitView.layer.shadowRadius = 28
        revealSlitView.layer.shadowOffset = .zero
        view.addSubview(revealSlitView)

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 0.85
        ringLayer.lineCap = .round
        ringLayer.opacity = 0
        view.layer.addSublayer(ringLayer)

        secondaryRingLayer.fillColor = UIColor.clear.cgColor
        secondaryRingLayer.strokeColor = UIColor.clear.cgColor
        secondaryRingLayer.lineWidth = 1.35
        secondaryRingLayer.lineCap = .round
        secondaryRingLayer.opacity = 0
        view.layer.addSublayer(secondaryRingLayer)

        compactStageView.translatesAutoresizingMaskIntoConstraints = false
        compactStageView.alpha = 0
        compactStageView.isHidden = true
        view.addSubview(compactStageView)

        compactGridStack.translatesAutoresizingMaskIntoConstraints = false
        compactGridStack.axis = .vertical
        compactGridStack.spacing = 16
        compactGridStack.distribution = .fillEqually
        compactStageView.addSubview(compactGridStack)
        configureCompactStageCards()

        compactPreviewDismissView.translatesAutoresizingMaskIntoConstraints = false
        compactPreviewDismissView.backgroundColor = UIColor.black.withAlphaComponent(0.001)
        compactPreviewDismissView.alpha = 0
        compactPreviewDismissView.isHidden = true
        compactPreviewDismissView.addTarget(self, action: #selector(handleCompactPreviewDismiss), for: .touchUpInside)
        view.addSubview(compactPreviewDismissView)

        sceneRewardCardView.translatesAutoresizingMaskIntoConstraints = false
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isHidden = true
        view.addSubview(sceneRewardCardView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        closeButton.layer.cornerRadius = 22
        closeButton.layer.cornerCurve = .continuous
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        closeButton.alpha = 0
        view.addSubview(closeButton)

        burstEmitter.emitterShape = .point
        burstEmitter.emitterMode = .points
        burstEmitter.renderMode = .additive
        burstEmitter.birthRate = 0
        burstEmitter.emitterCells = [makeBurstSparkCell(), makeShardCell()]
        view.layer.addSublayer(burstEmitter)

        streakEmitter.emitterShape = .point
        streakEmitter.emitterMode = .points
        streakEmitter.renderMode = .additive
        streakEmitter.birthRate = 0
        streakEmitter.emitterCells = [makeStreakCell()]
        view.layer.addSublayer(streakEmitter)

        dustEmitter.emitterShape = .point
        dustEmitter.emitterMode = .points
        dustEmitter.renderMode = .additive
        dustEmitter.birthRate = 0
        dustEmitter.emitterCells = [makeDustCell()]
        view.layer.addSublayer(dustEmitter)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            flashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flashView.topAnchor.constraint(equalTo: view.topAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            portalGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portalGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -18),
            portalGlowView.widthAnchor.constraint(equalToConstant: 356),
            portalGlowView.heightAnchor.constraint(equalToConstant: 356),

            portalCoreView.centerXAnchor.constraint(equalTo: portalGlowView.centerXAnchor),
            portalCoreView.centerYAnchor.constraint(equalTo: portalGlowView.centerYAnchor),
            portalCoreView.widthAnchor.constraint(equalToConstant: 246),
            portalCoreView.heightAnchor.constraint(equalToConstant: 274),

            floorGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floorGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
            floorGlowView.widthAnchor.constraint(equalToConstant: 320),
            floorGlowView.heightAnchor.constraint(equalToConstant: 110),

            compactStageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            compactStageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -6),
            compactStageView.widthAnchor.constraint(equalToConstant: 344),
            compactStageView.heightAnchor.constraint(equalToConstant: 324),

            compactGridStack.leadingAnchor.constraint(equalTo: compactStageView.leadingAnchor, constant: 8),
            compactGridStack.trailingAnchor.constraint(equalTo: compactStageView.trailingAnchor, constant: -8),
            compactGridStack.centerYAnchor.constraint(equalTo: compactStageView.centerYAnchor),
            compactGridStack.heightAnchor.constraint(equalToConstant: 234),

            revealSlitView.centerXAnchor.constraint(equalTo: compactStageView.centerXAnchor),
            revealSlitView.centerYAnchor.constraint(equalTo: compactStageView.centerYAnchor),
            revealSlitView.widthAnchor.constraint(equalToConstant: 58),
            revealSlitView.heightAnchor.constraint(equalToConstant: 286),

            compactPreviewDismissView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            compactPreviewDismissView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            compactPreviewDismissView.topAnchor.constraint(equalTo: view.topAnchor),
            compactPreviewDismissView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sceneRewardCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sceneRewardCardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sceneRewardCardView.widthAnchor.constraint(equalToConstant: 240),
            sceneRewardCardView.heightAnchor.constraint(equalToConstant: 340),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func configureCompactStageCards() {
        guard compactBackCardViews.isEmpty else { return }
        for rowIndex in 0..<2 {
            let row = UIStackView()
            row.translatesAutoresizingMaskIntoConstraints = false
            row.axis = .horizontal
            row.spacing = 12
            row.distribution = .fillEqually
            compactGridStack.addArrangedSubview(row)

            for columnIndex in 0..<5 {
                let card = LegacyCompactRevealCardView()
                card.applyBack(localBackImageName: series.backImageName, accent: series.accent)
                card.addTarget(self, action: #selector(handleCompactCardTap(_:)), for: .touchUpInside)
                row.addArrangedSubview(card)
                let resting = compactRestingTransform(row: rowIndex, column: columnIndex)
                card.transform = resting
                compactBackCardViews.append(card)
                compactBackCardRestingTransforms.append(resting)
            }
        }
    }

    private func playCompactRevealAnimation() {
        prepareCompactBackCardsForAnimation()
        compactStageView.alpha = 0
        compactStageView.isHidden = false
        portalGlowView.alpha = 0
        portalCoreView.alpha = 0
        floorGlowView.alpha = 0
        compactStageView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92).translatedBy(x: 0, y: 20)
        portalCoreView.transform = CGAffineTransform(scaleX: 0.9, y: 0.78)
        dimmingView.alpha = 0
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isHidden = true
        closeButton.alpha = 0

        UIView.animate(withDuration: 0.24, delay: 0.0, options: [.curveEaseOut]) {
            self.dimmingView.alpha = 1
            self.portalGlowView.alpha = 0.48
            self.portalCoreView.alpha = 0.36
            self.portalCoreView.transform = .identity
            self.floorGlowView.alpha = 0.22
            self.compactStageView.alpha = 1
            self.compactStageView.transform = .identity
        }

        for (index, card) in compactBackCardViews.enumerated() {
            UIView.animate(withDuration: 0.34, delay: 0.08 + (Double(index) * 0.024), usingSpringWithDamping: 0.78, initialSpringVelocity: 0.18, options: [.curveEaseOut]) {
                card.alpha = 1
                card.transform = self.compactBackCardRestingTransforms[index]
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
            self.startCompactIdleMotion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.92) {
            self.playCompactLockInPhase()
        }
    }

    private func prepareCompactBackCardsForAnimation() {
        isCompactResultEnabled = false
        compactPreviewIndex = nil
        compactPreviewDismissView.alpha = 0
        compactPreviewDismissView.isHidden = true
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isHidden = true
        sceneRewardCardView.isUserInteractionEnabled = false
        compactStageView.isHidden = false
        compactBackCardViews.enumerated().forEach { index, card in
            card.applyBack(localBackImageName: series.backImageName, accent: series.accent)
            card.isUserInteractionEnabled = false
            card.resetHighlight(animated: false)
            card.layer.removeAllAnimations()
            card.alpha = 0
            let row = index / 5
            let column = index % 5
            let xOffset = CGFloat(column - 2) * 12
            card.transform = CGAffineTransform(translationX: xOffset, y: 34 + abs(xOffset) * 0.2)
                .rotated(by: compactRestingAngle(row: row, column: column) * 1.2)
                .scaledBy(x: 0.76, y: 0.76)
        }
    }

    private func startCompactIdleMotion() {
        UIView.animateKeyframes(withDuration: 1.6, delay: 0.0, options: [.autoreverse, .repeat, .calculationModeLinear]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                self.compactStageView.transform = CGAffineTransform(translationX: 0, y: -4)
            }
        }
        for (index, card) in compactBackCardViews.enumerated() {
            let drift = CABasicAnimation(keyPath: "transform.translation.y")
            drift.fromValue = 0
            drift.toValue = index % 2 == 0 ? -4 : 4
            drift.duration = 1.2 + (Double(index % 5) * 0.08)
            drift.autoreverses = true
            drift.repeatCount = .infinity
            drift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            card.layer.add(drift, forKey: "compactIdleDrift")
        }
    }

    private func stopCompactIdleMotion() {
        compactStageView.layer.removeAllAnimations()
        compactBackCardViews.forEach { $0.layer.removeAnimation(forKey: "compactIdleDrift") }
        UIView.animate(withDuration: 0.12) {
            self.compactStageView.transform = .identity
        }
    }

    private func playCompactLockInPhase() {
        stopCompactIdleMotion()
        playShockwave()
        playCompactChargePulse()

        UIView.animateKeyframes(withDuration: 0.42, delay: 0.0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.44) {
                self.compactStageView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03).translatedBy(x: 0, y: -4)
                self.portalGlowView.transform = CGAffineTransform(scaleX: 1.08, y: 1.06)
                self.portalCoreView.transform = CGAffineTransform(scaleX: 1.14, y: 1.04)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.44, relativeDuration: 0.34) {
                self.compactStageView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06).translatedBy(x: 0, y: -8)
                self.portalGlowView.alpha = 0.66
                self.portalCoreView.alpha = 0.56
            }
            UIView.addKeyframe(withRelativeStartTime: 0.78, relativeDuration: 0.22) {
                self.compactStageView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            self.playCompactFlashReveal()
        }
    }

    private func playCompactChargePulse() {
        for (index, card) in compactBackCardViews.enumerated() {
            let delay = Double(index) * 0.016
            UIView.animate(withDuration: 0.16, delay: delay, options: [.curveEaseOut]) {
                card.transform = self.compactBackCardRestingTransforms[index].scaledBy(x: 1.04, y: 1.04)
            } completion: { _ in
                UIView.animate(withDuration: 0.18, delay: 0.0, options: [.curveEaseInOut]) {
                    card.transform = self.compactBackCardRestingTransforms[index]
                }
            }
        }
    }

    private func playCompactFlashReveal() {
        let rarity = dominantResultRarity
        let rarityColor = legacyRarityAccentColor(for: rarity)
        playShockwave(accentColor: rarityColor)
        playRevealSlit()
        transitionAtmosphereToRarity(rarityColor)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.playBurstParticles(rarity: rarity)
        }

        flashView.backgroundColor = legacyRarityFlashColor(for: rarity)
        let flashPeak: CGFloat = rarity == "SSR" ? 0.90 : (rarity == "SR" ? 0.84 : 0.78)
        UIView.animate(withDuration: 0.06, animations: {
            self.flashView.alpha = flashPeak
        }) { _ in
            UIView.animate(withDuration: 0.20, delay: 0.0, options: [.curveEaseOut]) {
                self.flashView.alpha = 0
            }
        }

        UIView.animate(withDuration: 0.24, delay: 0.02, options: [.curveEaseInOut]) {
            self.portalGlowView.transform = CGAffineTransform(scaleX: 1.1, y: 1.04)
            self.portalGlowView.alpha = 0.42
            self.portalCoreView.transform = CGAffineTransform(scaleX: 1.34, y: 1.16)
            self.portalCoreView.alpha = 0.78
            self.floorGlowView.transform = CGAffineTransform(scaleX: 1.12, y: 0.84)
            self.compactStageView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }

        let revealBaseDelay = 0.10
        for (index, item) in resultCards.enumerated() {
            let revealDelay = revealBaseDelay + (Double(index) * 0.075)
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                let card = self.compactBackCardViews[index]
                let resting = self.compactBackCardRestingTransforms[index]
                card.reveal(cardItem: item, animated: true)
                UIView.animate(withDuration: 0.14, delay: 0.0, options: [.curveEaseOut]) {
                    card.transform = resting.scaledBy(x: 1.08, y: 1.08)
                } completion: { _ in
                    UIView.animate(withDuration: 0.34, delay: 0.0, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.22, options: [.curveEaseOut]) {
                        card.transform = resting
                    }
                }
            }
        }

        let finalizeDelay = revealBaseDelay + (Double(max(resultCards.count - 1, 0)) * 0.075) + 0.34
        DispatchQueue.main.asyncAfter(deadline: .now() + finalizeDelay) {
            self.enterCompactResultMode()
        }
    }

    private func enterCompactResultMode() {
        isCompactResultEnabled = true
        UIView.animate(withDuration: 0.28, delay: 0.0, options: [.curveEaseOut]) {
            self.compactStageView.alpha = 1
            self.compactStageView.transform = .identity
            self.portalGlowView.alpha = 0.18
            self.portalCoreView.alpha = 0.08
            self.floorGlowView.alpha = 0.08
            self.revealSlitView.alpha = 0
            self.closeButton.alpha = 1
        }
        compactBackCardViews.forEach {
            $0.isUserInteractionEnabled = true
            $0.resetHighlight(animated: true)
        }
    }

    @objc private func handleCompactCardTap(_ sender: LegacyCompactRevealCardView) {
        guard
            isCompactResultEnabled,
            let index = compactBackCardViews.firstIndex(where: { $0 === sender }),
            let image = sender.displayedImage
        else { return }

        if compactPreviewIndex == index {
            dismissCompactPreview()
            return
        }

        compactPreviewIndex = index
        compactPreviewDismissView.isHidden = false
        compactPreviewDismissView.alpha = 0
        sceneRewardCardView.configure(frontImage: image, backImage: legacyBlindboxImage(localName: series.backImageName), accent: legacyRarityAccentColor(for: resultCards[index].rarity))
        sceneRewardCardView.isHidden = false
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isUserInteractionEnabled = false
        view.layoutIfNeeded()

        let snapshot = sender.makeSnapshotView()
        let sourceFrame = sender.convert(sender.bounds, to: view)
        let targetFrame = sceneRewardCardView.projectedCardFrame(in: view) ?? sourceFrame
        snapshot.frame = sourceFrame
        snapshot.layer.cornerRadius = 16
        snapshot.layer.cornerCurve = .continuous
        snapshot.clipsToBounds = true
        view.addSubview(snapshot)

        for (cardIndex, cardView) in compactBackCardViews.enumerated() {
            cardView.setDimmed(cardIndex != index, selected: cardIndex == index, animated: true)
        }

        UIView.animate(withDuration: 0.32, delay: 0.0, options: [.curveEaseInOut]) {
            self.compactPreviewDismissView.alpha = 1
            self.compactStageView.alpha = 0.42
            self.sceneRewardCardView.alpha = 1
            snapshot.frame = targetFrame
            snapshot.alpha = 0
            self.portalGlowView.alpha = 0.12
            self.portalCoreView.alpha = 0.04
        } completion: { _ in
            snapshot.removeFromSuperview()
            sender.alpha = 0
            self.sceneRewardCardView.isUserInteractionEnabled = true
        }
    }

    @objc private func handleCompactPreviewDismiss() {
        dismissCompactPreview()
    }

    private func dismissCompactPreview() {
        guard let index = compactPreviewIndex else { return }
        let cardView = compactBackCardViews[index]
        compactPreviewIndex = nil
        sceneRewardCardView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.24, delay: 0.0, options: [.curveEaseInOut]) {
            self.compactPreviewDismissView.alpha = 0
            self.compactStageView.alpha = 1
            self.sceneRewardCardView.alpha = 0
            self.portalGlowView.alpha = 0.18
            self.portalCoreView.alpha = 0.08
        } completion: { _ in
            self.compactPreviewDismissView.isHidden = true
            self.sceneRewardCardView.isHidden = true
            self.sceneRewardCardView.isUserInteractionEnabled = false
        }

        compactBackCardViews.enumerated().forEach { cardIndex, card in
            card.alpha = 1
            card.setDimmed(false, selected: false, animated: true)
            card.isUserInteractionEnabled = true
            if cardIndex == index {
                card.alpha = 1
            }
        }
        cardView.alpha = 1
    }

    @objc private func handleClose() {
        onFinished()
    }

    private var dominantResultRarity: String {
        if resultCards.contains(where: { $0.rarity == "SSR" }) { return "SSR" }
        if resultCards.contains(where: { $0.rarity == "SR" }) { return "SR" }
        if resultCards.contains(where: { $0.rarity == "R" }) { return "R" }
        return "N"
    }

    private func compactRestingAngle(row: Int, column: Int) -> CGFloat {
        let top: [CGFloat] = [-0.18, -0.10, -0.03, 0.07, 0.16]
        let bottom: [CGFloat] = [-0.14, -0.07, 0.02, 0.10, 0.18]
        return row == 0 ? top[column] : bottom[column]
    }

    private func compactRestingTransform(row: Int, column: Int) -> CGAffineTransform {
        let angle = compactRestingAngle(row: row, column: column)
        let topOffsets: [CGPoint] = [
            CGPoint(x: -10, y: -4), CGPoint(x: -6, y: -10), CGPoint(x: 0, y: -14), CGPoint(x: 6, y: -10), CGPoint(x: 10, y: -4),
        ]
        let bottomOffsets: [CGPoint] = [
            CGPoint(x: -8, y: 10), CGPoint(x: -4, y: 16), CGPoint(x: 0, y: 20), CGPoint(x: 4, y: 16), CGPoint(x: 8, y: 10),
        ]
        let offset = row == 0 ? topOffsets[column] : bottomOffsets[column]
        return CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: angle)
    }

    private func refreshAtmosphereLayers() {
        let ambient = series.accent
        portalGlowView.backgroundColor = .clear
        portalGlowView.layer.shadowColor = ambient.withAlphaComponent(0.16).cgColor
        portalCoreView.backgroundColor = .clear
        portalCoreView.layer.shadowColor = ambient.withAlphaComponent(0.24).cgColor
        floorGlowView.backgroundColor = .clear
        floorGlowView.layer.shadowColor = ambient.withAlphaComponent(0.14).cgColor

        configureGradientLayer(in: portalGlowView, name: "legacyBatchPortalPrimary", type: .radial, colors: [ambient.withAlphaComponent(0.18), ambient.withAlphaComponent(0.08), .clear], locations: [0.0, 0.54, 1.0], startPoint: CGPoint(x: 0.46, y: 0.4), endPoint: CGPoint(x: 1.0, y: 1.0), frameInset: UIEdgeInsets(top: 26, left: 30, bottom: 18, right: 24))
        configureGradientLayer(in: portalCoreView, name: "legacyBatchPortalCore", type: .radial, colors: [ambient.withAlphaComponent(0.12), .clear], locations: [0.0, 1.0], startPoint: CGPoint(x: 0.5, y: 0.44), endPoint: CGPoint(x: 1.0, y: 1.0), frameInset: UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18))
        configureGradientLayer(in: floorGlowView, name: "legacyBatchFloorGlow", type: .radial, colors: [ambient.withAlphaComponent(0.12), ambient.withAlphaComponent(0.05), .clear], locations: [0.0, 0.58, 1.0], startPoint: CGPoint(x: 0.5, y: 0.38), endPoint: CGPoint(x: 1.0, y: 1.0), frameInset: UIEdgeInsets(top: 8, left: 18, bottom: 18, right: 18))
    }

    private func refreshRevealSlitLayers() {
        let ambient = series.accent
        revealSlitView.backgroundColor = .clear
        revealSlitView.layer.shadowColor = ambient.withAlphaComponent(0.42).cgColor
        configureGradientLayer(in: revealSlitView, name: "legacyBatchRevealSlit", type: .axial, colors: [.clear, ambient.withAlphaComponent(0.24), UIColor.white.withAlphaComponent(0.92), ambient.withAlphaComponent(0.24), .clear], locations: [0.0, 0.22, 0.5, 0.78, 1.0], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1.0, y: 0.5), frameInset: .zero)
    }

    private func configureGradientLayer(in container: UIView, name: String, type: CAGradientLayerType, colors: [UIColor], locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint, frameInset: UIEdgeInsets) {
        let gradient: CAGradientLayer
        if let existing = container.layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer {
            gradient = existing
        } else {
            gradient = CAGradientLayer()
            gradient.name = name
            container.layer.addSublayer(gradient)
        }
        gradient.type = type
        gradient.colors = colors.map(\.cgColor)
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = CGRect(x: -frameInset.left, y: -frameInset.top, width: container.bounds.width + frameInset.left + frameInset.right, height: container.bounds.height + frameInset.top + frameInset.bottom)
    }

    private func playRevealSlit() {
        revealSlitView.layer.removeAllAnimations()
        revealSlitView.alpha = 0
        revealSlitView.transform = CGAffineTransform(scaleX: 0.14, y: 0.86)
        UIView.animateKeyframes(withDuration: 0.28, delay: 0.0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.24) {
                self.revealSlitView.alpha = 1
                self.revealSlitView.transform = CGAffineTransform(scaleX: 0.42, y: 0.98)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.24, relativeDuration: 0.34) {
                self.revealSlitView.alpha = 0.9
                self.revealSlitView.transform = CGAffineTransform(scaleX: 1.08, y: 1.06)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.58, relativeDuration: 0.42) {
                self.revealSlitView.alpha = 0
                self.revealSlitView.transform = CGAffineTransform(scaleX: 2.4, y: 1.12)
            }
        }
    }

    private func playShockwave(accentColor: UIColor? = nil) {
        let accent = accentColor ?? series.accent
        ringLayer.strokeColor = accent.withAlphaComponent(0.38).cgColor
        ringLayer.opacity = 0.55
        secondaryRingLayer.strokeColor = accent.withAlphaComponent(0.22).cgColor
        secondaryRingLayer.opacity = 0.48

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.88
        scale.toValue = 1.28
        scale.duration = 0.54
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.85
        fade.toValue = 0
        fade.duration = 0.54
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.54
        ringLayer.add(group, forKey: "shockwave")

        let innerScale = CABasicAnimation(keyPath: "transform.scale")
        innerScale.fromValue = 0.76
        innerScale.toValue = 1.08
        innerScale.duration = 0.36
        innerScale.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let innerFade = CABasicAnimation(keyPath: "opacity")
        innerFade.fromValue = 0.68
        innerFade.toValue = 0
        innerFade.duration = 0.36
        innerFade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let innerGroup = CAAnimationGroup()
        innerGroup.animations = [innerScale, innerFade]
        innerGroup.duration = 0.36
        secondaryRingLayer.add(innerGroup, forKey: "secondaryShockwave")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) {
            self.ringLayer.opacity = 0
            self.secondaryRingLayer.opacity = 0
        }
    }

    private func transitionAtmosphereToRarity(_ rarityColor: UIColor) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.34)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        let names = ["legacyBatchPortalPrimary", "legacyBatchPortalCore", "legacyBatchFloorGlow"]
        let alphas: [CGFloat] = [0.30, 0.22, 0.20]
        let views = [portalGlowView, portalCoreView, floorGlowView]
        for (i, view) in views.enumerated() {
            if let g = view.layer.sublayers?.first(where: { $0.name == names[i] }) as? CAGradientLayer {
                var updated = g.colors as? [CGColor] ?? []
                if updated.count >= 2 {
                    updated[0] = rarityColor.withAlphaComponent(alphas[i]).cgColor
                    if updated.count >= 3 { updated[1] = rarityColor.withAlphaComponent(alphas[i] * 0.45).cgColor }
                    g.colors = updated
                }
            }
            view.layer.shadowColor = rarityColor.withAlphaComponent(0.22).cgColor
        }
        CATransaction.commit()
    }

    private func playBurstParticles(rarity: String) {
        let cardFrame = compactStageView.convert(compactStageView.bounds, to: view)
        let origin = CGPoint(x: cardFrame.midX, y: cardFrame.midY - 10)
        let accent = legacyRarityAccentColor(for: rarity)
        let intensity = legacyParticleIntensity(for: rarity)

        burstEmitter.emitterPosition = origin
        burstEmitter.emitterShape = .point
        burstEmitter.emitterSize = .zero
        streakEmitter.emitterPosition = origin
        streakEmitter.emitterShape = .rectangle
        streakEmitter.emitterSize = CGSize(width: cardFrame.width * 0.58, height: cardFrame.height * 0.78)
        dustEmitter.emitterPosition = origin
        dustEmitter.emitterShape = .rectangle
        dustEmitter.emitterSize = CGSize(width: cardFrame.width * 0.68, height: cardFrame.height * 0.92)
        burstEmitter.emitterCells = [makeBurstSparkCell(accent: accent, intensity: intensity), makeShardCell(accent: accent, intensity: intensity)]
        streakEmitter.emitterCells = [makeStreakCell(accent: accent, intensity: intensity)]
        dustEmitter.emitterCells = [makeDustCell(accent: accent, intensity: intensity)]
        burstEmitter.birthRate = 1
        streakEmitter.birthRate = 1
        dustEmitter.birthRate = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { self.burstEmitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { self.streakEmitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) { self.dustEmitter.birthRate = 0 }
    }

    private func makeBurstSparkCell(accent: UIColor = UIColor(hex: 0xE978FF), intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(42 * intensity)
        cell.lifetime = 0.54
        cell.velocity = 176 * intensity
        cell.velocityRange = 58 * intensity
        cell.emissionRange = .pi * 2
        cell.scale = 0.22
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.7
        cell.contents = legacyGlintImage()?.cgImage
        cell.color = UIColor.white.withAlphaComponent(0.9).cgColor
        return cell
    }

    private func makeShardCell(accent: UIColor = UIColor(hex: 0x63F9FF), intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(28 * intensity)
        cell.lifetime = 0.86
        cell.velocity = 74 * intensity
        cell.velocityRange = 30 * intensity
        cell.emissionRange = .pi * 2
        cell.spin = 0.18
        cell.spinRange = 0.26
        cell.scale = 0.14
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.92
        cell.yAcceleration = -16
        cell.contents = legacyMoteImage()?.cgImage
        cell.color = accent.withAlphaComponent(0.34).cgColor
        return cell
    }

    private func makeStreakCell(accent: UIColor = .white, intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(16 * intensity)
        cell.lifetime = 0.24
        cell.velocity = 248 * intensity
        cell.velocityRange = 34 * intensity
        cell.emissionRange = .pi * 2
        cell.spin = 0.28
        cell.scale = 0.18
        cell.scaleRange = 0.04
        cell.alphaSpeed = -3.2
        cell.contents = legacyStreakImage()?.cgImage
        cell.color = accent.withAlphaComponent(0.62).cgColor
        return cell
    }

    private func makeDustCell(accent: UIColor = .white, intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(14 * intensity)
        cell.lifetime = 1.26
        cell.velocity = 18 * intensity
        cell.velocityRange = 12 * intensity
        cell.emissionRange = .pi * 2
        cell.scale = 0.08
        cell.scaleRange = 0.03
        cell.alphaSpeed = -0.42
        cell.yAcceleration = -10
        cell.contents = legacyMoteImage(size: CGSize(width: 28, height: 28))?.cgImage
        cell.color = accent.withAlphaComponent(0.16).cgColor
        return cell
    }
}

private final class LegacyBlindboxSingleDrawController: UIViewController, UIGestureRecognizerDelegate {
    private let series: LegacyBlindboxSeriesData
    private let resultCard: LegacyBlindboxCardDisplay
    private let remainingKeysText: String
    var onFinished: (() -> Void)?

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let dimmingView = UIView()
    private let flashView = UIView()
    private let portalGlowView = UIView()
    private let portalCoreView = UIView()
    private let floorGlowView = UIView()
    private let revealSlitView = UIView()
    private let cardStageView = UIView()
    private let cardInteractionHostView = UIView()
    private let cardFlipContainer = LegacyCardFlipContainerView()
    private let backCardView = UIView()
    private let frontCardView = UIView()
    private let backCardImageView = UIImageView()
    private let backCardSweepView = UIView()
    private let frontCardImageView = UIImageView()
    private let frontCardShineView = UIView()
    private let rarityBadge = UIView()
    private let rarityBadgeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let interactionHintLabel = UILabel()
    private let collectButton = UIButton(type: .custom)
    private let collectButtonBackground = UIView()
    private let sceneRewardCardView = LegacySceneKitRewardCardView(frame: .zero)
    private let ringLayer = CAShapeLayer()
    private let secondaryRingLayer = CAShapeLayer()
    private let burstEmitter = CAEmitterLayer()
    private let streakEmitter = CAEmitterLayer()
    private let dustEmitter = CAEmitterLayer()

    private var hasPlayed = false
    private var interactiveFlipAngle: CGFloat = 0
    private var interactiveTiltX: CGFloat = 0
    private var interactiveTiltY: CGFloat = 0
    private var interactiveOffsetX: CGFloat = 0
    private var interactiveOffsetY: CGFloat = 0
    private var isShowingFrontFace = true
    private var isInteractiveResultEnabled = false

    init(series: LegacyBlindboxSeriesData, resultCard: LegacyBlindboxCardDisplay, remainingKeysText: String) {
        self.series = series
        self.resultCard = resultCard
        self.remainingKeysText = remainingKeysText
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasPlayed else { return }
        hasPlayed = true
        playRevealAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        burstEmitter.frame = view.bounds
        streakEmitter.frame = view.bounds
        dustEmitter.frame = view.bounds
        cardInteractionHostView.layer.sublayerTransform = makePerspectiveSublayerTransform()

        let stageFrame = cardStageView.frame
        ringLayer.path = UIBezierPath(roundedRect: stageFrame.insetBy(dx: -24, dy: -24), cornerRadius: 42).cgPath
        secondaryRingLayer.path = UIBezierPath(roundedRect: stageFrame.insetBy(dx: -12, dy: -12), cornerRadius: 30).cgPath

        refreshAtmosphereLayers()
        refreshRevealSlitLayers()
        collectButtonBackground.updateGradientFrame(named: "legacyOpeningCollectButtonGradient")
    }

    private func setupLayout() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.46)
        dimmingView.alpha = 0
        view.addSubview(dimmingView)

        flashView.translatesAutoresizingMaskIntoConstraints = false
        flashView.backgroundColor = .white
        flashView.alpha = 0
        view.addSubview(flashView)

        portalGlowView.translatesAutoresizingMaskIntoConstraints = false
        portalGlowView.alpha = 0
        portalGlowView.layer.shadowOpacity = 0.14
        portalGlowView.layer.shadowRadius = 58
        portalGlowView.layer.shadowOffset = .zero
        view.addSubview(portalGlowView)

        portalCoreView.translatesAutoresizingMaskIntoConstraints = false
        portalCoreView.alpha = 0
        portalCoreView.layer.shadowOpacity = 0.12
        portalCoreView.layer.shadowRadius = 36
        portalCoreView.layer.shadowOffset = .zero
        view.addSubview(portalCoreView)

        floorGlowView.translatesAutoresizingMaskIntoConstraints = false
        floorGlowView.alpha = 0
        floorGlowView.layer.shadowOpacity = 0.08
        floorGlowView.layer.shadowRadius = 28
        floorGlowView.layer.shadowOffset = .zero
        floorGlowView.transform = CGAffineTransform(scaleX: 1.02, y: 0.78)
        view.addSubview(floorGlowView)

        revealSlitView.translatesAutoresizingMaskIntoConstraints = false
        revealSlitView.alpha = 0
        revealSlitView.isUserInteractionEnabled = false
        revealSlitView.layer.cornerRadius = 18
        revealSlitView.layer.cornerCurve = .continuous
        revealSlitView.layer.shadowOpacity = 0.22
        revealSlitView.layer.shadowRadius = 28
        revealSlitView.layer.shadowOffset = .zero
        view.addSubview(revealSlitView)

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 0.85
        ringLayer.lineCap = .round
        ringLayer.opacity = 0
        view.layer.addSublayer(ringLayer)

        secondaryRingLayer.fillColor = UIColor.clear.cgColor
        secondaryRingLayer.strokeColor = UIColor.clear.cgColor
        secondaryRingLayer.lineWidth = 1.35
        secondaryRingLayer.lineCap = .round
        secondaryRingLayer.opacity = 0
        view.layer.addSublayer(secondaryRingLayer)

        cardStageView.translatesAutoresizingMaskIntoConstraints = false
        cardStageView.alpha = 0
        view.addSubview(cardStageView)

        sceneRewardCardView.translatesAutoresizingMaskIntoConstraints = false
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isHidden = true
        view.addSubview(sceneRewardCardView)

        cardInteractionHostView.translatesAutoresizingMaskIntoConstraints = false
        cardInteractionHostView.isUserInteractionEnabled = true
        cardStageView.addSubview(cardInteractionHostView)

        cardFlipContainer.translatesAutoresizingMaskIntoConstraints = false
        cardFlipContainer.isUserInteractionEnabled = false
        cardInteractionHostView.addSubview(cardFlipContainer)

        configureCardFace(backCardView)
        configureCardFace(frontCardView)
        cardFlipContainer.addSubview(backCardView)
        cardFlipContainer.addSubview(frontCardView)

        backCardImageView.translatesAutoresizingMaskIntoConstraints = false
        backCardImageView.contentMode = .scaleAspectFill
        backCardImageView.setBlindboxImage(
            localName: series.backImageName,
            remoteURL: nil,
            placeholderTitle: "CARD BACK",
            accent: UIColor(hex: 0x8B80FF)
        )
        backCardView.addSubview(backCardImageView)

        backCardSweepView.translatesAutoresizingMaskIntoConstraints = false
        backCardSweepView.alpha = 0
        let backSweepGradient = CAGradientLayer()
        backSweepGradient.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.90).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        backSweepGradient.locations = [0.0, 0.48, 1.0]
        backSweepGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        backSweepGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        backSweepGradient.frame = CGRect(x: -220, y: 0, width: 220, height: 340)
        backSweepGradient.transform = CATransform3DMakeRotation(-0.38, 0, 0, 1)
        backCardSweepView.layer.addSublayer(backSweepGradient)
        backCardView.addSubview(backCardSweepView)

        frontCardImageView.translatesAutoresizingMaskIntoConstraints = false
        frontCardImageView.contentMode = .scaleAspectFill
        frontCardImageView.setBlindboxImage(
            localName: resultCard.localImageName,
            remoteURL: resultCard.remoteImageURL,
            placeholderTitle: resultCard.title,
            accent: rarityAccentColor(for: resultCard.rarity)
        )
        frontCardView.addSubview(frontCardImageView)

        frontCardShineView.translatesAutoresizingMaskIntoConstraints = false
        frontCardShineView.alpha = 0
        let shineGradient = CAGradientLayer()
        shineGradient.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.72).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        shineGradient.locations = [0.0, 0.5, 1.0]
        shineGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        shineGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        shineGradient.frame = CGRect(x: -160, y: 0, width: 160, height: 340)
        shineGradient.transform = CATransform3DMakeRotation(-0.34, 0, 0, 1)
        frontCardShineView.layer.addSublayer(shineGradient)
        frontCardView.addSubview(frontCardShineView)

        rarityBadge.translatesAutoresizingMaskIntoConstraints = false
        rarityBadge.alpha = 0
        rarityBadge.layer.cornerRadius = 12
        rarityBadge.layer.cornerCurve = .continuous
        rarityBadge.backgroundColor = rarityAccentColor(for: resultCard.rarity)
        frontCardView.addSubview(rarityBadge)

        rarityBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        rarityBadgeLabel.textAlignment = .center
        rarityBadgeLabel.font = .systemFont(ofSize: 11, weight: .black)
        rarityBadgeLabel.textColor = .black
        rarityBadgeLabel.text = resultCard.rarity
        rarityBadge.addSubview(rarityBadgeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 30, weight: .black)
        titleLabel.alpha = 0
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        view.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitleLabel.alpha = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        view.addSubview(subtitleLabel)

        interactionHintLabel.translatesAutoresizingMaskIntoConstraints = false
        interactionHintLabel.text = "左右拖动查看角度，轻点翻看背面"
        interactionHintLabel.textColor = UIColor.white.withAlphaComponent(0.58)
        interactionHintLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        interactionHintLabel.textAlignment = .center
        interactionHintLabel.alpha = 0
        view.addSubview(interactionHintLabel)

        collectButton.translatesAutoresizingMaskIntoConstraints = false
        collectButton.layer.cornerRadius = 18
        collectButton.layer.cornerCurve = .continuous
        collectButton.clipsToBounds = true
        collectButton.layer.borderWidth = 0.8
        collectButton.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        collectButton.alpha = 0
        collectButton.addTarget(self, action: #selector(handleCollect), for: .touchUpInside)
        view.addSubview(collectButton)

        collectButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        collectButtonBackground.isUserInteractionEnabled = false
        collectButtonBackground.layer.cornerRadius = 18
        collectButtonBackground.layer.cornerCurve = .continuous
        collectButtonBackground.applyHorizontalGradient(
            colors: [
                UIColor(hex: 0x62E6FF, alpha: 0.95),
                UIColor(hex: 0x8E7BFF, alpha: 0.92),
                UIColor(hex: 0xF05DFF, alpha: 0.95),
            ],
            name: "legacyOpeningCollectButtonGradient"
        )
        collectButton.addSubview(collectButtonBackground)

        let collectLabel = UILabel()
        collectLabel.translatesAutoresizingMaskIntoConstraints = false
        collectLabel.text = "收入收藏"
        collectLabel.textColor = .white
        collectLabel.font = .systemFont(ofSize: 17, weight: .black)
        collectLabel.textAlignment = .center
        collectLabel.isUserInteractionEnabled = false
        collectButton.addSubview(collectLabel)

        burstEmitter.emitterShape = .point
        burstEmitter.emitterMode = .points
        burstEmitter.renderMode = .additive
        burstEmitter.birthRate = 0
        burstEmitter.emitterCells = [makeBurstSparkCell(), makeShardCell()]
        view.layer.addSublayer(burstEmitter)

        streakEmitter.emitterShape = .point
        streakEmitter.emitterMode = .points
        streakEmitter.renderMode = .additive
        streakEmitter.birthRate = 0
        streakEmitter.emitterCells = [makeStreakCell()]
        view.layer.addSublayer(streakEmitter)

        dustEmitter.emitterShape = .point
        dustEmitter.emitterMode = .points
        dustEmitter.renderMode = .additive
        dustEmitter.birthRate = 0
        dustEmitter.emitterCells = [makeDustCell()]
        view.layer.addSublayer(dustEmitter)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            flashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flashView.topAnchor.constraint(equalTo: view.topAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            portalGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portalGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28),
            portalGlowView.widthAnchor.constraint(equalToConstant: 312),
            portalGlowView.heightAnchor.constraint(equalToConstant: 312),

            portalCoreView.centerXAnchor.constraint(equalTo: portalGlowView.centerXAnchor),
            portalCoreView.centerYAnchor.constraint(equalTo: portalGlowView.centerYAnchor),
            portalCoreView.widthAnchor.constraint(equalToConstant: 220),
            portalCoreView.heightAnchor.constraint(equalToConstant: 248),

            floorGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floorGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 138),
            floorGlowView.widthAnchor.constraint(equalToConstant: 280),
            floorGlowView.heightAnchor.constraint(equalToConstant: 100),

            revealSlitView.centerXAnchor.constraint(equalTo: cardStageView.centerXAnchor),
            revealSlitView.centerYAnchor.constraint(equalTo: cardStageView.centerYAnchor),
            revealSlitView.widthAnchor.constraint(equalToConstant: 40),
            revealSlitView.heightAnchor.constraint(equalToConstant: 340),

            cardStageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardStageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16),
            cardStageView.widthAnchor.constraint(equalToConstant: 214),
            cardStageView.heightAnchor.constraint(equalToConstant: 304),

            sceneRewardCardView.centerXAnchor.constraint(equalTo: cardStageView.centerXAnchor),
            sceneRewardCardView.centerYAnchor.constraint(equalTo: cardStageView.centerYAnchor),
            sceneRewardCardView.widthAnchor.constraint(equalTo: cardStageView.widthAnchor),
            sceneRewardCardView.heightAnchor.constraint(equalTo: cardStageView.heightAnchor),

            cardInteractionHostView.leadingAnchor.constraint(equalTo: cardStageView.leadingAnchor),
            cardInteractionHostView.trailingAnchor.constraint(equalTo: cardStageView.trailingAnchor),
            cardInteractionHostView.topAnchor.constraint(equalTo: cardStageView.topAnchor),
            cardInteractionHostView.bottomAnchor.constraint(equalTo: cardStageView.bottomAnchor),

            cardFlipContainer.leadingAnchor.constraint(equalTo: cardInteractionHostView.leadingAnchor),
            cardFlipContainer.trailingAnchor.constraint(equalTo: cardInteractionHostView.trailingAnchor),
            cardFlipContainer.topAnchor.constraint(equalTo: cardInteractionHostView.topAnchor),
            cardFlipContainer.bottomAnchor.constraint(equalTo: cardInteractionHostView.bottomAnchor),

            backCardView.leadingAnchor.constraint(equalTo: cardFlipContainer.leadingAnchor),
            backCardView.trailingAnchor.constraint(equalTo: cardFlipContainer.trailingAnchor),
            backCardView.topAnchor.constraint(equalTo: cardFlipContainer.topAnchor),
            backCardView.bottomAnchor.constraint(equalTo: cardFlipContainer.bottomAnchor),

            frontCardView.leadingAnchor.constraint(equalTo: cardFlipContainer.leadingAnchor),
            frontCardView.trailingAnchor.constraint(equalTo: cardFlipContainer.trailingAnchor),
            frontCardView.topAnchor.constraint(equalTo: cardFlipContainer.topAnchor),
            frontCardView.bottomAnchor.constraint(equalTo: cardFlipContainer.bottomAnchor),

            backCardImageView.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor),
            backCardImageView.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor),
            backCardImageView.topAnchor.constraint(equalTo: backCardView.topAnchor),
            backCardImageView.bottomAnchor.constraint(equalTo: backCardView.bottomAnchor),

            backCardSweepView.leadingAnchor.constraint(equalTo: backCardView.leadingAnchor),
            backCardSweepView.trailingAnchor.constraint(equalTo: backCardView.trailingAnchor),
            backCardSweepView.topAnchor.constraint(equalTo: backCardView.topAnchor),
            backCardSweepView.bottomAnchor.constraint(equalTo: backCardView.bottomAnchor),

            frontCardImageView.leadingAnchor.constraint(equalTo: frontCardView.leadingAnchor),
            frontCardImageView.trailingAnchor.constraint(equalTo: frontCardView.trailingAnchor),
            frontCardImageView.topAnchor.constraint(equalTo: frontCardView.topAnchor),
            frontCardImageView.bottomAnchor.constraint(equalTo: frontCardView.bottomAnchor),

            frontCardShineView.leadingAnchor.constraint(equalTo: frontCardView.leadingAnchor),
            frontCardShineView.trailingAnchor.constraint(equalTo: frontCardView.trailingAnchor),
            frontCardShineView.topAnchor.constraint(equalTo: frontCardView.topAnchor),
            frontCardShineView.bottomAnchor.constraint(equalTo: frontCardView.bottomAnchor),

            rarityBadge.topAnchor.constraint(equalTo: frontCardView.topAnchor, constant: 14),
            rarityBadge.leadingAnchor.constraint(equalTo: frontCardView.leadingAnchor, constant: 14),
            rarityBadge.heightAnchor.constraint(equalToConstant: 24),
            rarityBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 42),

            rarityBadgeLabel.leadingAnchor.constraint(equalTo: rarityBadge.leadingAnchor, constant: 10),
            rarityBadgeLabel.trailingAnchor.constraint(equalTo: rarityBadge.trailingAnchor, constant: -10),
            rarityBadgeLabel.centerYAnchor.constraint(equalTo: rarityBadge.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: cardStageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            interactionHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            interactionHintLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            interactionHintLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            interactionHintLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            collectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            collectButton.widthAnchor.constraint(equalToConstant: 216),
            collectButton.heightAnchor.constraint(equalToConstant: 56),

            collectButtonBackground.leadingAnchor.constraint(equalTo: collectButton.leadingAnchor),
            collectButtonBackground.trailingAnchor.constraint(equalTo: collectButton.trailingAnchor),
            collectButtonBackground.topAnchor.constraint(equalTo: collectButton.topAnchor),
            collectButtonBackground.bottomAnchor.constraint(equalTo: collectButton.bottomAnchor),

            collectLabel.centerXAnchor.constraint(equalTo: collectButton.centerXAnchor),
            collectLabel.centerYAnchor.constraint(equalTo: collectButton.centerYAnchor),
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleInteractivePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        pan.delegate = self
        cardInteractionHostView.addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleInteractiveTap))
        tap.delegate = self
        tap.require(toFail: pan)
        cardInteractionHostView.addGestureRecognizer(tap)

        prepareBackCardForAnimation()
    }

    private func playRevealAnimation() {
        prepareBackCardForAnimation()

        titleLabel.text = "封包校准"
        subtitleLabel.text = series.title
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 16)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 16)
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        rarityBadge.alpha = 0

        cardStageView.alpha = 0
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.isHidden = true
        cardStageView.transform = CGAffineTransform(scaleX: 0.82, y: 0.82).translatedBy(x: 0, y: 28)
        portalGlowView.alpha = 0
        portalCoreView.alpha = 0
        floorGlowView.alpha = 0
        revealSlitView.alpha = 0
        dimmingView.alpha = 0
        portalCoreView.transform = CGAffineTransform(scaleX: 0.86, y: 0.72)
        portalGlowView.transform = CGAffineTransform(scaleX: 0.96, y: 0.9)
        revealSlitView.transform = CGAffineTransform(scaleX: 0.18, y: 0.9)

        UIView.animate(withDuration: 0.36, delay: 0.0, options: [.curveEaseOut]) {
            self.dimmingView.alpha = 1
            self.portalGlowView.alpha = 0.56
            self.portalCoreView.alpha = 0.42
            self.portalGlowView.transform = .identity
            self.portalCoreView.transform = .identity
            self.floorGlowView.alpha = 0.26
            self.cardStageView.alpha = 1
            self.cardStageView.transform = .identity
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
            self.titleLabel.transform = .identity
            self.subtitleLabel.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            self.startIdleMotion()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.playLockInPhase()
        }
    }

    private func playLockInPhase() {
        stopIdleMotion()
        playShockwave()
        playEdgeChargeGlow()

        titleLabel.text = "密钥注入"
        subtitleLabel.text = "封包即将解锁"

        // Phase 1 — slow energy build (0→0.45s)
        UIView.animateKeyframes(withDuration: 0.82, delay: 0.0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.36) {
                self.cardStageView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03).translatedBy(x: 0, y: -5)
                self.portalGlowView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.portalCoreView.transform = CGAffineTransform(scaleX: 1.08, y: 1.02)
                self.portalCoreView.alpha = 0.54
                self.floorGlowView.transform = CGAffineTransform(scaleX: 1.06, y: 0.86)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.36, relativeDuration: 0.40) {
                self.cardStageView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08).translatedBy(x: 0, y: -10)
                self.portalGlowView.alpha = 0.76
                self.portalCoreView.transform = CGAffineTransform(scaleX: 1.18, y: 1.06)
                self.portalCoreView.alpha = 0.68
            }
            UIView.addKeyframe(withRelativeStartTime: 0.76, relativeDuration: 0.24) {
                self.cardStageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05).translatedBy(x: 0, y: -8)
            }
        }

        // Double rattle at peak for tension
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { self.playChargeRattle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) { self.playChargeRattle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) { self.playFlashReveal() }
    }

    private func playEdgeChargeGlow() {
        playBackCardSweep()

        let charge = CAShapeLayer()
        charge.name = "edgeChargeGlow"
        charge.path = UIBezierPath(roundedRect: backCardView.bounds, cornerRadius: 28).cgPath
        charge.fillColor = UIColor.clear.cgColor
        charge.strokeColor = series.accent.withAlphaComponent(0).cgColor
        charge.lineWidth = 3
        charge.shadowColor = series.accent.cgColor
        charge.shadowRadius = 12
        charge.shadowOpacity = 0
        charge.shadowOffset = .zero
        backCardView.layer.addSublayer(charge)

        let colorAnim = CAKeyframeAnimation(keyPath: "strokeColor")
        colorAnim.values = [
            series.accent.withAlphaComponent(0).cgColor,
            series.accent.withAlphaComponent(0.55).cgColor,
            series.accent.withAlphaComponent(0.92).cgColor,
        ]
        colorAnim.keyTimes = [0, 0.45, 1.0]
        colorAnim.duration = 0.66
        colorAnim.fillMode = .forwards
        colorAnim.isRemovedOnCompletion = false

        let shadowAnim = CAKeyframeAnimation(keyPath: "shadowOpacity")
        shadowAnim.values = [0, 0.45, 0.88]
        shadowAnim.keyTimes = [0, 0.45, 1.0]
        shadowAnim.duration = 0.66
        shadowAnim.fillMode = .forwards
        shadowAnim.isRemovedOnCompletion = false

        charge.add(colorAnim, forKey: "chargeColor")
        charge.add(shadowAnim, forKey: "chargeShadow")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
            charge.removeFromSuperlayer()
        }
    }

    private func playFlashReveal() {
        let rarity = resultCard.rarity
        let rarityColor = legacyRarityAccentColor(for: rarity)
        playRevealSlit()
        transitionAtmosphereToRarity(rarityColor)

        titleLabel.text = "结果揭晓"
        subtitleLabel.text = "\(rarity) 级信号已确认"

        // Portal scales while card charges
        UIView.animate(withDuration: 0.24, delay: 0.0, options: [.curveEaseInOut]) {
            self.portalGlowView.transform = CGAffineTransform(scaleX: 1.06, y: 0.98)
            self.portalGlowView.alpha = 0.42
            self.portalCoreView.transform = CGAffineTransform(scaleX: 1.36, y: 1.18)
            self.portalCoreView.alpha = 0.78
            self.floorGlowView.transform = CGAffineTransform(scaleX: 1.08, y: 0.82)
        }

        // Phase 1 — back card rotates to edge-on (easeIn, 0.26s)
        UIView.animate(withDuration: 0.26, delay: 0.0, options: [.curveEaseIn]) {
            self.backCardView.layer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 1, 0)
            self.cardStageView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06).translatedBy(x: 0, y: -12)
        } completion: { _ in
            // — midpoint flash & particles at exact 90° —
            self.playShockwave(accentColor: rarityColor)
            self.playBurstParticles(rarity: rarity)
            if rarity == "SSR" { self.playSSRAuraPulse() }

            self.flashView.backgroundColor = legacyRarityFlashColor(for: rarity)
            let peak: CGFloat = rarity == "SSR" ? 0.94 : (rarity == "SR" ? 0.88 : 0.82)
            self.flashView.alpha = peak
            UIView.animate(withDuration: 0.30, delay: 0.0, options: [.curveEaseOut]) {
                self.flashView.alpha = 0
            }

            // Swap faces
            self.backCardView.alpha = 0
            self.backCardView.layer.transform = CATransform3DIdentity
            self.frontCardView.alpha = 1
            self.rarityBadge.alpha = 0
            self.frontCardView.layer.transform = CATransform3DMakeRotation(.pi / 2, 0, 1, 0)

            // Phase 2 — front card sweeps in with spring (0.44s)
            UIView.animate(
                withDuration: 0.44,
                delay: 0.0,
                usingSpringWithDamping: 0.74,
                initialSpringVelocity: 0.4,
                options: []
            ) {
                self.frontCardView.layer.transform = CATransform3DIdentity
                self.rarityBadge.alpha = 1
                self.cardStageView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } completion: { _ in
                UIView.animate(withDuration: 0.36, delay: 0.0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
                    self.cardStageView.transform = .identity
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                self.finishReveal()
            }
        }
    }

    private func finishReveal() {
        titleLabel.text = resultCard.title
        if let assetNumber = resultCard.assetNumber {
            subtitleLabel.text = "\(series.title) · \(resultCard.rarity) · #\(assetNumber)\n\(remainingKeysText)"
        } else {
            subtitleLabel.text = "\(series.title) · \(resultCard.rarity)\n\(remainingKeysText)"
        }

        UIView.animate(withDuration: 0.16, delay: 0.0, options: [.curveEaseOut]) {
            self.portalGlowView.alpha = 0.34
            self.portalCoreView.alpha = 0.18
            self.floorGlowView.alpha = 0.12
            self.revealSlitView.alpha = 0
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }

        cardStageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.24, delay: 0.0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.7, options: [.curveEaseOut]) {
            self.cardStageView.transform = .identity
            self.portalGlowView.transform = .identity
            self.portalCoreView.transform = .identity
            self.floorGlowView.transform = CGAffineTransform(scaleX: 1.02, y: 0.78)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.64) {
            self.enterInteractiveResultMode()
        }
    }

    private func enterInteractiveResultMode() {
        let snapshot = makeRevealFrontSnapshotView()
        let sourceFrame = backCardView.convert(backCardView.bounds, to: view)

        sceneRewardCardView.configure(
            title: resultCard.title,
            rarity: resultCard.rarity,
            frontImageURL: resultCard.remoteImageURL,
            localImageName: resultCard.localImageName,
            backImageName: series.backImageName,
            accent: rarityAccentColor(for: resultCard.rarity)
        )
        sceneRewardCardView.isHidden = false
        view.layoutIfNeeded()
        let targetFrame = sceneRewardCardView.projectedCardFrame(in: view) ?? sourceFrame
        sceneRewardCardView.alpha = 0
        sceneRewardCardView.transform = .identity
        sceneRewardCardView.isUserInteractionEnabled = false

        snapshot.frame = sourceFrame
        snapshot.layer.cornerRadius = 28
        snapshot.layer.cornerCurve = .continuous
        snapshot.clipsToBounds = true
        view.addSubview(snapshot)

        UIView.animate(withDuration: 0.34, delay: 0.0, options: [.curveEaseInOut]) {
            self.interactionHintLabel.alpha = 1
            self.collectButton.alpha = 1
            self.portalGlowView.alpha = 0.2
            self.portalCoreView.alpha = 0.08
            self.floorGlowView.alpha = 0.08
            self.cardStageView.alpha = 0
            self.sceneRewardCardView.alpha = 1
            snapshot.frame = targetFrame
            snapshot.alpha = 0
        } completion: { _ in
            snapshot.removeFromSuperview()
            self.sceneRewardCardView.isUserInteractionEnabled = true
            self.isInteractiveResultEnabled = true
        }
    }

    @objc private func handleInteractiveTap() {
        guard isInteractiveResultEnabled else { return }
        isShowingFrontFace.toggle()
        interactiveFlipAngle += .pi * (isShowingFrontFace ? -1 : 1)
        interactiveTiltX = 0
        interactiveTiltY = 0
        interactiveOffsetX = 0
        interactiveOffsetY = 0
        applyInteractiveCardTransform(animated: true, duration: 0.52)
        playFrontShineSweep()
    }

    @objc private func handleInteractivePan(_ recognizer: UIPanGestureRecognizer) {
        guard isInteractiveResultEnabled else { return }

        let translation = recognizer.translation(in: cardInteractionHostView)
        let velocity = recognizer.velocity(in: cardInteractionHostView)
        let normalizedX = max(-1, min(1, translation.x / max(cardInteractionHostView.bounds.width, 1)))
        let normalizedY = max(-1, min(1, translation.y / max(cardInteractionHostView.bounds.height, 1)))

        switch recognizer.state {
        case .began, .changed:
            interactiveTiltY = normalizedX * 0.78
            interactiveTiltX = -normalizedY * 0.44
            interactiveOffsetX = translation.x * 0.12
            interactiveOffsetY = translation.y * 0.08
            interactionHintLabel.alpha = 0.28
            applyInteractiveCardTransform(animated: false)
        case .ended, .cancelled, .failed:
            if abs(translation.x) > 76 || abs(velocity.x) > 760 {
                isShowingFrontFace.toggle()
                interactiveFlipAngle += .pi * (translation.x >= 0 ? -1 : 1)
            }
            interactiveTiltX = 0
            interactiveTiltY = 0
            interactiveOffsetX = 0
            interactiveOffsetY = 0
            interactionHintLabel.alpha = 1
            applyInteractiveCardTransform(animated: true, duration: 0.38)
        default:
            break
        }
    }

    @objc private func handleCollect() {
        onFinished?()
    }

    private func prepareBackCardForAnimation() {
        cardStageView.isHidden = false
        backCardView.isHidden = false
        backCardView.alpha = 1
        backCardView.layer.removeAllAnimations()
        backCardView.layer.transform = CATransform3DIdentity

        frontCardView.isHidden = false
        frontCardView.alpha = 1
        frontCardView.layer.removeAllAnimations()
        frontCardView.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        rarityBadge.alpha = 0
        cardFlipContainer.layer.transform = CATransform3DIdentity
    }

    private func makeRevealFrontSnapshotView() -> UIView {
        let snapshot = UIView(frame: .zero)
        snapshot.backgroundColor = UIColor(hex: 0x10141B)
        snapshot.layer.cornerRadius = 28
        snapshot.layer.cornerCurve = .continuous
        snapshot.clipsToBounds = true
        snapshot.layer.borderWidth = 0.9
        snapshot.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let imageView = UIImageView(image: frontCardImageView.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        snapshot.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: snapshot.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: snapshot.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: snapshot.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: snapshot.bottomAnchor),
        ])

        return snapshot
    }

    private func applyInteractiveCardTransform(animated: Bool, duration: TimeInterval = 0.18) {
        let flipTransform = CATransform3DMakeRotation(interactiveFlipAngle, 0, 1, 0)
        var hostTransform = CATransform3DIdentity
        hostTransform = CATransform3DTranslate(hostTransform, interactiveOffsetX, interactiveOffsetY, 0)
        hostTransform = CATransform3DScale(hostTransform, isShowingFrontFace ? 1.0 : 0.985, isShowingFrontFace ? 1.0 : 0.985, 1)
        hostTransform = CATransform3DRotate(hostTransform, interactiveTiltX, 1, 0, 0)
        hostTransform = CATransform3DRotate(hostTransform, interactiveTiltY, 0, 1, 0)

        let applyBlock = {
            self.cardFlipContainer.layer.transform = flipTransform
            self.cardInteractionHostView.layer.transform = hostTransform
        }

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            applyBlock()
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            applyBlock()
            CATransaction.commit()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func configureCardFace(_ face: UIView) {
        face.translatesAutoresizingMaskIntoConstraints = false
        face.layer.cornerRadius = 28
        face.layer.cornerCurve = .continuous
        face.layer.isDoubleSided = false
        face.clipsToBounds = true
        face.backgroundColor = UIColor(hex: 0x10141B)
        face.layer.borderWidth = 0.9
        face.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        face.layer.shadowColor = UIColor.black.cgColor
        face.layer.shadowOpacity = 0.24
        face.layer.shadowRadius = 28
        face.layer.shadowOffset = CGSize(width: 0, height: 18)
    }

    private func playFrontShineSweep() {
        guard let shineLayer = frontCardShineView.layer.sublayers?.first else { return }
        frontCardShineView.alpha = 1
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -200
        animation.toValue = 360
        animation.duration = 0.68
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        shineLayer.add(animation, forKey: "shineSweep")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.69) {
            self.frontCardShineView.alpha = 0
        }
    }

    private func playBurstParticles(rarity: String) {
        let cardFrame = cardStageView.convert(cardStageView.bounds, to: view)
        let origin = CGPoint(x: cardFrame.midX, y: cardFrame.midY - 10)
        let accent = rarityAccentColor(for: rarity)
        let intensity = particleIntensity(for: rarity)

        burstEmitter.emitterPosition = origin
        burstEmitter.emitterShape = .point
        burstEmitter.emitterSize = .zero
        streakEmitter.emitterPosition = origin
        streakEmitter.emitterShape = .rectangle
        streakEmitter.emitterSize = CGSize(width: cardFrame.width * 0.58, height: cardFrame.height * 0.78)
        dustEmitter.emitterPosition = origin
        dustEmitter.emitterShape = .rectangle
        dustEmitter.emitterSize = CGSize(width: cardFrame.width * 0.68, height: cardFrame.height * 0.92)
        burstEmitter.emitterCells = [
            makeBurstSparkCell(accent: accent, intensity: intensity),
            makeShardCell(accent: accent, intensity: intensity)
        ]
        streakEmitter.emitterCells = [makeStreakCell(accent: accent, intensity: intensity)]
        dustEmitter.emitterCells = [makeDustCell(accent: accent, intensity: intensity)]
        burstEmitter.birthRate = 1
        streakEmitter.birthRate = 1
        dustEmitter.birthRate = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.burstEmitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.streakEmitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            self.dustEmitter.birthRate = 0
        }
    }

    private func playSSRAuraPulse() {
        let ssrColor = UIColor(hex: 0xFFD76A)
        let aura = UIView(frame: view.bounds)
        aura.backgroundColor = ssrColor.withAlphaComponent(0.0)
        aura.isUserInteractionEnabled = false
        view.insertSubview(aura, aboveSubview: flashView)
        UIView.animateKeyframes(withDuration: 0.72, delay: 0.04, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.18) {
                aura.backgroundColor = ssrColor.withAlphaComponent(0.22)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.18, relativeDuration: 0.82) {
                aura.backgroundColor = ssrColor.withAlphaComponent(0.0)
            }
        } completion: { _ in
            aura.removeFromSuperview()
        }

        // Extra wide ring for SSR
        let aurLayer = CAShapeLayer()
        aurLayer.path = ringLayer.path
        aurLayer.fillColor = UIColor.clear.cgColor
        aurLayer.strokeColor = ssrColor.withAlphaComponent(0.52).cgColor
        aurLayer.lineWidth = 2.2
        aurLayer.lineCap = .round
        aurLayer.opacity = 0
        view.layer.addSublayer(aurLayer)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.78; scale.toValue = 1.48
        scale.duration = 0.72; scale.timingFunction = CAMediaTimingFunction(name: .easeOut)
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.78; fade.toValue = 0
        fade.duration = 0.72; fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
        let grp = CAAnimationGroup()
        grp.animations = [scale, fade]; grp.duration = 0.72
        grp.isRemovedOnCompletion = true
        aurLayer.opacity = 0.78
        aurLayer.add(grp, forKey: "ssrAura")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.76) {
            aurLayer.removeFromSuperlayer()
        }
    }

    private func playShockwave(accentColor: UIColor? = nil) {
        let accent = accentColor ?? series.accent
        ringLayer.strokeColor = accent.withAlphaComponent(0.38).cgColor
        ringLayer.opacity = 0.55
        secondaryRingLayer.strokeColor = accent.withAlphaComponent(0.22).cgColor
        secondaryRingLayer.opacity = 0.48

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.88
        scale.toValue = 1.28
        scale.duration = 0.54
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.85
        fade.toValue = 0
        fade.duration = 0.54
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.54
        group.isRemovedOnCompletion = true
        ringLayer.add(group, forKey: "shockwave")

        let innerScale = CABasicAnimation(keyPath: "transform.scale")
        innerScale.fromValue = 0.76
        innerScale.toValue = 1.08
        innerScale.duration = 0.36
        innerScale.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let innerFade = CABasicAnimation(keyPath: "opacity")
        innerFade.fromValue = 0.68
        innerFade.toValue = 0
        innerFade.duration = 0.36
        innerFade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let innerGroup = CAAnimationGroup()
        innerGroup.animations = [innerScale, innerFade]
        innerGroup.duration = 0.36
        innerGroup.isRemovedOnCompletion = true
        secondaryRingLayer.add(innerGroup, forKey: "secondaryShockwave")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) {
            self.ringLayer.opacity = 0
            self.secondaryRingLayer.opacity = 0
        }
    }

    private func transitionAtmosphereToRarity(_ rarityColor: UIColor) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.34)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        let names = ["legacyOpeningPortalPrimary", "legacyOpeningPortalCore", "legacyOpeningFloorGlow"]
        let alphas: [CGFloat] = [0.30, 0.22, 0.20]
        let views = [portalGlowView, portalCoreView, floorGlowView]
        for (i, view) in views.enumerated() {
            if let g = view.layer.sublayers?.first(where: { $0.name == names[i] }) as? CAGradientLayer {
                var updated = g.colors as? [CGColor] ?? []
                if updated.count >= 2 {
                    updated[0] = rarityColor.withAlphaComponent(alphas[i]).cgColor
                    if updated.count >= 3 { updated[1] = rarityColor.withAlphaComponent(alphas[i] * 0.45).cgColor }
                    g.colors = updated
                }
            }
            view.layer.shadowColor = rarityColor.withAlphaComponent(0.22).cgColor
        }
        CATransaction.commit()
    }

    private func startIdleMotion() {
        let backRotate = CABasicAnimation(keyPath: "transform")
        backRotate.fromValue = NSValue(caTransform3D: makeFaceRotation(-0.12))
        backRotate.toValue = NSValue(caTransform3D: makeFaceRotation(0.12))
        backRotate.duration = 1.15
        backRotate.autoreverses = true
        backRotate.repeatCount = .infinity
        backRotate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        backCardView.layer.add(backRotate, forKey: "idleBackRotate")

        let frontReset = CABasicAnimation(keyPath: "transform")
        frontReset.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(.pi, 0, 1, 0))
        frontReset.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(.pi, 0, 1, 0))
        frontReset.duration = 1.15
        frontReset.repeatCount = .infinity
        frontCardView.layer.add(frontReset, forKey: "idleFrontHold")

        let glowScale = CABasicAnimation(keyPath: "transform.scale")
        glowScale.fromValue = 0.96
        glowScale.toValue = 1.06
        glowScale.duration = 1.4
        glowScale.autoreverses = true
        glowScale.repeatCount = .infinity
        glowScale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        portalGlowView.layer.add(glowScale, forKey: "portalScale")

        let coreScale = CABasicAnimation(keyPath: "transform.scale")
        coreScale.fromValue = 0.94
        coreScale.toValue = 1.08
        coreScale.duration = 1.08
        coreScale.autoreverses = true
        coreScale.repeatCount = .infinity
        coreScale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        portalCoreView.layer.add(coreScale, forKey: "coreScale")

        UIView.animateKeyframes(withDuration: 1.55, delay: 0.0, options: [.autoreverse, .repeat, .calculationModeLinear]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                self.cardStageView.transform = CGAffineTransform(translationX: 0, y: -6)
            }
        }
    }

    private func stopIdleMotion() {
        backCardView.layer.removeAnimation(forKey: "idleBackRotate")
        frontCardView.layer.removeAnimation(forKey: "idleFrontHold")
        portalGlowView.layer.removeAnimation(forKey: "portalScale")
        portalCoreView.layer.removeAnimation(forKey: "coreScale")
        cardStageView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.12) {
            self.cardStageView.transform = .identity
            self.portalCoreView.transform = .identity
        }
    }

    private func refreshAtmosphereLayers() {
        let ambient = series.accent
        portalGlowView.backgroundColor = .clear
        portalGlowView.layer.shadowColor = ambient.withAlphaComponent(0.16).cgColor
        portalCoreView.backgroundColor = .clear
        portalCoreView.layer.shadowColor = ambient.withAlphaComponent(0.24).cgColor
        floorGlowView.backgroundColor = .clear
        floorGlowView.layer.shadowColor = ambient.withAlphaComponent(0.14).cgColor

        configureGradientLayer(
            in: portalGlowView,
            name: "legacyOpeningPortalPrimary",
            type: .radial,
            colors: [
                ambient.withAlphaComponent(0.18),
                ambient.withAlphaComponent(0.08),
                UIColor.clear
            ],
            locations: [0.0, 0.54, 1.0],
            startPoint: CGPoint(x: 0.46, y: 0.4),
            endPoint: CGPoint(x: 1.0, y: 1.0),
            frameInset: UIEdgeInsets(top: 26, left: 30, bottom: 18, right: 24)
        )

        configureGradientLayer(
            in: portalCoreView,
            name: "legacyOpeningPortalCore",
            type: .radial,
            colors: [
                ambient.withAlphaComponent(0.12),
                UIColor.clear
            ],
            locations: [0.0, 1.0],
            startPoint: CGPoint(x: 0.5, y: 0.44),
            endPoint: CGPoint(x: 1.0, y: 1.0),
            frameInset: UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        )

        configureGradientLayer(
            in: floorGlowView,
            name: "legacyOpeningFloorGlow",
            type: .radial,
            colors: [
                ambient.withAlphaComponent(0.12),
                ambient.withAlphaComponent(0.05),
                UIColor.clear
            ],
            locations: [0.0, 0.58, 1.0],
            startPoint: CGPoint(x: 0.5, y: 0.38),
            endPoint: CGPoint(x: 1.0, y: 1.0),
            frameInset: UIEdgeInsets(top: 8, left: 18, bottom: 18, right: 18)
        )
    }

    private func playRevealSlit() {
        view.bringSubviewToFront(revealSlitView)
        revealSlitView.layer.removeAllAnimations()
        revealSlitView.alpha = 0
        revealSlitView.transform = CGAffineTransform(scaleX: 0.14, y: 0.86)

        UIView.animateKeyframes(withDuration: 0.28, delay: 0.0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.24) {
                self.revealSlitView.alpha = 1
                self.revealSlitView.transform = CGAffineTransform(scaleX: 0.42, y: 0.98)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.24, relativeDuration: 0.34) {
                self.revealSlitView.alpha = 0.9
                self.revealSlitView.transform = CGAffineTransform(scaleX: 1.08, y: 1.06)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.58, relativeDuration: 0.42) {
                self.revealSlitView.alpha = 0
                self.revealSlitView.transform = CGAffineTransform(scaleX: 2.4, y: 1.12)
            }
        }
    }

    private func refreshRevealSlitLayers() {
        let ambient = series.accent
        revealSlitView.backgroundColor = .clear
        revealSlitView.layer.shadowColor = ambient.withAlphaComponent(0.42).cgColor

        configureGradientLayer(
            in: revealSlitView,
            name: "legacyRevealSlitCore",
            type: .axial,
            colors: [
                UIColor.clear,
                ambient.withAlphaComponent(0.24),
                UIColor.white.withAlphaComponent(0.92),
                ambient.withAlphaComponent(0.24),
                UIColor.clear
            ],
            locations: [0.0, 0.22, 0.5, 0.78, 1.0],
            startPoint: CGPoint(x: 0.0, y: 0.5),
            endPoint: CGPoint(x: 1.0, y: 0.5),
            frameInset: .zero
        )
    }

    private func configureGradientLayer(
        in container: UIView,
        name: String,
        type: CAGradientLayerType,
        colors: [UIColor],
        locations: [NSNumber],
        startPoint: CGPoint,
        endPoint: CGPoint,
        frameInset: UIEdgeInsets
    ) {
        let gradient: CAGradientLayer
        if let existing = container.layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer {
            gradient = existing
        } else {
            gradient = CAGradientLayer()
            gradient.name = name
            container.layer.addSublayer(gradient)
        }

        gradient.type = type
        gradient.colors = colors.map(\.cgColor)
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = CGRect(
            x: -frameInset.left,
            y: -frameInset.top,
            width: container.bounds.width + frameInset.left + frameInset.right,
            height: container.bounds.height + frameInset.top + frameInset.bottom
        )
    }

    private func playBackCardSweep() {
        guard let sweepLayer = backCardSweepView.layer.sublayers?.first else { return }
        backCardSweepView.alpha = 0.9
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -240
        animation.toValue = 320
        animation.duration = 0.44
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        sweepLayer.add(animation, forKey: "backSweep")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.46) {
            self.backCardSweepView.alpha = 0
        }
    }

    private func playChargeRattle() {
        let xShake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        xShake.values = [0, -4, 3, -2, 2, 0]
        xShake.keyTimes = [0.0, 0.18, 0.4, 0.62, 0.82, 1.0]
        xShake.duration = 0.24
        xShake.isAdditive = true
        xShake.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        cardInteractionHostView.layer.add(xShake, forKey: "chargeShakeX")

        let zShake = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        zShake.values = [0, -0.012, 0.01, -0.006, 0]
        zShake.keyTimes = [0.0, 0.22, 0.48, 0.74, 1.0]
        zShake.duration = 0.24
        zShake.isAdditive = true
        zShake.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        cardInteractionHostView.layer.add(zShake, forKey: "chargeShakeZ")
    }

    private func makePerspectiveSublayerTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 760
        return transform
    }

    private func makeFaceRotation(_ angle: CGFloat) -> CATransform3D {
        CATransform3DMakeRotation(angle, 0, 1, 0)
    }

    private func rarityAccentColor(for rarity: String) -> UIColor {
        switch rarity {
        case "SSR": return UIColor(hex: 0xFFD76A)
        case "SR": return UIColor(hex: 0xFF69D8)
        case "R": return UIColor(hex: 0x5EDBFF)
        default: return UIColor(hex: 0xA8B0BC)
        }
    }

    private func particleIntensity(for rarity: String) -> CGFloat {
        switch rarity {
        case "SSR": return 1.2
        case "SR": return 1.08
        case "R": return 0.96
        default: return 0.82
        }
    }

    private func makeBurstSparkCell(accent: UIColor = UIColor(hex: 0xE978FF), intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(42 * intensity)
        cell.lifetime = 0.54
        cell.velocity = 176 * intensity
        cell.velocityRange = 58 * intensity
        cell.emissionRange = .pi * 2
        cell.scale = 0.22
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.7
        cell.contents = legacyGlintImage()?.cgImage
        cell.color = UIColor.white.withAlphaComponent(0.9).cgColor
        return cell
    }

    private func makeShardCell(accent: UIColor = UIColor(hex: 0x63F9FF), intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(28 * intensity)
        cell.lifetime = 0.86
        cell.velocity = 74 * intensity
        cell.velocityRange = 30 * intensity
        cell.emissionRange = .pi * 2
        cell.spin = 0.18
        cell.spinRange = 0.26
        cell.scale = 0.14
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.92
        cell.yAcceleration = -16
        cell.contents = legacyMoteImage()?.cgImage
        cell.color = accent.withAlphaComponent(0.34).cgColor
        return cell
    }

    private func makeStreakCell(accent: UIColor = UIColor.white, intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(16 * intensity)
        cell.lifetime = 0.24
        cell.velocity = 248 * intensity
        cell.velocityRange = 34 * intensity
        cell.emissionRange = .pi * 2
        cell.spin = 0.28
        cell.scale = 0.18
        cell.scaleRange = 0.04
        cell.alphaSpeed = -3.2
        cell.contents = legacyStreakImage()?.cgImage
        cell.color = accent.withAlphaComponent(0.62).cgColor
        return cell
    }

    private func makeDustCell(accent: UIColor = UIColor.white, intensity: CGFloat = 1) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = Float(14 * intensity)
        cell.lifetime = 1.26
        cell.velocity = 18 * intensity
        cell.velocityRange = 12 * intensity
        cell.emissionRange = .pi * 2
        cell.scale = 0.08
        cell.scaleRange = 0.03
        cell.alphaSpeed = -0.42
        cell.yAcceleration = -10
        cell.contents = legacyMoteImage(size: CGSize(width: 28, height: 28))?.cgImage
        cell.color = accent.withAlphaComponent(0.16).cgColor
        return cell
    }
}

private final class LegacyCardFlipContainerView: UIView {}

private final class LegacySceneKitRewardCardView: SCNView, UIGestureRecognizerDelegate {
    private let sceneRoot = SCNScene()
    private let cardNode = SCNNode()
    private let ambientLightNode = SCNNode()
    private let keyLightNode = SCNNode()
    private let rimLightNode = SCNNode()
    private let fillLightNode = SCNNode()
    private var baseYaw: Float = 0
    private var isShowingFront = true
    private var cardSize = CGSize(width: 4.28, height: 6.10)
    private var cardDepth: CGFloat = 0.14

    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, rarity: String, frontImageURL: URL?, localImageName: String?, backImageName: String?, accent: UIColor) {
        let geometry = SCNBox(width: cardSize.width, height: cardSize.height, length: cardDepth, chamferRadius: 0.18)
        geometry.chamferSegmentCount = 8

        let frontImage = legacyBlindboxImage(localName: localImageName) ?? legacyLoadRemoteOrFileImage(url: frontImageURL)
        let backImage = legacyBlindboxImage(localName: backImageName)

        applyGeometry(
            geometry: geometry,
            frontImage: frontImage ?? UIImage.legacyBlindboxPlaceholder(title: title, accent: accent),
            backImage: backImage ?? UIImage.legacyBlindboxPlaceholder(title: "CARD BACK", accent: UIColor(hex: 0x8B80FF)),
            accent: accent
        )
    }

    func configure(frontImage: UIImage?, backImage: UIImage?, accent: UIColor) {
        let geometry = SCNBox(width: cardSize.width, height: cardSize.height, length: cardDepth, chamferRadius: 0.18)
        geometry.chamferSegmentCount = 8

        applyGeometry(
            geometry: geometry,
            frontImage: frontImage ?? UIImage.legacyBlindboxPlaceholder(title: "CARD", accent: accent),
            backImage: backImage ?? UIImage.legacyBlindboxPlaceholder(title: "CARD BACK", accent: UIColor(hex: 0x8B80FF)),
            accent: accent
        )
    }

    private func applyGeometry(geometry: SCNBox, frontImage: UIImage, backImage: UIImage, accent: UIColor) {
        let frontMaterial = makeSurfaceMaterial(image: frontImage)
        let backMaterial = makeSurfaceMaterial(image: backImage)
        let edgeMaterial = makeEdgeMaterial(accent: accent)
        geometry.materials = [frontMaterial, edgeMaterial, backMaterial, edgeMaterial, edgeMaterial, edgeMaterial]

        cardNode.geometry = geometry
        cardNode.position = SCNVector3Zero
        cardNode.eulerAngles = SCNVector3Zero
        cardNode.removeAllActions()
        cardNode.opacity = 1
        isShowingFront = true
        baseYaw = 0
        animateNode(pitch: 0, yaw: 0, xOffset: 0, yOffset: 0, duration: 0.0)

        rimLightNode.light?.color = accent.withAlphaComponent(0.92)
        fillLightNode.light?.color = accent.withAlphaComponent(0.22)

        let floatUp = SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 1.35)
        floatUp.timingMode = .easeInEaseOut
        let floatDown = floatUp.reversed()
        cardNode.runAction(.repeatForever(.sequence([floatUp, floatDown])), forKey: "float")
    }

    private func setup() {
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false
        scene = sceneRoot
        sceneRoot.background.contents = UIColor.clear
        allowsCameraControl = false
        autoenablesDefaultLighting = false
        antialiasingMode = .multisampling4X
        preferredFramesPerSecond = 60

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 34
        camera.zNear = 0.1
        camera.zFar = 40
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0.05, 11.6)
        sceneRoot.rootNode.addChildNode(cameraNode)
        pointOfView = cameraNode

        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 140
        ambientLightNode.light?.color = UIColor.white.withAlphaComponent(0.95)
        sceneRoot.rootNode.addChildNode(ambientLightNode)

        keyLightNode.light = SCNLight()
        keyLightNode.light?.type = .omni
        keyLightNode.light?.intensity = 420
        keyLightNode.light?.color = UIColor.white
        keyLightNode.position = SCNVector3(-3.4, 3.8, 6.6)
        sceneRoot.rootNode.addChildNode(keyLightNode)

        rimLightNode.light = SCNLight()
        rimLightNode.light?.type = .omni
        rimLightNode.light?.intensity = 180
        rimLightNode.position = SCNVector3(3.1, -1.2, 5.8)
        sceneRoot.rootNode.addChildNode(rimLightNode)

        fillLightNode.light = SCNLight()
        fillLightNode.light?.type = .omni
        fillLightNode.light?.intensity = 90
        fillLightNode.position = SCNVector3(0, -3.6, 4.4)
        sceneRoot.rootNode.addChildNode(fillLightNode)

        cardNode.castsShadow = false
        sceneRoot.rootNode.addChildNode(cardNode)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        tap.require(toFail: pan)
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        isShowingFront.toggle()
        baseYaw = isShowingFront ? 0 : .pi
        animateNode(pitch: 0, yaw: baseYaw, xOffset: 0, yOffset: 0, duration: 0.52)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let velocity = recognizer.velocity(in: self)
        let normalizedX = max(-1, min(1, translation.x / max(bounds.width, 1)))
        let normalizedY = max(-1, min(1, translation.y / max(bounds.height, 1)))

        switch recognizer.state {
        case .began, .changed:
            let yaw = baseYaw + Float(normalizedX) * 0.78
            let pitch = Float(-normalizedY) * 0.42
            let offsetX = Float(normalizedX) * 0.22
            let offsetY = Float(-normalizedY) * 0.14
            animateNode(pitch: pitch, yaw: yaw, xOffset: offsetX, yOffset: offsetY, duration: 0.0)
        case .ended, .cancelled, .failed:
            if abs(translation.x) > 72 || abs(velocity.x) > 760 {
                isShowingFront.toggle()
                baseYaw = isShowingFront ? 0 : .pi
            }
            animateNode(pitch: 0, yaw: baseYaw, xOffset: 0, yOffset: 0, duration: 0.34)
        default:
            break
        }
    }

    private func animateNode(pitch: Float, yaw: Float, xOffset: Float, yOffset: Float, duration: CFTimeInterval) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        cardNode.eulerAngles = SCNVector3(pitch, yaw, 0)
        cardNode.position = SCNVector3(xOffset, yOffset, 0)
        SCNTransaction.commit()
    }

    func projectedCardFrame(in referenceView: UIView) -> CGRect? {
        let halfWidth = Float(cardSize.width / 2)
        let halfHeight = Float(cardSize.height / 2)
        let z = Float(cardDepth / 2)
        let corners = [
            SCNVector3(-halfWidth, -halfHeight, z),
            SCNVector3(halfWidth, -halfHeight, z),
            SCNVector3(-halfWidth, halfHeight, z),
            SCNVector3(halfWidth, halfHeight, z),
        ]

        let points = corners.map { corner -> CGPoint in
            let world = cardNode.presentation.convertPosition(corner, to: nil)
            let projected = projectPoint(world)
            let local = CGPoint(x: CGFloat(projected.x), y: bounds.height - CGFloat(projected.y))
            return convert(local, to: referenceView)
        }

        guard let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max() else {
            return nil
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func makeSurfaceMaterial(image: UIImage) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.emission.contents = UIColor.black
        material.metalness.contents = 0
        material.roughness.contents = 1
        material.lightingModel = .constant
        return material
    }

    private func makeEdgeMaterial(accent: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(hex: 0x1A2230)
        material.emission.contents = accent.withAlphaComponent(0.05)
        material.specular.contents = UIColor.white.withAlphaComponent(0.08)
        material.metalness.contents = 0.04
        material.roughness.contents = 0.62
        material.lightingModel = .physicallyBased
        return material
    }
}

private func legacyNormalizedImageURL(from rawValue: String?) -> URL? {
    guard let rawValue = VitalityNetworkConfig.rewriteToReachableURL(rawValue), !rawValue.isEmpty else { return nil }
    if rawValue.hasPrefix("http://") || rawValue.hasPrefix("https://") || rawValue.hasPrefix("file://") {
        return URL(string: rawValue)
    }
    if rawValue.hasPrefix("/") {
        return URL(fileURLWithPath: rawValue)
    }
    return nil
}

private func legacyCoverAssetName(title: String, imageSource: String?) -> String? {
    if let mapped = legacyAssetName(from: imageSource), mapped.hasSuffix("Cover") {
        return mapped
    }
    switch title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "flutter series 01":
        return "Series1Cover"
    case "flutter series 02":
        return "Series2Cover"
    default:
        return nil
    }
}

private func legacyBackAssetName(title: String, imageSource: String?) -> String? {
    if let mapped = legacyAssetName(from: imageSource), mapped.hasSuffix("Back") {
        return mapped
    }
    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    switch normalized {
    case "flutter series 01":
        return "Series1Back"
    case "flutter series 02":
        return "Series2Back"
    default:
        // imageURL 里有 series 关键词时也尝试匹配
        let src = (imageSource ?? "").lowercased()
        if src.contains("series1") || src.contains("series_1") || src.contains("s1") {
            return "Series1Back"
        }
        if src.contains("series2") || src.contains("series_2") || src.contains("s2") {
            return "Series2Back"
        }
        // 兜底：标题含数字/关键词轮换，保证始终有背面图
        if normalized.contains("01") || normalized.contains("1") || normalized.contains("一") {
            return "Series1Back"
        }
        return "Series2Back"
    }
}

private func legacyCardAssetName(title: String, imageSource: String?) -> String? {
    if let mapped = legacyAssetName(from: imageSource), !mapped.hasSuffix("Cover"), !mapped.hasSuffix("Back") {
        return mapped
    }

    let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if normalized.hasPrefix("flutter series 01 #"),
       let suffix = normalized.split(separator: "#").last {
        return "Series1_" + legacyFileNameForCardIndex(String(suffix), series: 1)
    }

    if normalized.hasPrefix("flutter series 02 #"),
       let suffix = normalized.split(separator: "#").last {
        return "Series2_" + legacyFileNameForCardIndex(String(suffix), series: 2)
    }

    return nil
}

private func legacyFileNameForCardIndex(_ indexText: String, series: Int) -> String {
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
    let hashes = series == 1 ? series1 : series2
    return hashes[min(cardIndex, hashes.count - 1)]
}

private func legacyAssetName(from imageSource: String?) -> String? {
    guard let url = legacyNormalizedImageURL(from: imageSource), url.isFileURL else { return nil }
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
    if originalFileName == "盲盒系列.PNG" { return prefix + "Cover" }
    if originalFileName == "背面.PNG" { return prefix + "Back" }
    return "\(prefix)_\(fileName)"
}

private func legacyBlindboxImage(localName: String?) -> UIImage? {
    guard
        let localName,
        let path = Bundle.main.path(forResource: localName, ofType: "png", inDirectory: "BlindboxAssets")
    else {
        return nil
    }
    return UIImage(contentsOfFile: path)
}

private func legacyLoadRemoteOrFileImage(url: URL?) -> UIImage? {
    guard let url else { return nil }
    if url.isFileURL {
        return UIImage(contentsOfFile: url.path)
    }
    guard url.pathExtension.lowercased() != "svg", let data = try? Data(contentsOf: url) else { return nil }
    return UIImage(data: data)
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension UIView {
    func applyHorizontalGradient(colors: [UIColor], name: String = "buttonGradient") {
        removeGradient(named: name)
        let gradient = CAGradientLayer()
        gradient.name = name
        gradient.colors = colors.map(\.cgColor)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.cornerRadius = layer.cornerRadius
        gradient.frame = bounds.isEmpty ? CGRect(x: 0, y: 0, width: 120, height: 44) : bounds
        layer.insertSublayer(gradient, at: 0)
    }

    func updateGradientFrame(named name: String) {
        guard let gradient = layer.sublayers?.first(where: { $0.name == name }) as? CAGradientLayer else { return }
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
    }

    func removeGradient(named name: String) {
        layer.sublayers?.removeAll(where: { $0.name == name })
    }
}

private extension UIImage {
    static func legacyBlindboxPlaceholder(title: String, accent: UIColor, size: CGSize = CGSize(width: 320, height: 320)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let colors = [
                accent.withAlphaComponent(0.95).cgColor,
                UIColor(hex: 0x111318).cgColor,
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])

            if let gradient {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: rect.maxX, y: rect.maxY),
                    options: []
                )
            }

            let titleRect = rect.insetBy(dx: 18, dy: 18)
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .black),
                .foregroundColor: UIColor.white.withAlphaComponent(0.92),
                .paragraphStyle: paragraph,
            ]
            let text = String(title.prefix(18))
            text.draw(in: titleRect, withAttributes: attributes)
        }
    }
}

nonisolated(unsafe) private var legacyBlindboxImageTaskKey: UInt8 = 0

private extension UIImageView {
    func setBlindboxImage(localName: String?, remoteURL: URL?, placeholderTitle: String, accent: UIColor) {
        if let task = objc_getAssociatedObject(self, &legacyBlindboxImageTaskKey) as? URLSessionDataTask {
            task.cancel()
            objc_setAssociatedObject(self, &legacyBlindboxImageTaskKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        if let localName, let image = legacyBlindboxImage(localName: localName) {
            self.image = image
            return
        }

        self.image = UIImage.legacyBlindboxPlaceholder(title: placeholderTitle, accent: accent)

        guard let remoteURL else { return }
        if remoteURL.isFileURL {
            if let image = UIImage(contentsOfFile: remoteURL.path) {
                self.image = image
            }
            return
        }

        guard remoteURL.pathExtension.lowercased() != "svg" else { return }

        let task = URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }
        objc_setAssociatedObject(self, &legacyBlindboxImageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        task.resume()
    }
}

private func legacyGlintImage(size: CGSize = CGSize(width: 30, height: 30)) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        let rect = CGRect(origin: .zero, size: size)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        context.cgContext.setBlendMode(.screen)
        UIColor.white.withAlphaComponent(0.95).setStroke()

        let vertical = UIBezierPath()
        vertical.move(to: CGPoint(x: center.x, y: 3))
        vertical.addLine(to: CGPoint(x: center.x, y: rect.maxY - 3))
        vertical.lineWidth = 2.2
        vertical.lineCapStyle = .round
        vertical.stroke()

        let horizontal = UIBezierPath()
        horizontal.move(to: CGPoint(x: 5, y: center.y))
        horizontal.addLine(to: CGPoint(x: rect.maxX - 5, y: center.y))
        horizontal.lineWidth = 1.6
        horizontal.lineCapStyle = .round
        horizontal.stroke()
    }
}

private func legacyRarityAccentColor(for rarity: String) -> UIColor {
    switch rarity {
    case "SSR": return UIColor(hex: 0xFFD76A)
    case "SR": return UIColor(hex: 0xFF69D8)
    case "R": return UIColor(hex: 0x5EDBFF)
    default: return UIColor(hex: 0xA8B0BC)
    }
}

/// Flash background color at the moment of card reveal — tinted by rarity.
private func legacyRarityFlashColor(for rarity: String) -> UIColor {
    switch rarity {
    case "SSR": return UIColor(red: 1.00, green: 0.93, blue: 0.50, alpha: 1) // golden
    case "SR":  return UIColor(red: 1.00, green: 0.72, blue: 0.94, alpha: 1) // pink
    case "R":   return UIColor(red: 0.68, green: 0.94, blue: 1.00, alpha: 1) // cyan
    default:    return .white
    }
}

private func legacyParticleIntensity(for rarity: String) -> CGFloat {
    switch rarity {
    case "SSR": return 1.2
    case "SR": return 1.08
    case "R": return 0.96
    default: return 0.82
    }
}

private func legacyMoteImage(size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        let rect = CGRect(origin: .zero, size: size)
        let colors = [
            UIColor.white.withAlphaComponent(0.95).cgColor,
            UIColor.white.withAlphaComponent(0.26).cgColor,
            UIColor.clear.cgColor
        ] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.42, 1.0])!
        context.cgContext.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: rect.midX, y: rect.midY),
            startRadius: 0,
            endCenter: CGPoint(x: rect.midX, y: rect.midY),
            endRadius: rect.width / 2,
            options: []
        )
    }
}

private func legacyStreakImage() -> UIImage? {
    let size = CGSize(width: 52, height: 8)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        let rect = CGRect(origin: .zero, size: size)
        let colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.95).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.48, 1.0])!
        let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
        clipPath.addClip()
        context.cgContext.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.minX, y: rect.midY),
            end: CGPoint(x: rect.maxX, y: rect.midY),
            options: []
        )
    }
}
