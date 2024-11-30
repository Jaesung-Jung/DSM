//
//  LoginViewController.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import UIKit
import JustUI
import RxSwift
import RxCocoa
import SnapKit
import ReactorKit

// MARK: - LoginViewController

final class LoginViewController: ConnectionFlowViewController<LoginReactor> {
  let accountTextField = JKTextField(style: .plain, contentInsets: NSDirectionalEdgeInsets(10)).then {
    $0.font = .preferredFont(forTextStyle: .headline)
    $0.placeholder = String(localized: "Account")
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
    $0.returnKeyType = .next
    $0.textContentType = .username
    $0.clearButtonMode = .whileEditing
  }

  let passwordTextField = JKTextField(style: .plain, contentInsets: NSDirectionalEdgeInsets(10)).then {
    $0.font = .preferredFont(forTextStyle: .headline)
    $0.placeholder = String(localized: "Password")
    $0.returnKeyType = .done
    $0.textContentType = .password
    $0.clearButtonMode = .whileEditing
    $0.isSecureTextEntry = true
  }

  let errorMessageLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .caption1)
    $0.textColor = .systemRed
    $0.numberOfLines = 0
    $0.isHidden = true
  }

  let passwordVisibilityButton = UIButton(configuration: .plain()).then {
    $0.configuration?.image = UIImage(systemName: "eye")
  }

  let helpButton = JKButton(localizedTitle: "Forgot your password?", size: .small).then {
    $0.configuration.contentInsets = NSDirectionalEdgeInsets(vertical: 16)
  }

  let loginButton = JKButton(localizedTitle: "Login", style: .filled, size: .large)

  override func bind(reactor: LoginReactor) {
  }

  override func configureUI() {
    super.configureUI()
    title = String(localized: "Login")

    let stackView = UIStackView(axis: .vertical, spacing: 16) {
      UILabel().then {
        $0.text = String(localized: "Your account and password are not stored and are only used for authentication.")
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
      }

      UIStackView(axis: .vertical) {
        UIStackView(axis: .vertical, spacing: 8) {
          TextInputView(
            image: UIImage(systemName: "person"),
            textField: accountTextField
          )
          TextInputView(
            image: UIImage(systemName: "lock"),
            textField: passwordTextField,
            trailingView: UIImageView(image: UIImage(systemName: "eye")).then {
              $0.setContentHuggingPriority(.required, for: .horizontal)
              $0.contentMode = .scaleAspectFit
            }
          )
          errorMessageLabel
        }
        UIStackView(axis: .vertical, alignment: .trailing) {
          helpButton
        }
      }
    }

    contentView.addSubview(stackView) {
      $0.directionalEdges.equalToSuperview()
    }

    bottomContentView.addSubview(loginButton) {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

// MARK: - LoginViewController (Private)

extension LoginViewController {
  final class TextInputView: UIView {
    init(image: UIImage?, textField: UITextField, trailingView: UIView? = nil) {
      super.init(frame: .zero)
      cornerRadius = 8
      cornerCurve = .continuous
      backgroundColor = .gray.withAlphaComponent(0.12)

      let imageView = UIImageView(image: image).then {
        $0.tintColor = .placeholderText
        $0.preferredSymbolConfiguration = .textStyle(.headline)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      }

      addSubview(imageView) {
        $0.leading.equalToSuperview().inset(16)
        $0.centerY.equalToSuperview()
      }
      if let trailingView {
        addSubview(textField) {
          $0.leading.equalTo(imageView.snp.trailing)
          $0.top.bottom.equalToSuperview()
        }
        addSubview(trailingView) {
          $0.leading.equalTo(textField.snp.trailing).offset(8)
          $0.top.bottom.equalToSuperview()
          $0.trailing.equalToSuperview().inset(16)
        }
      } else {
        addSubview(textField) {
          $0.leading.equalTo(imageView.snp.trailing)
          $0.top.bottom.equalToSuperview()
          $0.trailing.equalToSuperview().inset(16)
        }
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
//  private func _makeInputView(image: UIImage?, textField: FUTextField, trailingView: UIView? = nil) -> UIView {
//    let inputView = UIView().then {
//      $0.cornerRadius = 8
//      $0.cornerCurve = .continuous
//      $0.backgroundColor = .fluid.elevatedPrimary
//    }
//
//    let imageView = UIImageView(image: image).then {
//      $0.tintColor = .fluid.placeholder
//      $0.preferredSymbolConfiguration = .font(.fluid.headline(weight: .bold))
//      $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//    }
//    inputView.addSubview(imageView) {
//      $0.leading.equalToSuperview().inset(16)
//      $0.centerY.equalToSuperview()
//    }
//
//    if let trailingView {
//      inputView.addSubview(textField) {
//        $0.top.bottom.equalToSuperview()
//        $0.leading.equalTo(imageView.snp.trailing).offset(8)
//        $0.height.equalTo(44)
//      }
//
//      inputView.addSubview(trailingView) {
//        $0.top.bottom.trailing.equalToSuperview()
//        $0.leading.equalTo(textField.snp.trailing).offset(8)
//        $0.width.equalTo(trailingView.snp.height)
//      }
//    } else {
//      inputView.addSubview(textField) {
//        $0.top.bottom.equalToSuperview()
//        $0.leading.equalTo(imageView.snp.trailing).offset(8)
//        $0.trailing.equalToSuperview().inset(16)
//        $0.height.equalTo(44)
//      }
//    }
//    return inputView
//  }
}

// MARK: - LoginViewController Preview

@available(iOS 17.0, *)
#Preview {
  PreviewViewController(presentationStyle: .root, prefersLargeTitles: false) {
    LoginViewController()
  }
}
