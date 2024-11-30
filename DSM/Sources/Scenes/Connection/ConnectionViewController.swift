//
//  ConnectionViewController.swift
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

// MARK: - ConnectionViewController

final class ConnectionViewController: ConnectionFlowViewController<ConnectionReactor> {
  let addressTextField = JKTextField(style: .rounded).then {
    $0.font = .preferredFont(forTextStyle: .headline)
    $0.placeholder = String(localized: "QuickConnect ID or URL")
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
    $0.returnKeyType = .done
    $0.textContentType = .URL
    $0.clearButtonMode = .whileEditing
  }

  let errorMessageLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .caption1)
    $0.textColor = .systemRed
    $0.numberOfLines = 0
    $0.isHidden = true
  }

  let helpButton = JKButton(localizedTitle: "What is QuickConnect ID?", size: .small).then {
    $0.configuration.contentInsets = NSDirectionalEdgeInsets(vertical: 16)
  }

  let connectButton = JKButton(localizedTitle: "Connect", style: .filled, size: .large)

  override func bind(reactor: ConnectionReactor) {
    reactor.state
      .map { !$0.address.isEmpty }
      .distinctUntilChanged()
      .bind(to: connectButton.rx.isEnabled)
      .disposed(by: disposeBag)

    reactor.state
      .map(\.isLoading)
      .distinctUntilChanged()
      .bind(with: self) { `self`, isLoading in
        self.connectButton.configuration.showsActivityIndicator = isLoading
        self.addressTextField.isEnabled = !isLoading
        self.helpButton.isEnabled = !isLoading
      }
      .disposed(by: disposeBag)

    reactor
      .pulse(\.$connectCompleted)
      .filter {
        if case .success = $0 {
          return true
        }
        return false
      }
      .bind { Feedback.notification(.success) }
      .disposed(by: disposeBag)

    reactor
      .pulse(\.$connectCompleted)
      .compactMap {
        if case .failure(let error) = $0 {
          return error.localizedDescription
        }
        return nil
      }
      .observe(on: MainScheduler.asyncInstance)
      .bind(with: self) { `self`, errorMessage in
        if let errorMessage = try? AttributedString(markdown: errorMessage) {
          self.errorMessageLabel.attributedText = NSAttributedString(errorMessage)
        } else {
          self.errorMessageLabel.text = errorMessage
        }
        self.errorMessageLabel.isHidden = false
        self.addressTextField.textColor = .systemRed
        self.addressTextField.becomeFirstResponder()
        Feedback.notification(.error)
      }
      .disposed(by: disposeBag)

    rx.viewDidAppear
      .bind(with: addressTextField) {
        $0.becomeFirstResponder()
      }
      .disposed(by: disposeBag)

    addressTextField.rx.text.orEmpty
      .map { .updateAddress($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    addressTextField.rx.controlEvent(.editingChanged)
      .startWith(())
      .bind(with: self) { `self` in
        self.addressTextField.textColor = .label
        self.errorMessageLabel.isHidden = true
      }
      .disposed(by: disposeBag)

    connectButton.rx.tap
      .merge(addressTextField.rx.keyboardReturn)
      .map { .connect }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    helpButton.rx.tap
      .map { .help }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    closeButtonItem.rx.tap
      .map { .cancel }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  override func configureUI() {
    super.configureUI()
    title = String(localized: "Connect")

    let stackView = UIStackView(axis: .vertical, spacing: 16) {
      UILabel().then {
        $0.text = String(localized: "Enter your QuickConnect ID or URL to connect.")
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
      }

      UIStackView(axis: .vertical) {
        UIStackView(axis: .vertical, spacing: 8) {
          addressTextField
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

    bottomContentView.addSubview(connectButton) {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

// MARK: - ConnectionViewController Preview

@available(iOS 17.0, *)
#Preview {
  PreviewViewController(presentationStyle: .root, prefersLargeTitles: false) {
    ConnectionViewController()
  }
}
