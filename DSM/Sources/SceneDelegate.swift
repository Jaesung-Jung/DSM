//
//  SceneDelegate.swift
//  DSM
//
//  Created by 정재성 on 9/27/24.
//

import UIKit
import RxFlow
import JustFoundation

typealias Log = JustFoundation.Log

class SceneDelegate: UIResponder, UIWindowSceneDelegate, HasDisposeBag {
  let coordinator = FlowCoordinator()
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    coordinator.rx.willNavigate
      .subscribe(onNext: {
        Log.debug("👉 will navigate to flow=\($0) and step=\($1)")
      })
      .disposed(by: disposeBag)

    let appFlow = AppFlow(windowScene: windowScene)
    window = appFlow.window

    coordinator.coordinate(flow: appFlow, with: OneStepper(withSingleStep: AppStep.main))
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }
}
