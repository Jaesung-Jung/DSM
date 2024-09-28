//
//  IntroViewController.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import SwiftUI
import JustUI
import Lottie
import RxFlow
import RxCocoa
import SnapKit
import Synology

// MARK: - IntroViewController

final class IntroViewController: SceneViewController<IntroReactor> {
  let connectButton = JKButton(localizedTitle: "Connect to DSM", style: .filled, size: .large)

  override var sceneLayoutEdgeInsets: SceneLayoutEdgeInsets {
    SceneLayoutEdgeInsets(top: .fractional(0.15), leading: 20, bottom: 20, trailing: 20)
  }

  override var sceneLayoutMaxSize: SceneLayoutMaxSize {
    SceneLayoutMaxSize(width: 500)
  }

  override func bind(reactor: IntroReactor) {
    connectButton.rx.tap
      .map { .connection }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  override func configureUI() {
    super.configureUI()
    let logoView = LogoView()
    view.addSubview(logoView) {
      $0.top.equalTo(sceneLayoutGuide).priority(1)
      $0.centerX.equalTo(sceneLayoutGuide)
    }

    let featureIntroView = FeatureIntroView()
    featureIntroView.snp.makeConstraints {
      $0.height.equalTo(200)
    }
    let stackView = UIStackView(axis: .vertical, spacing: 20) {
      featureIntroView
      connectButton
    }
    view.addSubview(stackView) {
      $0.leading.trailing.bottom.equalTo(sceneLayoutGuide)
    }
  }
}

// MARK: - IntroViewController.LogoView

extension IntroViewController {
  final class LogoView: UIView {
    override init(frame: CGRect) {
      super.init(frame: frame)
      let logoImageView = UIImageView(image: .synologyLogo).then {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
      }
      addSubview(logoImageView) {
        $0.top.leading.trailing.equalToSuperview()
      }
      let logoLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .black)
        $0.text = "DiskStation Manager"
        $0.textColor = UIColor(light: UIColor(white: 0.655, alpha: 1), dark: .white)
      }
      addSubview(logoLabel) {
        $0.top.equalTo(logoImageView.snp.bottom).offset(4)
        $0.leading.trailing.equalTo(logoImageView)
        $0.bottom.equalToSuperview()
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - IntroViewController.FeatureIntroView

extension IntroViewController {
  final class FeatureIntroView: UIView {
    let contentView: UIView

    override init(frame: CGRect) {
      self.contentView = HostingView {
        ContentView()
      }
      super.init(frame: frame)
      addSubview(contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      contentView.frame = bounds
    }

    struct ContentView: View {
      @SwiftUI.State var index = 0
      let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

      var body: some View {
        ZStack {
          switch index {
          case 0:
            ItemView(
              animation: "intro.file",
              mode: .playOnce,
              title: "File",
              text: "Manage and access your files with ease."
            )
            .transition(.scale)
          case 1:
            ItemView(
              animation: "intro.share",
              mode: .playOnce,
              title: "Share",
              text: "Share your files easily, anytime and anywhere."
            )
            .transition(.scale)
          case 2:
            ItemView(
              animation: "intro.download",
              mode: .playOnce,
              title: "Download",
              text: "Download files easily from anywhere, directly to your DSM."
            )
            .transition(.scale)
          default:
            ItemView(
              animation: "intro.chart",
              mode: .loop,
              title: "Manage Device",
              text: "Easily monitor your system’s status and performance."
            )
            .transition(.scale)
          }
        }
        .onReceive(timer) { _ in
          index = (index + 1) % 4
        }
        .animation(.easeInOut, value: index)
      }
    }

    struct ItemView: View {
      let animation: String
      let mode: LottieLoopMode
      let title: LocalizedStringResource
      let text: LocalizedStringResource

      var body: some View {
        VStack(spacing: 20) {
          ZStack {
            Spacer()
          }
          .overlay {
            LottieView(animation: .named(animation))
              .playing(loopMode: mode)
              .frame(width: 120, height: 120)
          }
          .frame(width: 60, height: 60)

          VStack(spacing: 4) {
            Text(title)
              .font(.headline)
              .fontWeight(.heavy)
            Text(text)
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
              .frame(maxWidth: 200)
          }
          Spacer()
        }
      }
    }
  }
}

// MARK: - IntroViewController Preview

@available(iOS 17.0, *)
#Preview {
  IntroViewController()
}
