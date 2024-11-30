//
//  ConnectionFlowViewController.swift
//  DSM
//
//  Created by 정재성 on 9/28/24.
//

import UIKit
import SnapKit

class ConnectionFlowViewController<Reactor: SceneReactor>: SceneViewController<Reactor> {
  private let _scrollView = UIScrollView()

  let contentView = UIView()
  let bottomContentView = UIView()
  let closeButtonItem = UIBarButtonItem.closeBarButtonItem()

  override var sceneLayoutEdgeInsets: SceneLayoutEdgeInsets {
    SceneLayoutEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
  }

  override func configureUI() {
    super.configureUI()
    isModalInPresentation = true
    navigationItem.backButtonDisplayMode = .minimal

    if let navigationController, navigationController.viewControllers.count == 1 {
      navigationItem.leftBarButtonItem = closeButtonItem
    }

    let insets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
    view.addSubview(_scrollView) {
      $0.top.leading.trailing.equalToSuperview()
    }

    view.addSubview(bottomContentView) {
      $0.top.equalTo(_scrollView.snp.bottom)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(insets)
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-insets.bottom)
    }

    _scrollView.addSubview(contentView) {
      $0.top.bottom.equalTo(_scrollView.contentLayoutGuide).inset(insets)
      $0.leading.trailing.equalTo(_scrollView.frameLayoutGuide).inset(insets)
      $0.width.equalTo(_scrollView.contentLayoutGuide)
    }
  }
}
