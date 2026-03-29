import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: VitalityStore

    private let weekProgress: [(label: String, hit: Bool)] = [
        ("一", true), ("二", true), ("三", true), ("四", true), ("五", true), ("六", false), ("日", false)
    ]

    private var progress: Double {
        min(Double(store.health.moveCalories) / Double(store.health.goalCalories), 1.0)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topHero
                    streakPanel
                    caloriePanel
                    healthMetrics
                    timelinePanel
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("元气运动")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Apple 健康模拟数据已同步")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.68))
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(VitalityTheme.orange.opacity(0.14))
                        .frame(width: 54, height: 54)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(VitalityTheme.orange)
                }
            }

            HStack(spacing: 12) {
                headlinePill(title: "连胜天数", value: "\(store.health.winStreak)", tint: VitalityTheme.orange)
                headlinePill(title: "元气币", value: "\(store.profile.vitalityCoins)", tint: VitalityTheme.accent)
                headlinePill(title: "钥匙", value: "\(store.profile.keys)", tint: VitalityTheme.cyan)
            }
        }
        .padding(.top, 8)
    }

    private var streakPanel: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("每周达标")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(store.health.weeklyGoalHits)/7")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VitalityTheme.accent)
                }

                HStack(spacing: 12) {
                    ForEach(Array(weekProgress.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 8) {
                            Text(item.label)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(index == 5 ? VitalityTheme.accent : .white.opacity(0.6))
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(item.hit ? VitalityTheme.accent.opacity(0.22) : Color.white.opacity(0.05))
                                    .frame(width: 38, height: 46)
                                if item.hit {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundStyle(VitalityTheme.accent)
                                } else {
                                    Circle()
                                        .fill(index == 5 ? VitalityTheme.accent : Color.white.opacity(0.2))
                                        .frame(width: 7, height: 7)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var caloriePanel: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日卡路里")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("消耗热量可直接兑换元气币，连续达标可提升收集节奏。")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.66))
                    }
                    Spacer()
                    Text("目标 \(store.health.goalCalories)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VitalityTheme.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(VitalityTheme.orange.opacity(0.12), in: Capsule())
                }

                HStack(spacing: 18) {
                    dashboardRing
                        .frame(width: 188, height: 188)

                    VStack(alignment: .leading, spacing: 14) {
                        sideStat(title: "预计兑换", value: "\(max(store.health.moveCalories / 10, 1)) 元气币", icon: "bitcoinsign.circle.fill", tint: VitalityTheme.accent)
                        sideStat(title: "健康同步", value: "步数、距离、站立时长", icon: "waveform.path.ecg", tint: VitalityTheme.cyan)
                        sideStat(title: "奖励状态", value: progress >= 1 ? "今日满额可领取" : "继续运动解锁更多", icon: "sparkles", tint: VitalityTheme.orange)
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        store.claimCoinsFromCalories()
                    } label: {
                        Label("兑换元气币", systemImage: "sparkles")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .background(
                        LinearGradient(
                            colors: [VitalityTheme.accent, Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                    .foregroundStyle(Color.black.opacity(0.85))

                    Button {
                        store.buyKeys()
                    } label: {
                        Label("购买钥匙", systemImage: "key.fill")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var dashboardRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 18, lineCap: .round))

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [VitalityTheme.cyan, VitalityTheme.accent, VitalityTheme.orange, VitalityTheme.pink],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: VitalityTheme.accent.opacity(0.35), radius: 14, x: 0, y: 0)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.10), Color.white.opacity(0.03), .clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 80
                    )
                )
                .padding(22)

            VStack(spacing: 6) {
                Text("\(store.health.moveCalories)")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("kcal")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(Int(progress * 100))% 完成")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(VitalityTheme.accent)
            }
        }
    }

    private var healthMetrics: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metricCard(title: "步数", value: "\(store.health.steps)", unit: "steps", icon: "figure.walk.motion", tint: VitalityTheme.cyan)
                metricCard(title: "距离", value: store.health.distance.formatted(.number.precision(.fractionLength(1))), unit: "km", icon: "location.north.line.fill", tint: VitalityTheme.accent)
            }
            HStack(spacing: 12) {
                metricCard(title: "站立", value: "\(store.health.standHours)", unit: "hours", icon: "figure.stand.line.dotted.figure.stand", tint: VitalityTheme.orange)
                metricCard(title: "本周目标", value: "\(store.health.weeklyGoalHits)", unit: "days", icon: "target", tint: VitalityTheme.pink)
            }
        }
    }


    private var timelinePanel: some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("运动记录")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ForEach(store.activities) { item in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(VitalityTheme.accent)
                                .frame(width: 10, height: 10)
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 1)
                        }
                        .frame(height: 54)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(item.detail)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.66))
                            Text(item.timestamp)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(VitalityTheme.orange)
                        }
                    }
                }
            }
        }
    }

    private func headlinePill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(tint.opacity(0.24), lineWidth: 1)
                )
        )
    }

    private func sideStat(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func metricCard(title: String, value: String, unit: String, icon: String, tint: Color) -> some View {
        FrostCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(unit)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
    }
}
