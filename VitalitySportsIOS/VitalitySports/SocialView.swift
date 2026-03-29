import SwiftUI

struct SocialView: View {
    @State private var selection = 0

    private let socialPosts: [(name: String, detail: String, meta: String)] = [
        ("跑酷达人", "刚刚完成了 10km 晨跑，并晒出今日消耗卡路里。", "2 分钟前"),
        ("星际探索者", "开启盲盒获得 SR 藏品《极夜跨栏》，准备挂到市场试价。", "14 分钟前"),
        ("健身狂魔", "已经连续打卡 30 天，准备冲击下一个称号徽章。", "1 小时前")
    ]

    private let challenges: [(title: String, reward: String, progress: String, state: String)] = [
        ("一周跑步 50 公里", "500 元气币 + 1 把钥匙", "32 / 50 km", "进行中"),
        ("连续 7 天燃烧 500 kcal", "限定称号", "5 / 7 天", "冲刺中"),
        ("本周收集 3 张 SR 及以上卡", "限定展示边框", "2 / 3 张", "即将完成")
    ]

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "社交网络", subtitle: "社交动态与挑战竞技场切换查看，不再上下堆叠")

                    Picker("社交切换", selection: $selection) {
                        Text("社交动态").tag(0)
                        Text("挑战竞技场").tag(1)
                    }
                    .pickerStyle(.segmented)

                    if selection == 0 {
                        socialFeedSection
                    } else {
                        challengeArenaSection
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var socialFeedSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(socialPosts.enumerated()), id: \.offset) { index, post in
                FrostCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [VitalityTheme.cyan, VitalityTheme.pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(String(post.name.prefix(1)))
                                            .font(.system(size: 18, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                    )

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(post.name)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(post.meta)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(VitalityTheme.accent)
                                }
                            }
                            Spacer()
                            Image(systemName: index == 0 ? "bolt.fill" : "person.2.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(index == 0 ? VitalityTheme.orange : VitalityTheme.cyan)
                        }

                        Text(post.detail)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.74))

                        HStack(spacing: 22) {
                            socialAction(icon: "heart.fill", label: "点赞 12", tint: VitalityTheme.pink)
                            socialAction(icon: "message.fill", label: "评论 3", tint: VitalityTheme.cyan)
                            socialAction(icon: "arrowshape.turn.up.right.fill", label: "分享", tint: VitalityTheme.accent)
                        }
                    }
                }
            }
        }
    }

    private var challengeArenaSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(challenges.enumerated()), id: \.offset) { index, challenge in
                FrostCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(challenge.title)
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("奖励：\(challenge.reward)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.68))
                            }
                            Spacer()
                            Text(challenge.state)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background((index == 0 ? VitalityTheme.accent : VitalityTheme.orange), in: Capsule())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(challenge.progress)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(VitalityTheme.accent)

                            GeometryReader { geometry in
                                let progressWidth = geometry.size.width * progressValue(for: challenge.progress)
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [VitalityTheme.accent, VitalityTheme.cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: progressWidth)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
    }

    private func socialAction(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.68))
        }
    }

    private func progressValue(for progress: String) -> CGFloat {
        let numbers = progress
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }

        guard numbers.count >= 2, numbers[1] != 0 else { return 0.0 }
        return CGFloat(numbers[0]) / CGFloat(numbers[1])
    }
}
