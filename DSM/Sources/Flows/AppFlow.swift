//
//  AppFlow.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import UIKit
import SafariServices
import RxFlow
import RxSwift
import Synology

// MARK: - AppFlow

final class AppFlow: Flow {
  let window: UIWindow

  let keychain: AuthKeychain
  // let connectionManager: ConnectionManager
  let preferences: AppPreferences

  var root: Presentable { window }

  var rootViewController: UIViewController? { window.rootViewController }

  var presentedViewController: UIViewController? {
    func _presentedViewController(_ from: UIViewController?) -> UIViewController? {
      if let presentedViewController = from?.presentedViewController {
        return _presentedViewController(presentedViewController)
      }
      return from
    }
    return _presentedViewController(window.rootViewController?.presentedViewController)
  }

  init(windowScene: UIWindowScene) {
    let newWindow = UIWindow(windowScene: windowScene).then {
      $0.makeKeyAndVisible()
    }
    self.window = newWindow
    self.keychain = AuthKeychain()
    // self.connectionManager = ConnectionManager(keychain: keychain)
    self.preferences = AppPreferences()
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else {
      return .none
    }
    switch step {
    case .main:
      let reactor = IntroReactor()
      let viewController = IntroViewController(reactor: reactor)
      window.rootViewController = viewController
      return .one(flowContributor: .contribute(with: viewController))
    default:
      return .none
    }
  }
}

// MARK: - AppFlow.Window

final class AppStepper: Stepper {
  var initialStep: Step { AppStep.main }
}
